import '../entities/smart_home_device.dart';

abstract class SmartHomeRepository {
  List<SmartHomeDevice> devicesFor(String roomId);
  void addDevice(String roomId, SmartHomeDevice device);
  void updateDevice(String roomId, SmartHomeDevice device);
  void removeDevice(String roomId, String deviceId);
}
