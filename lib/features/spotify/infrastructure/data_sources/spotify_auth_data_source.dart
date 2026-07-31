import 'dart:convert';

import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;

import '../../domain/failures/spotify_failure.dart';
import '../../domain/value_objects/spotify_auth_config.dart';
import '../models/spotify_token_response_dto.dart';
import 'spotify_pkce_helper.dart';

/// Runs the Authorization Code + PKCE flow via a browser popup
/// ([FlutterWebAuth2]) and talks to Spotify's `/authorize`/`/api/token`
/// endpoints. No client secret is used or needed — PKCE is secret-less.
class SpotifyAuthDataSource {
  SpotifyAuthDataSource({http.Client? httpClient})
    : _http = httpClient ?? http.Client();

  final http.Client _http;

  static const _authorizeHost = 'accounts.spotify.com';
  static const _tokenUri = 'https://accounts.spotify.com/api/token';
  static const _scope =
      'user-read-currently-playing user-modify-playback-state';

  Future<SpotifyTokenResponseDto> authenticate(
    SpotifyAuthConfig config,
  ) async {
    final verifier = SpotifyPkceHelper.generateCodeVerifier();
    final challenge = SpotifyPkceHelper.generateCodeChallenge(verifier);
    final state = SpotifyPkceHelper.generateState();

    final authorizeUri = Uri.https(_authorizeHost, '/authorize', {
      'client_id': config.clientId,
      'response_type': 'code',
      'redirect_uri': config.redirectUri,
      'code_challenge_method': 'S256',
      'code_challenge': challenge,
      'scope': _scope,
      'state': state,
    });

    final String resultUrl;
    try {
      resultUrl = await FlutterWebAuth2.authenticate(
        url: authorizeUri.toString(),
        // Unused on web (matching happens via same-origin postMessage from
        // web/auth.html), but the package still validates this looks like a
        // URL scheme.
        callbackUrlScheme: 'https',
      );
    } catch (_) {
      throw const SpotifyAuthCancelledFailure();
    }

    final params = Uri.parse(resultUrl).queryParameters;
    if (params['error'] != null) throw const SpotifyAuthCancelledFailure();
    final code = params['code'];
    if (code == null || params['state'] != state) {
      throw const SpotifyUnexpectedFailure('Ungültige Antwort von Spotify.');
    }

    return _exchangeCodeForTokens(config, code, verifier);
  }

  Future<SpotifyTokenResponseDto> _exchangeCodeForTokens(
    SpotifyAuthConfig config,
    String code,
    String verifier,
  ) => _requestToken({
    'grant_type': 'authorization_code',
    'code': code,
    'redirect_uri': config.redirectUri,
    'client_id': config.clientId,
    'code_verifier': verifier,
  });

  Future<SpotifyTokenResponseDto> refreshAccessToken(
    SpotifyAuthConfig config,
    String refreshToken,
  ) => _requestToken({
    'grant_type': 'refresh_token',
    'refresh_token': refreshToken,
    'client_id': config.clientId,
  });

  Future<SpotifyTokenResponseDto> _requestToken(
    Map<String, String> body,
  ) async {
    final response = await _http
        .post(
          Uri.parse(_tokenUri),
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          body: body,
        )
        .timeout(const Duration(seconds: 10));
    if (response.statusCode == 401 || response.statusCode == 400) {
      throw const SpotifyUnauthenticatedFailure();
    }
    if (response.statusCode != 200) {
      throw SpotifyUnexpectedFailure('HTTP ${response.statusCode}');
    }
    return SpotifyTokenResponseDto.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}
