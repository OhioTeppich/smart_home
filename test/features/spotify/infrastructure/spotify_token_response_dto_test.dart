import 'package:flutter_test/flutter_test.dart';
import 'package:smart_home/features/spotify/infrastructure/models/spotify_token_response_dto.dart';

void main() {
  test('fromJson maps access token, expiry and refresh token', () {
    final dto = SpotifyTokenResponseDto.fromJson({
      'access_token': 'access-123',
      'token_type': 'Bearer',
      'expires_in': 3600,
      'refresh_token': 'refresh-456',
      'scope': 'user-read-currently-playing',
    });

    expect(dto.accessToken, 'access-123');
    expect(dto.expiresIn, 3600);
    expect(dto.refreshToken, 'refresh-456');
  });

  test('fromJson tolerates an absent refresh_token (refresh grant)', () {
    final dto = SpotifyTokenResponseDto.fromJson({
      'access_token': 'access-123',
      'token_type': 'Bearer',
      'expires_in': 3600,
    });

    expect(dto.refreshToken, isNull);
  });
}
