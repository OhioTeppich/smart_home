import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../application/energy_dashboard_controller.dart';
import '../../domain/entities/energy_point.dart';

class ChartCard extends StatelessWidget {
  const ChartCard({
    required this.period,
    required this.onDetails,
    this.showDetails = true,
    super.key,
  });
  final Period period;
  final VoidCallback onDetails;
  final bool showDetails;

  @override
  Widget build(BuildContext context) {
    final data = context.watch<EnergyDashboardController>().data;
    final points = switch (period) {
      Period.day => data.hourly,
      Period.week => data.week,
      Period.month => data.month,
    };
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Verbrauchsverlauf',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Kilowattstunden',
                      style: TextStyle(fontSize: 12, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              if (showDetails)
                TextButton(
                  onPressed: onDetails,
                  child: const Text(
                    'Details  →',
                    style: TextStyle(
                      color: AppColors.blueDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 22),
          SizedBox(
            height: 220,
            child: CustomPaint(
              painter: EnergyChartPainter(
                points: points,
                highlightIndex: points.length - 1,
              ),
              child: const SizedBox.expand(),
            ),
          ),
        ],
      ),
    );
  }
}

class EnergyChartPainter extends CustomPainter {
  EnergyChartPainter({required this.points, required this.highlightIndex});
  final List<EnergyPoint> points;
  final int highlightIndex;

  @override
  void paint(Canvas canvas, Size size) {
    const left = 34.0, bottom = 27.0;
    final chartWidth = size.width - left - 6;
    final chartHeight = size.height - bottom - 8;
    final maxKwh = points.map((point) => point.kwh).reduce(math.max);
    final max = maxKwh <= 0 ? 1.0 : maxKwh * 1.25;
    final gridPaint = Paint()
      ..color = AppColors.line
      ..strokeWidth = 1;
    for (var i = 0; i < 4; i++) {
      final y = 8 + chartHeight * i / 3;
      canvas.drawLine(Offset(left, y), Offset(size.width, y), gridPaint);
    }
    final gap = chartWidth / points.length;
    for (var i = 0; i < points.length; i++) {
      final point = points[i];
      final barHeight = chartHeight * point.kwh / max;
      final x = left + gap * i + gap * .22;
      final barWidth = gap * .56;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, 8 + chartHeight - barHeight, barWidth, barHeight),
        const Radius.circular(6),
      );
      canvas.drawRRect(
        rect,
        Paint()..color = i == highlightIndex ? AppColors.ink : AppColors.blue,
      );
      final painter = TextPainter(
        text: TextSpan(
          text: point.label,
          style: const TextStyle(color: AppColors.muted, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(canvas, Offset(x + barWidth / 2 - 8, size.height - 17));
    }
  }

  @override
  bool shouldRepaint(covariant EnergyChartPainter oldDelegate) =>
      oldDelegate.points != points ||
      oldDelegate.highlightIndex != highlightIndex;
}
