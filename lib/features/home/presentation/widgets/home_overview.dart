import 'package:flutter/material.dart';

import 'markets_card.dart';
import 'top_devices_card.dart';
import 'weather_card.dart';

/// Wide-screen layout: weather, markets and top devices side by side.
/// On narrow screens each card becomes its own horizontally swipeable
/// panel instead (see `HomePage`).
class HomeOverview extends StatelessWidget {
  const HomeOverview({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 300,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Expanded(flex: 5, child: WeatherCard()),
        const SizedBox(width: 14),
        const Expanded(flex: 5, child: MarketsCard()),
        const SizedBox(width: 14),
        const Expanded(flex: 4, child: TopDevicesCard()),
      ],
    ),
  );
}
