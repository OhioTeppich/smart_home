import 'package:flutter/material.dart';

import 'markets_card.dart';
import 'top_devices_card.dart';
import 'weather_card.dart';

class HomeOverview extends StatelessWidget {
  const HomeOverview({required this.compact, super.key});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return compact
        ? const Column(
            children: [
              WeatherCard(),
              SizedBox(height: 14),
              MarketsCard(),
              SizedBox(height: 14),
              TopDevicesCard(),
            ],
          )
        : SizedBox(
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
}
