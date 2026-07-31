import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// The 17Track API key is a long-lived credential and lives in secure
/// storage only — there is no non-sensitive half to split off, unlike
/// `HaConnectionLocalDataSource`/`SpotifyLocalDataSource`.
class Track17ApiKeyLocalDataSource {
  Track17ApiKeyLocalDataSource({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const _apiKeyKey = 'track17_api_key';

  final FlutterSecureStorage _secureStorage;

  Future<String?> read() => _secureStorage.read(key: _apiKeyKey);

  Future<void> write(String apiKey) =>
      _secureStorage.write(key: _apiKeyKey, value: apiKey);

  Future<void> clear() => _secureStorage.delete(key: _apiKeyKey);
}
