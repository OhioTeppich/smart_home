abstract class QuickAccessRepository {
  Future<List<String>> loadDeviceIds();
  Future<void> saveDeviceIds(List<String> deviceIds);
}
