import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../rooms/domain/entities/smart_home_device.dart';
import '../../rooms/presentation/widgets/smart_home_device_ui.dart';
import '../domain/entities/device_usage.dart';
import '../domain/entities/energy_dashboard_data.dart';
import '../domain/entities/energy_point.dart';
import '../domain/repositories/energy_repository.dart';

const _weekdayLabels = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];

class EnergyDashboardController extends ChangeNotifier {
  EnergyDashboardController(this._repository);

  final EnergyRepository _repository;

  Period period = Period.day;
  double? pricePerKwh;
  List<SmartHomeDevice> _devices = const [];
  Map<DateTime, Map<String, double>> _history = {};
  DateTime? _lastRecordedAt;

  Future<void> start() async {
    pricePerKwh = await _repository.loadPricePerKwh();
    _history = await _repository.loadHistory();
    notifyListeners();
  }

  Future<void> setPricePerKwh(double value) async {
    pricePerKwh = value;
    await _repository.savePricePerKwh(value);
    notifyListeners();
  }

  void selectPeriod(Period value) {
    if (period == value) return;
    period = value;
    notifyListeners();
  }

  /// Called whenever `SmartHomeBloc` emits a fresh device list. Recomputes
  /// the live totals and — throttled to at most once a minute, since Home
  /// Assistant's daily total only ever grows — persists a snapshot so a day
  /// change (detected in `EnergyRepositoryImpl.recordReadings`) archives
  /// yesterday's last-known value into history.
  void updateDevices(List<SmartHomeDevice> devices) {
    _devices = devices;
    notifyListeners();
    _maybeRecordReadings();
  }

  List<SmartHomeDevice> get _trackedDevices => _devices
      .where(
        (device) =>
            (device.powerWatts > 0 || device.dailyKwh > 0) &&
            device.status == 'Online',
      )
      .toList();

  void _maybeRecordReadings() {
    final now = DateTime.now();
    if (_lastRecordedAt != null &&
        now.difference(_lastRecordedAt!) < const Duration(seconds: 60)) {
      return;
    }
    final tracked = _trackedDevices;
    if (tracked.isEmpty) return;
    _lastRecordedAt = now;
    unawaited(
      _repository.recordReadings(DateTime(now.year, now.month, now.day), {
        for (final device in tracked) device.id: device.dailyKwh,
      }),
    );
  }

  double get todayKwh =>
      _trackedDevices.fold(0.0, (sum, device) => sum + device.dailyKwh);

  double get currentPowerWatts =>
      _trackedDevices.fold(0.0, (sum, device) => sum + device.powerWatts);

  double? get todayCostEuro =>
      pricePerKwh == null ? null : todayKwh * pricePerKwh!;

  double? get yesterdayKwh => _totalFor(
    DateTime.now().subtract(const Duration(days: 1)),
  );

  double? _totalFor(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    final readings = _history[key];
    if (readings == null) return null;
    return readings.values.fold<double>(0.0, (sum, kwh) => sum + kwh);
  }

  EnergyDashboardData get data {
    final tracked = _trackedDevices;
    final total = todayKwh;
    final deviceUsages =
        [
            for (final device in tracked)
              DeviceUsage(
                name: device.name,
                kwh: device.dailyKwh,
                share: total <= 0
                    ? 0
                    : ((device.dailyKwh / total) * 100).round(),
                icon: device.type.icon,
                color: device.type.color,
              ),
          ]
          ..sort((a, b) => b.kwh.compareTo(a.kwh));

    return EnergyDashboardData(
      hourly: [EnergyPoint('Heute', total, 0)],
      week: _historyPoints(7, (day) => _weekdayLabels[day.weekday - 1]),
      month: _historyPoints(30, (day) => '${day.day}'),
      deviceUsages: deviceUsages,
    );
  }

  List<EnergyPoint> _historyPoints(
    int days,
    String Function(DateTime) label,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return [
      for (var i = days - 1; i >= 0; i--)
        _pointFor(today.subtract(Duration(days: i)), today, label),
    ];
  }

  EnergyPoint _pointFor(
    DateTime day,
    DateTime today,
    String Function(DateTime) label,
  ) => EnergyPoint(label(day), day == today ? todayKwh : (_totalFor(day) ?? 0.0), 0);
}

class EnergyScope extends InheritedNotifier<EnergyDashboardController> {
  const EnergyScope({
    required EnergyDashboardController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static EnergyDashboardController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<EnergyScope>();
    assert(scope != null, 'EnergyScope is missing above this widget.');
    return scope!.notifier!;
  }
}
