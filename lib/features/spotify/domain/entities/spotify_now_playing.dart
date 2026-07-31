import 'package:equatable/equatable.dart';

class SpotifyTrack extends Equatable {
  const SpotifyTrack({
    required this.name,
    required this.artistNames,
    required this.albumName,
    required this.albumArtUrl,
    required this.durationMs,
  });

  final String name;
  final List<String> artistNames;
  final String albumName;
  final String? albumArtUrl;
  final int durationMs;

  String get artistsLabel => artistNames.join(', ');

  @override
  List<Object?> get props => [
    name,
    artistNames,
    albumName,
    albumArtUrl,
    durationMs,
  ];
}

class SpotifyNowPlaying extends Equatable {
  const SpotifyNowPlaying({
    required this.track,
    required this.isPlaying,
    required this.progressMs,
  });

  final SpotifyTrack track;
  final bool isPlaying;
  final int progressMs;

  @override
  List<Object?> get props => [track, isPlaying, progressMs];
}
