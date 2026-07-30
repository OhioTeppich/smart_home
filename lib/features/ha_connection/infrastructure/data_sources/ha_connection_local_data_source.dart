import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StoredHaConnection {
  const StoredHaConnection({required this.baseUrl, required this.token});

  final String baseUrl;
  final String token;
}

/// Base URL is not sensitive and lives in [SharedPreferences]; the
/// long-lived access token is sensitive and lives in secure storage.
class HaConnectionLocalDataSource {
  HaConnectionLocalDataSource({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const _baseUrlKey = 'ha_connection_base_url';
  static const _tokenKey = 'ha_connection_token';

  final FlutterSecureStorage _secureStorage;

  Future<StoredHaConnection?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final baseUrl = prefs.getString(_baseUrlKey);
    final token = await _secureStorage.read(key: _tokenKey);
    if (baseUrl == null || token == null) return null;
    return StoredHaConnection(baseUrl: baseUrl, token: token);
  }

  Future<void> write({required String baseUrl, required String token}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_baseUrlKey, baseUrl);
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_baseUrlKey);
    await _secureStorage.delete(key: _tokenKey);
  }
}
