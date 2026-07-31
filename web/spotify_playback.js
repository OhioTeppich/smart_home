// Bridges Dart (via dart:js_interop) to Spotify's Web Playback SDK, which
// registers this browser tab as a Spotify Connect device ("Smart Home
// Display") so playback can be started on it directly. Kept as plain JS
// rather than hand-written @JS() bindings for the whole Spotify.Player
// class, since the SDK's own API surface is easier to get right here (and
// to debug in the browser console) than to model in Dart interop.
window.smartHomeSpotify = {
  // getOAuthTokenAsync: () => Promise<string access token>
  // Resolves with the Spotify Connect device_id once the player is ready,
  // or rejects with an error message string.
  connect: function (getOAuthTokenAsync) {
    if (window._smartHomeSpotifyConnectPromise) {
      return window._smartHomeSpotifyConnectPromise;
    }
    window._smartHomeSpotifyConnectPromise = new Promise(function (resolve, reject) {
      function init() {
        var player = new Spotify.Player({
          name: 'Smart Home Display',
          getOAuthToken: function (callback) {
            getOAuthTokenAsync().then(callback);
          },
          volume: 0.5,
        });

        player.addListener('ready', function (event) {
          resolve(event.device_id);
        });
        player.addListener('initialization_error', function (event) {
          reject(event.message);
        });
        player.addListener('authentication_error', function (event) {
          reject(event.message);
        });
        player.addListener('account_error', function (event) {
          reject(event.message);
        });

        player.connect();
        window._smartHomeSpotifyPlayer = player;
      }

      if (window.Spotify) {
        init();
      } else {
        window.onSpotifyWebPlaybackSDKReady = init;
      }
    });
    return window._smartHomeSpotifyConnectPromise;
  },
};
