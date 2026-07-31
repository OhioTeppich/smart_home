import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StoredSpotifyAuth {
  const StoredSpotifyAuth({
    required this.clientId,
    required this.redirectUri,
    required this.refreshToken,
  });

  final String clientId;
  final String redirectUri;
  final String? refreshToken;
}

/// Client ID/Redirect URI are not sensitive and live in [SharedPreferences];
/// the refresh token is a long-lived credential and lives in secure storage.
class SpotifyLocalDataSource {
  SpotifyLocalDataSource({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const _clientIdKey = 'spotify_client_id';
  static const _redirectUriKey = 'spotify_redirect_uri';
  static const _refreshTokenKey = 'spotify_refresh_token';

  final FlutterSecureStorage _secureStorage;

  Future<StoredSpotifyAuth?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final clientId = prefs.getString(_clientIdKey);
    final redirectUri = prefs.getString(_redirectUriKey);
    if (clientId == null || redirectUri == null) return null;
    final refreshToken = await _secureStorage.read(key: _refreshTokenKey);
    return StoredSpotifyAuth(
      clientId: clientId,
      redirectUri: redirectUri,
      refreshToken: refreshToken,
    );
  }

  Future<void> writeConfig({
    required String clientId,
    required String redirectUri,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_clientIdKey, clientId);
    await prefs.setString(_redirectUriKey, redirectUri);
  }

  Future<void> writeRefreshToken(String refreshToken) async {
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<void> clearRefreshToken() async {
    await _secureStorage.delete(key: _refreshTokenKey);
  }
}
