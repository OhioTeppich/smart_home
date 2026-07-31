import 'package:flutter/material.dart';

import '../../../quick_access/presentation/widgets/quick_access_card.dart';
import 'markets_card.dart';
import 'weather_card.dart';

/// Wide-screen layout: weather and markets side by side, with the
/// Schnellzugriff widget in its own full-width row below. On narrow screens
/// each card becomes its own horizontally swipeable panel instead (see
/// `HomePage`).
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
          ],
        ),
      ),
      const SizedBox(height: 14),
      const SizedBox(height: 96, child: QuickAccessCard()),
    ],
  );
}
