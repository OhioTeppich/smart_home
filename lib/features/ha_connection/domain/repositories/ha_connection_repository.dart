import '../value_objects/ha_connection_config.dart';

abstract class HaConnectionRepository {
  Future<HaConnectionConfig?> loadConfig();
  Future<void> saveConfig(HaConnectionConfig config);
  Future<void> clearConfig();

  /// Throws an [HaConnectionFailure] subtype when [config] cannot reach
  /// Home Assistant. Returns normally on success.
  Future<void> testConnection(HaConnectionConfig config);
}
