import '../entities/spotify_now_playing.dart';
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
}
