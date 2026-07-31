import 'dart:async';
import 'dart:js_interop';

@JS('smartHomeSpotify.connect')
external JSPromise<JSString> _connect(JSFunction getOAuthTokenAsync);

/// Bridges to the Spotify Web Playback SDK loaded in `web/index.html` (via
/// `web/spotify_playback.js`), registering this browser tab as a Spotify
/// Connect device so playback can be started on it directly. Web-only —
/// this feature isn't wired up for the (currently unused) mobile targets.
class SpotifyWebPlaybackSdk {
  SpotifyWebPlaybackSdk({required Future<String> Function() getAccessToken})
    : _getAccessToken = getAccessToken;

  final Future<String> Function() _getAccessToken;
  String? _deviceId;
  Future<String>? _connecting;

  /// Connects the player (idempotent — a second call while connecting, or
  /// once connected, reuses the same result) and resolves with the Spotify
  /// Connect device id once ready.
  Future<String> ensureConnected() {
    final existing = _deviceId;
    if (existing != null) return Future.value(existing);
    return _connecting ??= _connect(_tokenProvider).toDart
        .then((jsId) => _deviceId = jsId.toDart)
        .catchError((Object error) {
          _connecting = null;
          throw StateError(
            'Spotify-Player konnte nicht verbunden werden ($error).',
          );
        });
  }

  JSFunction get _tokenProvider => (() {
    final tokenPromise = _getAccessToken().then((token) => token.toJS);
    return tokenPromise.toJS;
  }).toJS;
}
