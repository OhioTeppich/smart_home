import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class StoredCurrentDay {
  const StoredCurrentDay({required this.date, required this.readings});

  final String date;
  final Map<String, double> readings;
}

/// Thin key-value wrapper — no rollover/merge logic, that lives in
/// `EnergyRepositoryImpl`.
class EnergyLocalDataSource {
  static const _priceKey = 'energy_price_per_kwh';
  static const _historyDaysKey = 'energy_history_days';
  static const _currentDayKey = 'energy_history_current';

  Future<double?> readPricePerKwh() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_priceKey);
  }

  Future<void> writePricePerKwh(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_priceKey, value);
  }

  Future<Map<String, Map<String, double>>> readHistoryDays() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_historyDaysKey);
    if (raw == null) return {};
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map(
      (date, readings) => MapEntry(
        date,
        (readings as Map<String, dynamic>).map(
          (id, kwh) => MapEntry(id, (kwh as num).toDouble()),
        ),
      ),
    );
  }

  Future<void> writeHistoryDays(Map<String, Map<String, double>> days) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_historyDaysKey, jsonEncode(days));
  }

  Future<StoredCurrentDay?> readCurrentDay() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_currentDayKey);
    if (raw == null) return null;
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final readings = (decoded['readings'] as Map<String, dynamic>).map(
      (id, kwh) => MapEntry(id, (kwh as num).toDouble()),
    );
    return StoredCurrentDay(date: decoded['date'] as String, readings: readings);
  }

  Future<void> writeCurrentDay(StoredCurrentDay current) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _currentDayKey,
      jsonEncode({'date': current.date, 'readings': current.readings}),
    );
  }
}
