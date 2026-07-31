import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

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

  /// Raw readings as recorded per day (device id -> whatever
  /// `SmartHomeDevice.dailyKwh` was at the time). For a cumulative device
  /// (lifetime meter, see [SmartHomeDevice.dailyKwhIsCumulative]) this is
  /// NOT that day's consumption yet — [_consumptionOn] diffs consecutive
  /// days to get the actual usage.
  Map<DateTime, Map<String, double>> _history = {};
  DateTime? _lastRecordedAt;

  /// Memoizes [data] so the (week/month history + device-usage sort)
  /// aggregation runs once per actual data change instead of once per
  /// widget that reads `EnergyScope.of(context).data` in the same frame.
  /// Invalidated (set to `null`) wherever `_devices`/`_history`/
  /// `pricePerKwh` change.
  EnergyDashboardData? _cachedData;

  Future<void> start() async {
    pricePerKwh = await _repository.loadPricePerKwh();
    _history = await _repository.loadHistory();
    _cachedData = null;
    notifyListeners();
  }

  Future<void> setPricePerKwh(double value) async {
    pricePerKwh = value;
    await _repository.savePricePerKwh(value);
    _cachedData = null;
    notifyListeners();
  }

  void selectPeriod(Period value) {
    if (period == value) return;
    period = value;
    notifyListeners();
  }

  /// Called whenever `SmartHomeBloc` emits a fresh device list. Recomputes
  /// the live totals and — throttled to at most once a minute, since the
  /// raw reading only ever grows or resets, never needs finer granularity —
  /// persists a snapshot so a day change (detected in
  /// `EnergyRepositoryImpl.recordReadings`) archives yesterday's last-known
  /// raw reading into history.
  void updateDevices(List<SmartHomeDevice> devices) {
    _devices = devices;
    _cachedData = null;
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

  SmartHomeDevice? _deviceById(String id) {
    for (final device in _devices) {
      if (device.id == id) return device;
    }
    return null;
  }

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
      _repository.recordReadings(_todayKey(), {
        for (final device in tracked) device.id: device.dailyKwh,
      }),
    );
  }

  DateTime _todayKey() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// That day's actual consumption for [device]'s raw [rawReading]. For a
  /// plain daily counter (already reset by Home Assistant), the raw reading
  /// IS the consumption. For a cumulative lifetime meter (most
  /// power-monitoring plugs, e.g. Shelly), it's the delta against
  /// [previousRaw] (the previous day's final raw reading) — clamped to the
  /// raw value itself if the meter went backwards (device replaced/reset)
  /// and to 0 if there's no previous reading yet (first day ever tracked).
  double _consumption({
    required bool isCumulative,
    required double rawReading,
    required double? previousRaw,
  }) {
    if (!isCumulative) return rawReading;
    if (previousRaw == null) return 0;
    final delta = rawReading - previousRaw;
    return delta < 0 ? rawReading : delta;
  }

  double _todayConsumptionFor(SmartHomeDevice device) {
    final yesterday = _todayKey().subtract(const Duration(days: 1));
    return _consumption(
      isCumulative: device.dailyKwhIsCumulative,
      rawReading: device.dailyKwh,
      previousRaw: _history[yesterday]?[device.id],
    );
  }

  double get todayKwh => _trackedDevices.fold(
    0.0,
    (sum, device) => sum + _todayConsumptionFor(device),
  );

  double get currentPowerWatts =>
      _trackedDevices.fold(0.0, (sum, device) => sum + device.powerWatts);

  double? get todayCostEuro =>
      pricePerKwh == null ? null : todayKwh * pricePerKwh!;

  double? get yesterdayKwh {
    final yesterday = _todayKey().subtract(const Duration(days: 1));
    if (!_history.containsKey(yesterday)) return null;
    return _consumptionOnArchivedDay(yesterday);
  }

  /// Total consumption on an archived (non-today) [day] — sums each
  /// device's raw reading for [day] diffed against the previous day's raw
  /// reading when that device is (or, if no longer live, was last known to
  /// be) a cumulative meter.
  double _consumptionOnArchivedDay(DateTime day) {
    final readings = _history[day];
    if (readings == null) return 0.0;
    final previousDay = day.subtract(const Duration(days: 1));
    final previousReadings = _history[previousDay];
    var total = 0.0;
    for (final entry in readings.entries) {
      final device = _deviceById(entry.key);
      total += _consumption(
        isCumulative: device?.dailyKwhIsCumulative ?? false,
        rawReading: entry.value,
        previousRaw: previousReadings?[entry.key],
      );
    }
    return total;
  }

  EnergyDashboardData get data => _cachedData ??= _computeData();

  EnergyDashboardData _computeData() {
    final tracked = _trackedDevices;
    final total = todayKwh;
    final deviceUsages = [
      for (final device in tracked)
        DeviceUsage(
          name: device.name,
          kwh: _todayConsumptionFor(device),
          share: total <= 0
              ? 0
              : ((_todayConsumptionFor(device) / total) * 100).round(),
          icon: device.type.icon,
          color: device.type.color,
        ),
    ]..sort((a, b) => b.kwh.compareTo(a.kwh));

    return EnergyDashboardData(
      hourly: [EnergyPoint('Heute', total, 0)],
      week: _historyPoints(7, (day) => _weekdayLabels[day.weekday - 1]),
      month: _historyPoints(30, (day) => '${day.day}'),
      deviceUsages: deviceUsages,
    );
  }

  List<EnergyPoint> _historyPoints(int days, String Function(DateTime) label) {
    final today = _todayKey();
    return [
      for (var i = days - 1; i >= 0; i--)
        _pointFor(today.subtract(Duration(days: i)), today, label),
    ];
  }

  EnergyPoint _pointFor(
    DateTime day,
    DateTime today,
    String Function(DateTime) label,
  ) => EnergyPoint(
    label(day),
    day == today ? todayKwh : _consumptionOnArchivedDay(day),
    0,
  );
}

/// Backed by `ChangeNotifierProvider` (not a raw `InheritedNotifier`) so
/// consumers can use `context.select` to react to just the field they
/// read (e.g. the period selector in the app shell) instead of rebuilding
/// on every device tick. Widgets that only need to call a method (no
/// rebuild) should use [of], which reads without subscribing.
class EnergyScope extends StatelessWidget {
  const EnergyScope({required this.controller, required this.child, super.key});

  final EnergyDashboardController controller;
  final Widget child;

  static EnergyDashboardController of(BuildContext context) =>
      context.read<EnergyDashboardController>();

  @override
  Widget build(BuildContext context) =>
      ChangeNotifierProvider<EnergyDashboardController>.value(
        value: controller,
        child: child,
      );
}
