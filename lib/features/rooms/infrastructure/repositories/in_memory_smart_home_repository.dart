import '../../domain/entities/smart_home_device.dart';
import '../../domain/repositories/smart_home_repository.dart';

class InMemorySmartHomeRepository implements SmartHomeRepository {
  final Map<String, List<SmartHomeDevice>> _devicesByRoom = {};

  @override
  List<SmartHomeDevice> devicesFor(String roomId) =>
      List.unmodifiable(_devicesByRoom[roomId] ?? const []);

  @override
  void addDevice(String roomId, SmartHomeDevice device) {
    (_devicesByRoom[roomId] ??= []).add(device);
  }

  @override
  void updateDevice(String roomId, SmartHomeDevice device) {
    final devices = _devicesByRoom[roomId];
    if (devices == null) return;
    final index = devices.indexWhere((item) => item.id == device.id);
    if (index != -1) devices[index] = device;
  }

  @override
  void removeDevice(String roomId, String deviceId) {
    _devicesByRoom[roomId]?.removeWhere((device) => device.id == deviceId);
  }
}
