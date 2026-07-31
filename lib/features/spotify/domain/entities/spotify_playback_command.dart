/// A read-write playback control command sent to `/me/player/...`.
/// Requires the `user-modify-playback-state` scope, unlike the rest of this
/// feature which only reads currently-playing state.
enum SpotifyPlaybackCommand { play, pause, skipNext, skipPrevious }
