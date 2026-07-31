import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/failures/spotify_failure.dart';
import '../domain/repositories/spotify_repository.dart';
import '../domain/value_objects/spotify_auth_config.dart';
import 'spotify_event.dart';
import 'spotify_state.dart';

class SpotifyBloc extends Bloc<SpotifyEvent, SpotifyState> {
  SpotifyBloc(this._repository) : super(const SpotifyInitial()) {
    on<SpotifyStarted>(_onStarted);
    on<SpotifyConfigSaveRequested>(_onConfigSaveRequested);
    on<SpotifyLoginRequested>(_onLoginRequested);
    on<SpotifyLogoutRequested>(_onLogoutRequested);
    on<SpotifyPollTicked>(_onPollTicked);
    on<SpotifyPlaybackCommandRequested>(_onPlaybackCommandRequested);
    on<SpotifyVolumeChangeRequested>(_onVolumeChangeRequested);
  }

  final SpotifyRepository _repository;
  Timer? _pollTimer;

  Future<void> _onStarted(
    SpotifyStarted event,
    Emitter<SpotifyState> emit,
  ) async {
    final authConfig = await _repository.loadAuthConfig();
    final authenticated = await _repository.isAuthenticated();
    if (!authenticated) {
      emit(SpotifyUnauthenticated(authConfig: authConfig));
      return;
    }
    emit(SpotifyIdle(authConfig: authConfig));
    _startPolling();
    add(const SpotifyPollTicked());
  }

  Future<void> _onConfigSaveRequested(
    SpotifyConfigSaveRequested event,
    Emitter<SpotifyState> emit,
  ) async {
    final config = SpotifyAuthConfig.tryCreate(
      clientId: event.clientId,
      redirectUri: event.redirectUri,
    );
    if (config == null) {
      emit(
        SpotifyUnauthenticated(
          authConfig: state.authConfig,
          error: const SpotifyInvalidConfigFailure(),
        ),
      );
      return;
    }
    await _repository.saveAuthConfig(config);
    emit(SpotifyUnauthenticated(authConfig: config));
  }

  Future<void> _onLoginRequested(
    SpotifyLoginRequested event,
    Emitter<SpotifyState> emit,
  ) async {
    emit(SpotifyAuthenticating(authConfig: state.authConfig));
    try {
      await _repository.login();
      emit(SpotifyIdle(authConfig: state.authConfig));
      _startPolling();
      add(const SpotifyPollTicked());
    } on SpotifyFailure catch (failure) {
      emit(SpotifyUnauthenticated(authConfig: state.authConfig, error: failure));
    }
  }

  Future<void> _onLogoutRequested(
    SpotifyLogoutRequested event,
    Emitter<SpotifyState> emit,
  ) async {
    _pollTimer?.cancel();
    await _repository.logout();
    emit(SpotifyUnauthenticated(authConfig: state.authConfig));
  }

  Future<void> _onPollTicked(
    SpotifyPollTicked event,
    Emitter<SpotifyState> emit,
  ) async {
    try {
      final nowPlaying = await _repository.fetchCurrentlyPlaying();
      emit(
        nowPlaying == null
            ? SpotifyIdle(authConfig: state.authConfig)
            : SpotifyPlaying(
                authConfig: state.authConfig,
                nowPlaying: nowPlaying,
              ),
      );
    } on SpotifyUnauthenticatedFailure {
      _pollTimer?.cancel();
      emit(SpotifyUnauthenticated(authConfig: state.authConfig));
    } on SpotifyFailure catch (failure) {
      // Transient error (e.g. network hiccup) — keep polling, next tick may
      // recover, don't force the user to log in again.
      emit(SpotifyError(authConfig: state.authConfig, error: failure));
    }
  }

  Future<void> _onPlaybackCommandRequested(
    SpotifyPlaybackCommandRequested event,
    Emitter<SpotifyState> emit,
  ) => _runMutatingCommand(
    emit,
    () => _repository.sendPlaybackCommand(event.command),
  );

  Future<void> _onVolumeChangeRequested(
    SpotifyVolumeChangeRequested event,
    Emitter<SpotifyState> emit,
  ) async {
    final current = state;
    if (current is! SpotifyPlaying || current.nowPlaying.volumePercent == null) {
      return;
    }
    final target = (current.nowPlaying.volumePercent! + event.delta).clamp(
      0,
      100,
    );
    await _runMutatingCommand(emit, () => _repository.setVolume(target));
  }

  /// Shared by playback commands and volume changes: run [action], surface
  /// a transient [SpotifyPlaying.commandError] on failure (without losing
  /// the currently displayed track), then re-poll shortly after — instead
  /// of waiting for the next scheduled tick (up to 8s away) — so the UI
  /// reflects the actual new state quickly either way.
  Future<void> _runMutatingCommand(
    Emitter<SpotifyState> emit,
    Future<void> Function() action,
  ) async {
    final current = state;
    try {
      await action();
    } on SpotifyUnauthenticatedFailure {
      _pollTimer?.cancel();
      emit(SpotifyUnauthenticated(authConfig: state.authConfig));
      return;
    } on SpotifyFailure catch (failure) {
      if (current is SpotifyPlaying) {
        emit(
          SpotifyPlaying(
            authConfig: current.authConfig,
            nowPlaying: current.nowPlaying,
            commandError: failure,
          ),
        );
      }
    }
    await Future.delayed(const Duration(milliseconds: 400));
    add(const SpotifyPollTicked());
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(
      const Duration(seconds: 8),
      (_) => add(const SpotifyPollTicked()),
    );
  }

  @override
  Future<void> close() {
    _pollTimer?.cancel();
    return super.close();
  }
}
