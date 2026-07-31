import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_card.dart';

class ComparisonCard extends StatelessWidget {
  const ComparisonCard({super.key});
  @override
  Widget build(BuildContext context) => GlassCard(
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vergleich',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        SizedBox(height: 17),
        Text(
          'Gestern                         - 0,47 kWh',
          style: TextStyle(color: AppColors.muted, fontSize: 12),
        ),
        SizedBox(height: 13),
        Text(
          '7-Tage-Schnitt              + 0,68 kWh',
          style: TextStyle(color: AppColors.muted, fontSize: 12),
        ),
      ],
    ),
  );
}

class GoalCard extends StatelessWidget {
  const GoalCard({super.key});
  @override
  Widget build(BuildContext context) => GlassCard(
    child: const Row(
      children: [
        Icon(Icons.track_changes_rounded, color: AppColors.blueDark, size: 34),
        SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tagesziel',
                style: TextStyle(color: AppColors.muted, fontSize: 12),
              ),
              SizedBox(height: 5),
              Text(
                '73 % erreicht',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class PeakCard extends StatelessWidget {
  const PeakCard({super.key});
  @override
  Widget build(BuildContext context) => GlassCard(
    child: const Row(
      children: [
        Icon(Icons.trending_up_rounded, color: AppColors.brown),
        SizedBox(width: 14),
        Expanded(
          child: Text(
            'Höchste Lastspitze  ·  980 W',
            style: TextStyle(fontWeight: FontWeight.w800),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}

class ForecastCard extends StatelessWidget {
  const ForecastCard({super.key});
  @override
  Widget build(BuildContext context) => GlassCard(
    child: const Row(
      children: [
        Icon(Icons.auto_graph_rounded, color: AppColors.brown),
        SizedBox(width: 14),
        Expanded(
          child: Text(
            'Monatsprognose  ·  58,40 €',
            style: TextStyle(fontWeight: FontWeight.w800),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}

class TimeOfDayCard extends StatelessWidget {
  const TimeOfDayCard({super.key});
  @override
  Widget build(BuildContext context) => GlassCard(
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Verbrauch nach Tageszeit',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        SizedBox(height: 17),
        Text('Morgen       18 %'),
        SizedBox(height: 13),
        Text('Tag             31 %'),
        SizedBox(height: 13),
        Text('Abend        39 %'),
        SizedBox(height: 13),
        Text('Nacht         12 %'),
      ],
    ),
  );
}
