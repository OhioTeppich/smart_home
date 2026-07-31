import 'package:equatable/equatable.dart';

sealed class QuickAccessState extends Equatable {
  const QuickAccessState();

  @override
  List<Object?> get props => [];
}

class QuickAccessInitial extends QuickAccessState {
  const QuickAccessInitial();
}

class QuickAccessLoadInProgress extends QuickAccessState {
  const QuickAccessLoadInProgress();
}

/// Single settled state: the ordered list of Home Assistant `entity_id`s the
/// user picked. Live device data (name, on/off, cover position) is looked up
/// from `SmartHomeConnected.devices` at render time, not duplicated here.
class QuickAccessReady extends QuickAccessState {
  const QuickAccessReady({required this.deviceIds});

  final List<String> deviceIds;

  QuickAccessReady copyWith({List<String>? deviceIds}) =>
      QuickAccessReady(deviceIds: deviceIds ?? this.deviceIds);

  @override
  List<Object?> get props => [deviceIds];
}
