import '../entities/smart_home_device.dart';

abstract class SmartHomeRepository {
  /// Emits the full device list whenever it changes (Home Assistant
  /// `state_changed` push or a local overlay change). Emits an empty list
  /// when no Home Assistant connection is configured — there is no mock
  /// fallback.
  Stream<List<SmartHomeDevice>> watchDevices();

  Future<List<SmartHomeDevice>> fetchDevices();

  Future<void> toggleDevice(String id, bool isOn);

  /// `roomId: null` unassigns the device. Always clears the device's
  /// placement (see [SmartHomeDevice.assignToRoom]).
  Future<void> assignDeviceToRoom(String id, String? roomId);

  Future<void> placeDevice(String id, String roomId, double x, double y);

  /// Clears both room assignment and placement.
  Future<void> removeFromView(String id);
}
