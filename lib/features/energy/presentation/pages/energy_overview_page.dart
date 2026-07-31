import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/horizontal_page_scaffold.dart';
import '../../application/energy_dashboard_controller.dart';
import '../../domain/entities/energy_point.dart';
import '../widgets/energy_chart_widgets.dart';
import '../widgets/energy_metric_widgets.dart';
import 'energy_price_settings_page.dart';

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
    final controller = EnergyScope.of(context);
    final data = controller.data;
    final chart = ChartCard(period: period, onDetails: onDetails);

    final todayKwh = controller.todayKwh;
    final yesterdayKwh = controller.yesterdayKwh;
    final pricePerKwh = controller.pricePerKwh;
    final costEuro = controller.todayCostEuro;

    final kwhChange = yesterdayKwh == null
        ? 'Keine Vergleichsdaten'
        : _formatDelta(todayKwh - yesterdayKwh, 'kWh');
    final costChange = pricePerKwh == null
        ? 'Preis festlegen'
        : (yesterdayKwh == null
              ? 'Keine Vergleichsdaten'
              : _formatDelta((todayKwh - yesterdayKwh) * pricePerKwh, '€'));

    final metrics = Wrap(
      spacing: 14,
      runSpacing: 14,
      children: [
        MetricCard(
          title: 'Verbrauch heute',
          value: _formatNumber(todayKwh),
          unit: 'kWh',
          change: kwhChange,
          icon: Icons.bolt_rounded,
          color: AppColors.blue,
        ),
        GestureDetector(
          onTap: pricePerKwh == null
              ? () => Navigator.of(context).push<void>(
                  MaterialPageRoute(
                    builder: (_) => const EnergyPriceSettingsPage(),
                  ),
                )
              : null,
          child: MetricCard(
            title: 'Kosten heute',
            value: costEuro == null ? '–' : _formatNumber(costEuro),
            unit: '€',
            change: costChange,
            icon: Icons.euro_rounded,
            color: AppColors.peach,
          ),
        ),
        MetricCard(
          title: 'Aktuelle Leistung',
          value: controller.currentPowerWatts.round().toString(),
          unit: 'W',
          change: 'normal',
          icon: Icons.speed_rounded,
          color: AppColors.lavender,
        ),
        if (data.deviceUsages.isNotEmpty)
          DeviceUsageCard(
            label: 'Am meisten',
            device: data.deviceUsages.first,
            accent: AppColors.peach,
          ),
        if (data.deviceUsages.length > 1)
          DeviceUsageCard(
            label: 'Am wenigsten',
            device: data.deviceUsages.last,
            accent: AppColors.green,
          ),
        if (data.deviceUsages.isEmpty) const _NoDevicesCard(),
      ],
    );
    return HorizontalPageScaffold(sections: [metrics, chart]);
  }

  static String _formatNumber(double value) =>
      value.toStringAsFixed(2).replaceAll('.', ',');

  static String _formatDelta(double delta, String unit) =>
      '${delta >= 0 ? '+' : ''}${_formatNumber(delta)} $unit';
}

class _NoDevicesCard extends StatelessWidget {
  const _NoDevicesCard();

  @override
  Widget build(BuildContext context) => const SizedBox(
    width: 232,
    child: GlassCard(
      child: Text(
        'Keine Geräte mit Energiedaten gefunden.',
        style: TextStyle(color: AppColors.muted, fontSize: 12),
      ),
    ),
  );
}
