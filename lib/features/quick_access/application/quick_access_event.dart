import 'package:equatable/equatable.dart';

sealed class QuickAccessEvent extends Equatable {
  const QuickAccessEvent();

  @override
  List<Object?> get props => [];
}

class QuickAccessStarted extends QuickAccessEvent {
  const QuickAccessStarted();
}

class QuickAccessDeviceAdded extends QuickAccessEvent {
  const QuickAccessDeviceAdded(this.deviceId);

  final String deviceId;

  @override
  List<Object?> get props => [deviceId];
}

class QuickAccessDeviceRemoved extends QuickAccessEvent {
  const QuickAccessDeviceRemoved(this.deviceId);

  final String deviceId;

  @override
  List<Object?> get props => [deviceId];
}
