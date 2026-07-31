import '../../domain/repositories/energy_repository.dart';
import '../data_sources/energy_local_data_source.dart';

class EnergyRepositoryImpl implements EnergyRepository {
  EnergyRepositoryImpl(this._dataSource);

  static const _maxHistoryDays = 90;

  final EnergyLocalDataSource _dataSource;

  @override
  Future<double?> loadPricePerKwh() => _dataSource.readPricePerKwh();

  @override
  Future<void> savePricePerKwh(double value) =>
      _dataSource.writePricePerKwh(value);

  @override
  Future<void> recordReadings(
    DateTime day,
    Map<String, double> kwhByDeviceId,
  ) async {
    final dayKey = _dateKey(day);
    final current = await _dataSource.readCurrentDay();

    if (current != null && current.date != dayKey) {
      final days = await _dataSource.readHistoryDays();
      final archived = {...days[current.date] ?? {}, ...current.readings};
      days[current.date] = archived;
      await _dataSource.writeHistoryDays(_pruned(days));
    }

    await _dataSource.writeCurrentDay(
      StoredCurrentDay(date: dayKey, readings: kwhByDeviceId),
    );
  }

  @override
  Future<Map<DateTime, Map<String, double>>> loadHistory() async {
    final days = await _dataSource.readHistoryDays();
    return days.map((dateKey, readings) => MapEntry(_parseKey(dateKey), readings));
  }

  Map<String, Map<String, double>> _pruned(
    Map<String, Map<String, double>> days,
  ) {
    if (days.length <= _maxHistoryDays) return days;
    final sortedKeys = days.keys.toList()
      ..sort((a, b) => _parseKey(b).compareTo(_parseKey(a)));
    final kept = sortedKeys.take(_maxHistoryDays).toSet();
    return {for (final key in days.keys) if (kept.contains(key)) key: days[key]!};
  }

  String _dateKey(DateTime day) =>
      '${day.year.toString().padLeft(4, '0')}-'
      '${day.month.toString().padLeft(2, '0')}-'
      '${day.day.toString().padLeft(2, '0')}';

  DateTime _parseKey(String key) {
    final parts = key.split('-');
    return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
  }
}
