import 'package:flutter/material.dart';

import '../../../parcel_tracking/presentation/widgets/parcel_tracking_card.dart';
import '../../../quick_access/presentation/widgets/quick_access_card.dart';
import '../../../spotify/presentation/widgets/spotify_now_playing_card.dart';
import 'markets_card.dart';
import 'weather_card.dart';

/// Wide-screen layout: weather, markets and Spotify side by side, with
/// Paket-Tracking and Schnellzugriff sharing the row below. On narrow
/// screens each card becomes its own horizontally swipeable panel instead
/// (see `HomePage`). Spotify gets a fixed width rather than `Expanded` so
/// the existing Wetter/Märkte columns stay pixel-identical to before.
class HomeOverview extends StatelessWidget {
  const HomeOverview({super.key});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      SizedBox(
        height: 300,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            Expanded(child: WeatherCard()),
            SizedBox(width: 14),
            Expanded(child: MarketsCard()),
            SizedBox(width: 14),
            SizedBox(width: 320, child: SpotifyNowPlayingCard()),
          ],
        ),
      ),
      const SizedBox(height: 14),
      SizedBox(
        height: 220,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            Expanded(child: ParcelTrackingCard()),
            SizedBox(width: 14),
            Expanded(child: QuickAccessCard()),
          ],
        ),
      ),
    ],
  );
}
