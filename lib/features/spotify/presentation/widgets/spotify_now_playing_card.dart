import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../home/presentation/widgets/home_card.dart';
import '../../application/spotify_bloc.dart';
import '../../application/spotify_event.dart';
import '../../application/spotify_state.dart';
import '../../domain/entities/spotify_now_playing.dart';

class SpotifyNowPlayingCard extends StatelessWidget {
  const SpotifyNowPlayingCard({super.key});

  @override
  Widget build(BuildContext context) => HomeCard(
    child: BlocBuilder<SpotifyBloc, SpotifyState>(
      builder: (context, state) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          HomeCardTitle(
            icon: Icons.music_note_rounded,
            title: 'Spotify',
            trailing: switch (state) {
              SpotifyPlaying(:final nowPlaying) =>
                nowPlaying.isPlaying ? 'Läuft gerade' : 'Pausiert',
              _ => 'Live',
            },
          ),
          const SizedBox(height: 16),
          switch (state) {
            SpotifyInitial() || SpotifyAuthenticating() =>
              const _SpotifyLoading(),
            SpotifyUnauthenticated() => const _SpotifyConnectPrompt(),
            SpotifyIdle() => const Text(
              'Nichts wird abgespielt',
              style: TextStyle(color: AppColors.muted),
            ),
            SpotifyError() => const Text(
              'Spotify ist derzeit nicht erreichbar.',
              style: TextStyle(color: AppColors.muted),
            ),
            SpotifyPlaying(:final nowPlaying) => _SpotifyTrackView(
              nowPlaying: nowPlaying,
            ),
          },
        ],
      ),
    ),
  );
}

class _SpotifyLoading extends StatelessWidget {
  const _SpotifyLoading();

  @override
  Widget build(BuildContext context) => const Center(
    child: Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    ),
  );
}

class _SpotifyConnectPrompt extends StatelessWidget {
  const _SpotifyConnectPrompt();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Nicht mit Spotify verbunden.',
        style: TextStyle(color: AppColors.muted),
      ),
      const SizedBox(height: 12),
      OutlinedButton(
        onPressed: () => context.read<SpotifyBloc>().add(
          const SpotifyLoginRequested(),
        ),
        child: const Text('Mit Spotify verbinden'),
      ),
    ],
  );
}

class _SpotifyTrackView extends StatelessWidget {
  const _SpotifyTrackView({required this.nowPlaying});

  final SpotifyNowPlaying nowPlaying;

  @override
  Widget build(BuildContext context) {
    final track = nowPlaying.track;
    final progress = track.durationMs == 0
        ? 0.0
        : (nowPlaying.progressMs / track.durationMs).clamp(0.0, 1.0);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: track.albumArtUrl == null
              ? Container(
                  width: 56,
                  height: 56,
                  color: AppColors.blue.withOpacity(.15),
                  child: const Icon(
                    Icons.album_rounded,
                    color: AppColors.blueDark,
                  ),
                )
              : Image.network(
                  track.albumArtUrl!,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                track.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              Text(
                track.artistsLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.muted, fontSize: 12),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 4,
                  backgroundColor: AppColors.blue.withOpacity(.15),
                  valueColor: const AlwaysStoppedAnimation(AppColors.blueDark),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
