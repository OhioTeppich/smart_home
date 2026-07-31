import 'dart:async';
import 'dart:io';

import '../../domain/entities/spotify_now_playing.dart';
import '../../domain/entities/spotify_playback_command.dart';
import '../../domain/failures/spotify_failure.dart';
import '../../domain/repositories/spotify_repository.dart';
import '../../domain/value_objects/spotify_auth_config.dart';
import '../data_sources/spotify_auth_data_source.dart';
import '../data_sources/spotify_local_data_source.dart';
import '../data_sources/spotify_remote_data_source.dart';
import '../data_sources/spotify_web_playback_sdk.dart';
import '../models/spotify_token_response_dto.dart';

class SpotifyRepositoryImpl implements SpotifyRepository {
  SpotifyRepositoryImpl(
    this._local, [
    SpotifyAuthDataSource? authDataSource,
    SpotifyRemoteDataSource? remoteDataSource,
  ]) : _authDataSource = authDataSource ?? SpotifyAuthDataSource(),
       _remoteDataSource = remoteDataSource ?? SpotifyRemoteDataSource();

  final SpotifyLocalDataSource _local;
  final SpotifyAuthDataSource _authDataSource;
  final SpotifyRemoteDataSource _remoteDataSource;

  String? _accessToken;
  DateTime? _accessTokenExpiry;
  SpotifyWebPlaybackSdk? _webPlayback;

  @override
  Future<SpotifyAuthConfig?> loadAuthConfig() async {
    final stored = await _local.read();
    if (stored == null) return null;
    return SpotifyAuthConfig(
      clientId: stored.clientId,
      redirectUri: stored.redirectUri,
    );
  }

  @override
  Future<void> saveAuthConfig(SpotifyAuthConfig config) => _local.writeConfig(
    clientId: config.clientId,
    redirectUri: config.redirectUri,
  );

  @override
  Future<bool> isAuthenticated() async =>
      (await _local.read())?.refreshToken != null;

  @override
  Future<void> login() => _guard(() async {
    final stored = await _local.read();
    if (stored == null) throw const SpotifyInvalidConfigFailure();
    final config = SpotifyAuthConfig(
      clientId: stored.clientId,
      redirectUri: stored.redirectUri,
    );
    final tokens = await _authDataSource.authenticate(config);
    _applyTokens(tokens);
    final refreshToken = tokens.refreshToken;
    if (refreshToken == null) {
      throw const SpotifyUnexpectedFailure(
        'Spotify hat kein Refresh-Token geliefert.',
      );
    }
    await _local.writeRefreshToken(refreshToken);
  });

  @override
  Future<void> logout() async {
    _accessToken = null;
    _accessTokenExpiry = null;
    await _local.clearRefreshToken();
  }

  @override
  Future<SpotifyNowPlaying?> fetchCurrentlyPlaying() => _guard(() async {
    final token = await _validAccessToken();
    try {
      final dto = await _remoteDataSource.fetchCurrentlyPlaying(token);
      return dto?.toDomain();
    } on SpotifyUnauthenticatedFailure {
      final refreshed = await _validAccessToken(force: true);
      final dto = await _remoteDataSource.fetchCurrentlyPlaying(refreshed);
      return dto?.toDomain();
    }
  });

  @override
  Future<void> sendPlaybackCommand(SpotifyPlaybackCommand command) =>
      _guard(() async {
        final token = await _validAccessToken();
        try {
          await _remoteDataSource.sendPlaybackCommand(token, command);
        } on SpotifyUnauthenticatedFailure {
          final refreshed = await _validAccessToken(force: true);
          await _remoteDataSource.sendPlaybackCommand(refreshed, command);
        }
      });

  @override
  Future<void> setVolume(int percent) => _guard(() async {
    final token = await _validAccessToken();
    try {
      await _remoteDataSource.setVolume(token, percent);
    } on SpotifyUnauthenticatedFailure {
      final refreshed = await _validAccessToken(force: true);
      await _remoteDataSource.setVolume(refreshed, percent);
    }
  });

  @override
  Future<void> playOnThisDevice() => _guard(() async {
    final sdk = _webPlayback ??= SpotifyWebPlaybackSdk(
      getAccessToken: () => _validAccessToken(),
    );
    final String deviceId;
    try {
      deviceId = await sdk.ensureConnected();
    } on StateError catch (error) {
      throw SpotifyUnexpectedFailure(error.message);
    }
    final token = await _validAccessToken();
    try {
      await _remoteDataSource.transferPlaybackToDevice(token, deviceId);
    } on SpotifyUnauthenticatedFailure {
      final refreshed = await _validAccessToken(force: true);
      await _remoteDataSource.transferPlaybackToDevice(refreshed, deviceId);
    }
  });

  Future<String> _validAccessToken({bool force = false}) async {
    if (!force &&
        _accessToken != null &&
        _accessTokenExpiry!.isAfter(
          DateTime.now().add(const Duration(seconds: 30)),
        )) {
      return _accessToken!;
    }
    final stored = await _local.read();
    final refreshToken = stored?.refreshToken;
    if (stored == null || refreshToken == null) {
      throw const SpotifyUnauthenticatedFailure();
    }
    final config = SpotifyAuthConfig(
      clientId: stored.clientId,
      redirectUri: stored.redirectUri,
    );
    final tokens = await _authDataSource.refreshAccessToken(
      config,
      refreshToken,
    );
    _applyTokens(tokens);
    final rotatedRefreshToken = tokens.refreshToken;
    if (rotatedRefreshToken != null) {
      await _local.writeRefreshToken(rotatedRefreshToken);
    }
    return _accessToken!;
  }

  void _applyTokens(SpotifyTokenResponseDto tokens) {
    _accessToken = tokens.accessToken;
    _accessTokenExpiry = DateTime.now().add(
      Duration(seconds: tokens.expiresIn),
    );
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on SpotifyFailure {
      rethrow;
    } on TimeoutException {
      throw const SpotifyNetworkFailure();
    } on SocketException {
      throw const SpotifyNetworkFailure();
    } catch (error) {
      throw SpotifyUnexpectedFailure(error.toString());
    }
  }
}
