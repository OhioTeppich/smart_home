import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../home/presentation/widgets/home_card.dart';
import '../../application/spotify_bloc.dart';
import '../../application/spotify_event.dart';
import '../../application/spotify_state.dart';
import '../../domain/entities/spotify_now_playing.dart';
import '../../domain/entities/spotify_playback_command.dart';
import '../../domain/failures/spotify_failure.dart';

class SpotifyNowPlayingCard extends StatelessWidget {
  const SpotifyNowPlayingCard({super.key});

  @override
  Widget build(BuildContext context) => HomeCard(
    child: BlocBuilder<SpotifyBloc, SpotifyState>(
      builder: (context, state) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          const SizedBox(height: 8),
          Expanded(
            child: switch (state) {
              SpotifyInitial() || SpotifyAuthenticating() =>
                const _SpotifyLoading(),
              SpotifyUnauthenticated() => const _SpotifyConnectPrompt(),
              SpotifyIdle(:final commandError) =>
                _SpotifyEmptyState(commandError: commandError),
              SpotifyError() => const Center(
                child: Text(
                  'Spotify ist derzeit nicht erreichbar.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.muted),
                ),
              ),
              SpotifyPlaying(:final nowPlaying, :final commandError) =>
                _SpotifyTrackView(
                  nowPlaying: nowPlaying,
                  commandError: commandError,
                ),
            },
          ),
        ],
      ),
    ),
  );
}

class _SpotifyLoading extends StatelessWidget {
  const _SpotifyLoading();

  @override
  Widget build(BuildContext context) => const Center(
    child: SizedBox(
      width: 28,
      height: 28,
      child: CircularProgressIndicator(strokeWidth: 2.5),
    ),
  );
}

class _SpotifyEmptyState extends StatelessWidget {
  const _SpotifyEmptyState({this.commandError});

  final SpotifyFailure? commandError;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.music_off_rounded, size: 40, color: AppColors.muted),
        const SizedBox(height: 12),
        const Text(
          'Gerade läuft nichts',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () => context.read<SpotifyBloc>().add(
            const SpotifyPlayHereRequested(),
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: const Text('Hier abspielen', style: TextStyle(fontSize: 14)),
        ),
        if (commandError != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              commandError!.message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted, fontSize: 12),
            ),
          ),
      ],
    ),
  );
}

class _SpotifyConnectPrompt extends StatelessWidget {
  const _SpotifyConnectPrompt();

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.music_note_rounded,
          size: 40,
          color: AppColors.muted,
        ),
        const SizedBox(height: 12),
        const Text(
          'Nicht mit Spotify verbunden',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () => context.read<SpotifyBloc>().add(
            const SpotifyLoginRequested(),
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: const Text(
            'Mit Spotify verbinden',
            style: TextStyle(fontSize: 14),
          ),
        ),
      ],
    ),
  );
}

class _SpotifyTrackView extends StatelessWidget {
  const _SpotifyTrackView({required this.nowPlaying, this.commandError});

  final SpotifyNowPlaying nowPlaying;
  final SpotifyFailure? commandError;

  @override
  Widget build(BuildContext context) {
    final track = nowPlaying.track;
    final progress = track.durationMs == 0
        ? 0.0
        : (nowPlaying.progressMs / track.durationMs).clamp(0.0, 1.0);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: track.albumArtUrl == null
              ? Container(
                  width: 128,
                  height: 128,
                  color: AppColors.blue.withOpacity(.15),
                  child: const Icon(
                    Icons.album_rounded,
                    size: 48,
                    color: AppColors.blueDark,
                  ),
                )
              : Image.network(
                  track.albumArtUrl!,
                  width: 128,
                  height: 128,
                  fit: BoxFit.cover,
                ),
        ),
        const SizedBox(height: 16),
        Text(
          track.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        ),
        const SizedBox(height: 4),
        Text(
          track.artistsLabel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.muted, fontSize: 13),
        ),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 5,
            backgroundColor: AppColors.blue.withOpacity(.15),
            valueColor: const AlwaysStoppedAnimation(AppColors.blueDark),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SpotifyControlButton(
              icon: Icons.skip_previous_rounded,
              size: 28,
              onPressed: () => context.read<SpotifyBloc>().add(
                const SpotifyPlaybackCommandRequested(
                  SpotifyPlaybackCommand.skipPrevious,
                ),
              ),
            ),
            const SizedBox(width: 8),
            _SpotifyControlButton(
              icon: nowPlaying.isPlaying
                  ? Icons.pause_circle_filled_rounded
                  : Icons.play_circle_fill_rounded,
              size: 44,
              onPressed: () => context.read<SpotifyBloc>().add(
                SpotifyPlaybackCommandRequested(
                  nowPlaying.isPlaying
                      ? SpotifyPlaybackCommand.pause
                      : SpotifyPlaybackCommand.play,
                ),
              ),
            ),
            const SizedBox(width: 8),
            _SpotifyControlButton(
              icon: Icons.skip_next_rounded,
              size: 28,
              onPressed: () => context.read<SpotifyBloc>().add(
                const SpotifyPlaybackCommandRequested(
                  SpotifyPlaybackCommand.skipNext,
                ),
              ),
            ),
          ],
        ),
        if (nowPlaying.volumePercent != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _SpotifyControlButton(
                  icon: Icons.volume_down_rounded,
                  size: 22,
                  onPressed: () => context.read<SpotifyBloc>().add(
                    const SpotifyVolumeChangeRequested(-10),
                  ),
                ),
                SizedBox(
                  width: 36,
                  child: Text(
                    '${nowPlaying.volumePercent}%',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ),
                _SpotifyControlButton(
                  icon: Icons.volume_up_rounded,
                  size: 22,
                  onPressed: () => context.read<SpotifyBloc>().add(
                    const SpotifyVolumeChangeRequested(10),
                  ),
                ),
              ],
            ),
          ),
        if (commandError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              commandError!.message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted, fontSize: 12),
            ),
          ),
      ],
    );
  }
}

class _SpotifyControlButton extends StatelessWidget {
  const _SpotifyControlButton({
    required this.icon,
    required this.onPressed,
    this.size = 24,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final double size;

  @override
  Widget build(BuildContext context) => IconButton(
    onPressed: onPressed,
    icon: Icon(icon, color: AppColors.blueDark, size: size),
    visualDensity: VisualDensity.compact,
  );
}
