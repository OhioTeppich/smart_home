import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/entities/spotify_playback_command.dart';
import '../../domain/failures/spotify_failure.dart';
import '../models/spotify_currently_playing_dto.dart';

class SpotifyRemoteDataSource {
  SpotifyRemoteDataSource({http.Client? httpClient})
    : _http = httpClient ?? http.Client();

  final http.Client _http;

  /// Uses `/v1/me/player` rather than the narrower
  /// `/v1/me/player/currently-playing` so the response also carries the
  /// active device's `volume_percent` for the Lauter/Leiser controls.
  /// Returns `null` when nothing is currently playing (HTTP 204).
  Future<SpotifyCurrentlyPlayingDto?> fetchCurrentlyPlaying(
    String accessToken,
  ) async {
    final response = await _http
        .get(
          Uri.https('api.spotify.com', '/v1/me/player'),
          headers: {'Authorization': 'Bearer $accessToken'},
        )
        .timeout(const Duration(seconds: 10));
    if (response.statusCode == 204 || response.body.isEmpty) return null;
    if (response.statusCode == 401) {
      throw const SpotifyUnauthenticatedFailure();
    }
    if (response.statusCode != 200) {
      throw SpotifyUnexpectedFailure('HTTP ${response.statusCode}');
    }
    return SpotifyCurrentlyPlayingDto.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<void> sendPlaybackCommand(
    String accessToken,
    SpotifyPlaybackCommand command,
  ) async {
    final path = switch (command) {
      SpotifyPlaybackCommand.play => '/v1/me/player/play',
      SpotifyPlaybackCommand.pause => '/v1/me/player/pause',
      SpotifyPlaybackCommand.skipNext => '/v1/me/player/next',
      SpotifyPlaybackCommand.skipPrevious => '/v1/me/player/previous',
    };
    final uri = Uri.https('api.spotify.com', path);
    final headers = {'Authorization': 'Bearer $accessToken'};
    final response = await switch (command) {
      SpotifyPlaybackCommand.play ||
      SpotifyPlaybackCommand.pause => _http.put(uri, headers: headers),
      SpotifyPlaybackCommand.skipNext ||
      SpotifyPlaybackCommand.skipPrevious => _http.post(uri, headers: headers),
    }.timeout(const Duration(seconds: 10));

    _checkCommandResponse(response);
  }

  Future<void> setVolume(String accessToken, int volumePercent) async {
    final response = await _http
        .put(
          Uri.https('api.spotify.com', '/v1/me/player/volume', {
            'volume_percent': '$volumePercent',
          }),
          headers: {'Authorization': 'Bearer $accessToken'},
        )
        .timeout(const Duration(seconds: 10));

    _checkCommandResponse(response);
  }

  /// Transfers/resumes playback onto [deviceId] (the Web Playback SDK's
  /// registered device). A 404 here typically means there's no prior
  /// playback context on the account to resume.
  Future<void> transferPlaybackToDevice(
    String accessToken,
    String deviceId,
  ) async {
    final response = await _http
        .put(
          Uri.https('api.spotify.com', '/v1/me/player'),
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'device_ids': [deviceId],
            'play': true,
          }),
        )
        .timeout(const Duration(seconds: 10));

    _checkCommandResponse(response);
  }

  /// Spotify's own docs promise HTTP 204 for these player-control endpoints,
  /// but in practice some clients/devices report back 200 with an empty
  /// body instead — treat both as success rather than surfacing a spurious
  /// "HTTP 200" error for a command that actually worked.
  void _checkCommandResponse(http.Response response) {
    if (response.statusCode == 200 || response.statusCode == 204) return;
    if (response.statusCode == 401) {
      throw const SpotifyUnauthenticatedFailure();
    }
    if (response.statusCode == 403) {
      throw const SpotifyPremiumRequiredFailure();
    }
    if (response.statusCode == 404) {
      throw const SpotifyNoActiveDeviceFailure();
    }
    throw SpotifyUnexpectedFailure('HTTP ${response.statusCode}');
  }
}
