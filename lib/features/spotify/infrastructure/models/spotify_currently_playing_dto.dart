import '../../domain/entities/spotify_now_playing.dart';

class SpotifyCurrentlyPlayingDto {
  const SpotifyCurrentlyPlayingDto({
    required this.isPlaying,
    required this.progressMs,
    required this.trackName,
    required this.artistNames,
    required this.albumName,
    required this.albumArtUrl,
    required this.durationMs,
  });

  /// Returns `null` when the payload has no playable `item` (e.g. an ad, a
  /// local file, or a podcast episode without a track object) — treated the
  /// same as "nothing playing" upstream rather than as an error.
  static SpotifyCurrentlyPlayingDto? fromJson(Map<String, dynamic> json) {
    final item = json['item'] as Map<String, dynamic>?;
    if (item == null) return null;
    final album = item['album'] as Map<String, dynamic>?;
    final images = (album?['images'] as List?) ?? const [];
    final artists = (item['artists'] as List?) ?? const [];
    return SpotifyCurrentlyPlayingDto(
      isPlaying: json['is_playing'] as bool? ?? false,
      progressMs: (json['progress_ms'] as num?)?.toInt() ?? 0,
      trackName: item['name'] as String? ?? '',
      artistNames: artists
          .map((artist) => (artist as Map<String, dynamic>)['name'] as String)
          .toList(),
      albumName: album?['name'] as String? ?? '',
      albumArtUrl: images.isEmpty
          ? null
          : (images.first as Map<String, dynamic>)['url'] as String?,
      durationMs: (item['duration_ms'] as num?)?.toInt() ?? 0,
    );
  }

  final bool isPlaying;
  final int progressMs;
  final String trackName;
  final List<String> artistNames;
  final String albumName;
  final String? albumArtUrl;
  final int durationMs;

  SpotifyNowPlaying toDomain() => SpotifyNowPlaying(
    track: SpotifyTrack(
      name: trackName,
      artistNames: artistNames,
      albumName: albumName,
      albumArtUrl: albumArtUrl,
      durationMs: durationMs,
    ),
    isPlaying: isPlaying,
    progressMs: progressMs,
  );
}
