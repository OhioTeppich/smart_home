import 'package:flutter/material.dart';

import '../../domain/entities/energy_point.dart';
import '../widgets/energy_chart_widgets.dart';
import '../widgets/energy_metric_widgets.dart';
import '../widgets/energy_summary_widgets.dart';

class AnalysisPage extends StatelessWidget {
  const AnalysisPage({required this.period, super.key});
  final Period period;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(44, 32, 52, 42),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final stacked = constraints.maxWidth < 780;
            final chart = ChartCard(
              period: period,
              showDetails: false,
              onDetails: () {},
            );
            const list = DeviceUsageListCard(fixedHeight: 360);
            return stacked
                ? Column(children: [chart, const SizedBox(height: 18), list])
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: chart),
                      const SizedBox(width: 18),
                      const Expanded(
                        child: DeviceUsageListCard(fixedHeight: 360),
                      ),
                    ],
                  );
          },
        ),
        const SizedBox(height: 18),
        const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: TimeOfDayCard()),
            SizedBox(width: 18),
            Expanded(child: ForecastCard()),
          ],
        ),
      ],
    ),
  );
}
