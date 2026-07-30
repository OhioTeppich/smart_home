import 'package:equatable/equatable.dart';

import '../domain/entities/smart_home_device.dart';

class SmartHomePendingPlacement extends Equatable {
  const SmartHomePendingPlacement({required this.device, required this.roomId});

  final SmartHomeDevice device;
  final String roomId;

  @override
  List<Object?> get props => [device, roomId];
}

sealed class SmartHomeState extends Equatable {
  const SmartHomeState();

  @override
  List<Object?> get props => [];
}

class SmartHomeInitial extends SmartHomeState {
  const SmartHomeInitial();
}

class SmartHomeLoading extends SmartHomeState {
  const SmartHomeLoading();
}

class SmartHomeConnected extends SmartHomeState {
  const SmartHomeConnected({required this.devices, this.pendingPlacement});

  final List<SmartHomeDevice> devices;
  final SmartHomePendingPlacement? pendingPlacement;

  bool get isPlacing => pendingPlacement != null;

  List<SmartHomeDevice> devicesFor(String roomId) =>
      devices.where((device) => device.roomId == roomId).toList();

  SmartHomeConnected copyWith({
    List<SmartHomeDevice>? devices,
    SmartHomePendingPlacement? pendingPlacement,
    bool clearPendingPlacement = false,
  }) => SmartHomeConnected(
    devices: devices ?? this.devices,
    pendingPlacement: clearPendingPlacement
        ? null
        : (pendingPlacement ?? this.pendingPlacement),
  );

  @override
  List<Object?> get props => [devices, pendingPlacement];
}

class SmartHomeError extends SmartHomeState {
  const SmartHomeError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
