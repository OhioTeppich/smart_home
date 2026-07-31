import 'package:flutter_test/flutter_test.dart';
import 'package:smart_home/features/spotify/infrastructure/data_sources/spotify_pkce_helper.dart';

void main() {
  test('generateCodeVerifier produces a 64-char unreserved string', () {
    final verifier = SpotifyPkceHelper.generateCodeVerifier();

    expect(verifier, hasLength(64));
    expect(RegExp(r'^[A-Za-z0-9]+$').hasMatch(verifier), isTrue);
  });

  test('generateCodeVerifier is random across calls', () {
    expect(
      SpotifyPkceHelper.generateCodeVerifier(),
      isNot(SpotifyPkceHelper.generateCodeVerifier()),
    );
  });

  test('generateCodeChallenge is deterministic and unpadded base64url', () {
    final challengeA = SpotifyPkceHelper.generateCodeChallenge('fixed-verifier');
    final challengeB = SpotifyPkceHelper.generateCodeChallenge('fixed-verifier');

    expect(challengeA, challengeB);
    expect(challengeA, isNot(contains('=')));
    expect(RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(challengeA), isTrue);
  });

  test('generateState produces a non-empty random string', () {
    final a = SpotifyPkceHelper.generateState();
    final b = SpotifyPkceHelper.generateState();

    expect(a, hasLength(32));
    expect(a, isNot(b));
  });
}
