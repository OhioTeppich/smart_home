/// Non-web fallback (e.g. `flutter test`'s VM runner, or a future
/// mobile build) so this file compiles outside a browser. `ensureConnected`
/// is never actually invoked here: [SpotifyRepositoryImpl.playOnThisDevice]
/// is only reachable via UI a user taps in the running (web) app.
class SpotifyWebPlaybackSdk {
  SpotifyWebPlaybackSdk({required Future<String> Function() getAccessToken});

  Future<String> ensureConnected() => throw UnsupportedError(
    'Spotify Web Playback SDK is only available on the web target.',
  );
}
