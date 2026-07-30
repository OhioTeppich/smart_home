import 'package:flutter/foundation.dart';

import '../../domain/entities/smart_home_device.dart';
import '../../domain/repositories/smart_home_repository.dart';

class SmartHomeController extends ChangeNotifier {
  SmartHomeController(this._repository);

  final SmartHomeRepository _repository;
  SmartHomeDevice? _pendingDevice;
  String? _pendingRoomId;

  List<SmartHomeDevice> get devices => devicesFor('livingRoom');
  List<SmartHomeDevice> devicesFor(String roomId) =>
      _repository.devicesFor(roomId);
  SmartHomeDevice? get pendingDevice => _pendingDevice;
  bool get isPlacing => _pendingDevice != null;

  void startPlacement(SmartHomeDevice device, {String roomId = 'livingRoom'}) {
    _pendingDevice = device;
    _pendingRoomId = roomId;
    notifyListeners();
  }

  void placePending(double x, double y) {
    final device = _pendingDevice;
    if (device == null) return;
    final roomId = _pendingRoomId ?? 'livingRoom';
    _repository.addDevice(roomId, device.placeAt(x, y));
    _pendingDevice = null;
    _pendingRoomId = null;
    notifyListeners();
  }

  void cancelPlacement() {
    if (_pendingDevice == null) return;
    _pendingDevice = null;
    _pendingRoomId = null;
    notifyListeners();
  }

  void toggleDevice(String id, bool isOn, {String roomId = 'livingRoom'}) {
    final devices = _repository.devicesFor(roomId);
    final index = devices.indexWhere((device) => device.id == id);
    if (index == -1 || !devices[index].canToggle) return;
    _repository.updateDevice(roomId, devices[index].withPowerState(isOn));
    notifyListeners();
  }

  void removeDevice(String id, {String roomId = 'livingRoom'}) {
    _repository.removeDevice(roomId, id);
    notifyListeners();
  }
}
