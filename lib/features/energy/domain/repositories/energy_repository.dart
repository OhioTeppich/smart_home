abstract interface class EnergyRepository {
  Future<double?> loadPricePerKwh();
  Future<void> savePricePerKwh(double value);

  /// Records the readings (device id -> kWh consumed today so far) for
  /// [day]. Implementations detect a day change from the previously
  /// recorded day and archive it into history before storing the new one.
  Future<void> recordReadings(DateTime day, Map<String, double> kwhByDeviceId);

  /// Archived, complete days only — never includes the day currently being
  /// recorded via [recordReadings].
  Future<Map<DateTime, Map<String, double>>> loadHistory();
}
