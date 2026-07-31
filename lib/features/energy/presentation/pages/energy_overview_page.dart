import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../application/energy_dashboard_controller.dart';
import '../../domain/entities/energy_point.dart';
import '../widgets/energy_chart_widgets.dart';
import '../widgets/energy_metric_widgets.dart';

class OverviewPage extends StatelessWidget {
  const OverviewPage({
    required this.compact,
    required this.period,
    required this.onDetails,
    super.key,
  });
  final bool compact;
  final Period period;
  final VoidCallback onDetails;

  @override
  Widget build(BuildContext context) {
    final data = EnergyScope.of(context).data;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        compact ? 24 : 44,
        32,
        compact ? 24 : 52,
        42,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              final stacked = constraints.maxWidth < 780;
              final chart = ChartCard(period: period, onDetails: onDetails);
              final widgets = Wrap(
                spacing: 14,
                runSpacing: 14,
                children: [
                  const MetricCard(
                    title: 'Verbrauch heute',
                    value: '6,14',
                    unit: 'kWh',
                    change: '+8,4 %',
                    icon: Icons.bolt_rounded,
                    color: AppColors.blue,
                  ),
                  const MetricCard(
                    title: 'Kosten heute',
                    value: '1,96',
                    unit: '€',
                    change: '+0,21 €',
                    icon: Icons.euro_rounded,
                    color: AppColors.peach,
                  ),
                  const MetricCard(
                    title: 'Aktuelle Leistung',
                    value: '810',
                    unit: 'W',
                    change: 'normal',
                    icon: Icons.speed_rounded,
                    color: AppColors.lavender,
                  ),
                  DeviceUsageCard(
                    label: 'Am meisten',
                    device: data.deviceUsages.first,
                    accent: AppColors.peach,
                  ),
                  DeviceUsageCard(
                    label: 'Am wenigsten',
                    device: data.deviceUsages.last,
                    accent: AppColors.green,
                  ),
                ],
              );
              return stacked
                  ? Column(
                      children: [chart, const SizedBox(height: 18), widgets],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: chart),
                        const SizedBox(width: 18),
                        Expanded(child: widgets),
                      ],
                    );
            },
          ),
        ],
      ),
    );
  }
}
