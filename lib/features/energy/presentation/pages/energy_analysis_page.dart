import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/energy_point.dart';
import '../widgets/energy_chart_widgets.dart';
import '../widgets/energy_metric_widgets.dart';
import '../widgets/energy_summary_widgets.dart';

class AnalysisPage extends StatelessWidget {
  const AnalysisPage({required this.period, this.onBack, super.key});
  final Period period;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(44, 32, 52, 42),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (onBack != null) ...[
          InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(8),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.arrow_back_rounded,
                    size: 18,
                    color: AppColors.blueDark,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Übersicht',
                    style: TextStyle(
                      color: AppColors.blueDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
        ],
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
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final stacked = constraints.maxWidth < 780;
            const side = Column(
              children: [
                SizedBox(height: 170, child: ComparisonCard()),
                SizedBox(height: 18),
                SizedBox(height: 154, child: GoalCard()),
              ],
            );
            return stacked
                ? const Column(
                    children: [PeakCard(), SizedBox(height: 18), side],
                  )
                : const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: PeakCard()),
                      SizedBox(width: 18),
                      Expanded(child: side),
                    ],
                  );
          },
        ),
      ],
    ),
  );
}
