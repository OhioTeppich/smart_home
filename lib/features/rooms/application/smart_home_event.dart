import 'package:equatable/equatable.dart';

import '../domain/entities/cover_action.dart';
import '../domain/entities/smart_home_device.dart';

sealed class SmartHomeEvent extends Equatable {
  const SmartHomeEvent();

  @override
  List<Object?> get props => [];
}

class SmartHomeStarted extends SmartHomeEvent {
  const SmartHomeStarted();
}

class SmartHomeDeviceToggled extends SmartHomeEvent {
  const SmartHomeDeviceToggled(this.id, this.isOn);

  final String id;
  final bool isOn;

  @override
  List<Object?> get props => [id, isOn];
}

class SmartHomeCoverActionRequested extends SmartHomeEvent {
  const SmartHomeCoverActionRequested(this.id, this.action);

  final String id;
  final CoverAction action;

  @override
  List<Object?> get props => [id, action];
}

class SmartHomeDeviceAssignedToRoom extends SmartHomeEvent {
  const SmartHomeDeviceAssignedToRoom(this.id, this.roomId);

  final String id;
  final String? roomId;

  @override
  List<Object?> get props => [id, roomId];
}

class SmartHomeDeviceRemovedFromView extends SmartHomeEvent {
  const SmartHomeDeviceRemovedFromView(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

class SmartHomePlacementStarted extends SmartHomeEvent {
  const SmartHomePlacementStarted(this.device, this.roomId);

  final SmartHomeDevice device;
  final String roomId;

  @override
  List<Object?> get props => [device, roomId];
}

class SmartHomePlacementConfirmed extends SmartHomeEvent {
  const SmartHomePlacementConfirmed(this.x, this.y);

  final double x;
  final double y;

  @override
  List<Object?> get props => [x, y];
}

class SmartHomePlacementCancelled extends SmartHomeEvent {
  const SmartHomePlacementCancelled();
}

/// Internal: folded from `SmartHomeRepository.watchDevices()`.
class SmartHomeDevicesUpdated extends SmartHomeEvent {
  const SmartHomeDevicesUpdated(this.devices);

  final List<SmartHomeDevice> devices;

  @override
  List<Object?> get props => [devices];
}

/// Internal: folded from `SmartHomeRepository.watchDevices()` errors.
class SmartHomeStreamFailed extends SmartHomeEvent {
  const SmartHomeStreamFailed(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
