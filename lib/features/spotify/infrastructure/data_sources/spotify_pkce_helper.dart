import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Pure helper functions for the OAuth Authorization Code + PKCE flow.
/// No I/O — safe to unit-test without mocking anything.
class SpotifyPkceHelper {
  static const _charset =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';

  /// A random string, 43-128 chars per RFC 7636 (`code_verifier`).
  static String generateCodeVerifier() => _randomString(64);

  /// `BASE64URL-ENCODE(SHA256(code_verifier))`, unpadded, per RFC 7636.
  static String generateCodeChallenge(String verifier) {
    final digest = sha256.convert(ascii.encode(verifier));
    return base64Url.encode(digest.bytes).replaceAll('=', '');
  }

  /// Opaque random value to guard the redirect against CSRF.
  static String generateState() => _randomString(32);

  static String _randomString(int length) {
    final random = Random.secure();
    return List.generate(
      length,
      (_) => _charset[random.nextInt(_charset.length)],
    ).join();
  }
}
