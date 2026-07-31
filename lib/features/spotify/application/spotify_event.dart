import 'package:equatable/equatable.dart';

import '../domain/entities/spotify_playback_command.dart';

sealed class SpotifyEvent extends Equatable {
  const SpotifyEvent();

  @override
  List<Object?> get props => [];
}

class SpotifyStarted extends SpotifyEvent {
  const SpotifyStarted();
}

class SpotifyConfigSaveRequested extends SpotifyEvent {
  const SpotifyConfigSaveRequested({
    required this.clientId,
    required this.redirectUri,
  });

  final String clientId;
  final String redirectUri;

  @override
  List<Object?> get props => [clientId, redirectUri];
}

class SpotifyLoginRequested extends SpotifyEvent {
  const SpotifyLoginRequested();
}

class SpotifyLogoutRequested extends SpotifyEvent {
  const SpotifyLogoutRequested();
}

/// Internal event added by the polling [Timer] while authenticated.
class SpotifyPollTicked extends SpotifyEvent {
  const SpotifyPollTicked();
}

class SpotifyPlaybackCommandRequested extends SpotifyEvent {
  const SpotifyPlaybackCommandRequested(this.command);

  final SpotifyPlaybackCommand command;

  @override
  List<Object?> get props => [command];
}
