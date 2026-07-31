import 'package:flutter/material.dart';

import '../../../../core/widgets/horizontal_page_scaffold.dart';
import '../../../quick_access/presentation/widgets/quick_access_card.dart';
import '../../../spotify/presentation/widgets/spotify_now_playing_card.dart';
import '../widgets/home_overview.dart';
import '../widgets/markets_card.dart';
import '../widgets/weather_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 780;
    return HorizontalPageScaffold(
      sections: compact
          ? const [
              WeatherCard(),
              MarketsCard(),
              SpotifyNowPlayingCard(),
              QuickAccessCard(),
            ]
          : const [HomeOverview()],
    );
  }
}
