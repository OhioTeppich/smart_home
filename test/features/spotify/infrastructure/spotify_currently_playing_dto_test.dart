import 'package:flutter_test/flutter_test.dart';
import 'package:smart_home/features/spotify/infrastructure/models/spotify_currently_playing_dto.dart';

void main() {
  test('fromJson maps a full currently-playing payload', () {
    final dto = SpotifyCurrentlyPlayingDto.fromJson({
      'is_playing': true,
      'progress_ms': 12345,
      'item': {
        'name': 'Song Title',
        'duration_ms': 200000,
        'album': {
          'name': 'Album Name',
          'images': [
            {'url': 'https://example.com/big.jpg'},
            {'url': 'https://example.com/small.jpg'},
          ],
        },
        'artists': [
          {'name': 'Artist One'},
          {'name': 'Artist Two'},
        ],
      },
    });

    expect(dto, isNotNull);
    expect(dto!.isPlaying, isTrue);
    expect(dto.progressMs, 12345);
    expect(dto.trackName, 'Song Title');
    expect(dto.durationMs, 200000);
    expect(dto.albumName, 'Album Name');
    expect(dto.albumArtUrl, 'https://example.com/big.jpg');
    expect(dto.artistNames, ['Artist One', 'Artist Two']);

    final domain = dto.toDomain();
    expect(domain.track.artistsLabel, 'Artist One, Artist Two');
    expect(domain.isPlaying, isTrue);
    expect(domain.progressMs, 12345);
  });

  test('fromJson returns null when item is missing (ad/no track)', () {
    final dto = SpotifyCurrentlyPlayingDto.fromJson({
      'is_playing': false,
      'progress_ms': 0,
    });

    expect(dto, isNull);
  });

  test('fromJson defaults album art to null when no images present', () {
    final dto = SpotifyCurrentlyPlayingDto.fromJson({
      'is_playing': true,
      'progress_ms': 0,
      'item': {
        'name': 'Song',
        'duration_ms': 1000,
        'album': {'name': 'Album', 'images': <Map<String, dynamic>>[]},
        'artists': <Map<String, dynamic>>[],
      },
    });

    expect(dto, isNotNull);
    expect(dto!.albumArtUrl, isNull);
    expect(dto.artistNames, isEmpty);
  });
}
