import '../entities/spotify_now_playing.dart';
import '../entities/spotify_playback_command.dart';
import '../value_objects/spotify_auth_config.dart';

abstract class SpotifyRepository {
  /// Loaded auth config (Client ID/Redirect URI), independent of login state.
  Future<SpotifyAuthConfig?> loadAuthConfig();

  /// Persists Client ID/Redirect URI. Does not by itself authenticate.
  Future<void> saveAuthConfig(SpotifyAuthConfig config);

  /// Whether a refresh token from a previous login is stored.
  Future<bool> isAuthenticated();

  /// Runs the full PKCE login flow and persists the resulting refresh token.
  /// Throws a [SpotifyFailure] subtype on cancellation/failure.
  Future<void> login();

  /// Clears the stored refresh token. Keeps the saved auth config.
  Future<void> logout();

  /// Returns `null` when nothing is currently playing (not a failure).
  /// Throws a [SpotifyFailure] subtype on auth/network errors.
  Future<SpotifyNowPlaying?> fetchCurrentlyPlaying();

  /// Throws a [SpotifyFailure] subtype (e.g. no active device, Premium
  /// required) on failure. Returns normally on success.
  Future<void> sendPlaybackCommand(SpotifyPlaybackCommand command);

  /// [percent] is clamped to 0-100 by the caller before this is invoked.
  /// Throws a [SpotifyFailure] subtype on failure.
  Future<void> setVolume(int percent);

  /// Registers this browser tab as a Spotify Connect device (via the Web
  /// Playback SDK) and transfers/resumes playback onto it. Throws a
  /// [SpotifyFailure] subtype on failure (e.g. no Premium, no prior
  /// playback context to resume, or the SDK failing to connect).
  Future<void> playOnThisDevice();
}
