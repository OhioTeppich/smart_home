import 'package:flutter_test/flutter_test.dart';
import 'package:smart_home/features/spotify/domain/value_objects/spotify_auth_config.dart';

void main() {
  test('tryCreate builds a config for a valid client id and redirect uri', () {
    final config = SpotifyAuthConfig.tryCreate(
      clientId: ' abc123 ',
      redirectUri: 'http://localhost:8080/auth.html',
    );

    expect(config, isNotNull);
    expect(config!.clientId, 'abc123');
    expect(config.redirectUri, 'http://localhost:8080/auth.html');
  });

  test('tryCreate rejects an empty client id', () {
    final config = SpotifyAuthConfig.tryCreate(
      clientId: '   ',
      redirectUri: 'http://localhost:8080/auth.html',
    );

    expect(config, isNull);
  });

  test('tryCreate rejects a redirect uri without a scheme', () {
    final config = SpotifyAuthConfig.tryCreate(
      clientId: 'abc123',
      redirectUri: 'localhost:8080/auth.html',
    );

    expect(config, isNull);
  });

  test('tryCreate rejects an unparsable redirect uri', () {
    final config = SpotifyAuthConfig.tryCreate(
      clientId: 'abc123',
      redirectUri: '::not a uri::',
    );

    expect(config, isNull);
  });
}
