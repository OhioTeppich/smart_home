import 'package:equatable/equatable.dart';

import '../domain/entities/spotify_now_playing.dart';
import '../domain/failures/spotify_failure.dart';
import '../domain/value_objects/spotify_auth_config.dart';

sealed class SpotifyState extends Equatable {
  const SpotifyState({required this.authConfig});

  /// Carried through every state so the settings page can always prefill
  /// its fields via `BlocBuilder`, without calling the repository directly.
  final SpotifyAuthConfig? authConfig;

  @override
  List<Object?> get props => [authConfig];
}

class SpotifyInitial extends SpotifyState {
  const SpotifyInitial() : super(authConfig: null);
}

class SpotifyUnauthenticated extends SpotifyState {
  const SpotifyUnauthenticated({super.authConfig, this.error});

  final SpotifyFailure? error;

  @override
  List<Object?> get props => [authConfig, error];
}

class SpotifyAuthenticating extends SpotifyState {
  const SpotifyAuthenticating({required super.authConfig});
}

class SpotifyIdle extends SpotifyState {
  const SpotifyIdle({required super.authConfig});
}

class SpotifyPlaying extends SpotifyState {
  const SpotifyPlaying({
    required super.authConfig,
    required this.nowPlaying,
    this.commandError,
  });

  final SpotifyNowPlaying nowPlaying;

  /// Set briefly after a failed play/pause/skip command (e.g. no active
  /// device, Premium required); cleared again once the next poll succeeds.
  final SpotifyFailure? commandError;

  @override
  List<Object?> get props => [authConfig, nowPlaying, commandError];
}

class SpotifyError extends SpotifyState {
  const SpotifyError({required super.authConfig, required this.error});

  final SpotifyFailure error;

  @override
  List<Object?> get props => [authConfig, error];
}
