import 'package:flutter/material.dart';

import '../../../../core/widgets/horizontal_page_scaffold.dart';
import '../widgets/home_overview.dart';
import '../widgets/markets_card.dart';
import '../widgets/top_devices_card.dart';
import '../widgets/weather_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 780;
    return HorizontalPageScaffold(
      sections: compact
          ? const [WeatherCard(), MarketsCard(), TopDevicesCard()]
          : const [HomeOverview()],
    );
  }
}
