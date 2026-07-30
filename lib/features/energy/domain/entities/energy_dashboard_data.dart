import 'device_usage.dart';
import 'energy_point.dart';

class EnergyDashboardData {
  const EnergyDashboardData({
    required this.hourly,
    required this.week,
    required this.month,
    required this.deviceUsages,
  });

  final List<EnergyPoint> hourly;
  final List<EnergyPoint> week;
  final List<EnergyPoint> month;
  final List<DeviceUsage> deviceUsages;
}
