import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/entities/smart_home_device.dart';
import '../domain/failures/smart_home_failure.dart';
import '../domain/repositories/smart_home_repository.dart';
import 'smart_home_event.dart';
import 'smart_home_state.dart';

class SmartHomeBloc extends Bloc<SmartHomeEvent, SmartHomeState> {
  SmartHomeBloc(this._repository) : super(const SmartHomeInitial()) {
    on<SmartHomeStarted>(_onStarted);
    on<SmartHomeDevicesUpdated>(_onDevicesUpdated);
    on<SmartHomeStreamFailed>(_onStreamFailed);
    on<SmartHomeDeviceToggled>(_onDeviceToggled);
    on<SmartHomeCoverActionRequested>(_onCoverActionRequested);
    on<SmartHomeDeviceAssignedToRoom>(_onDeviceAssignedToRoom);
    on<SmartHomeDeviceRemovedFromView>(_onDeviceRemovedFromView);
    on<SmartHomePlacementStarted>(_onPlacementStarted);
    on<SmartHomePlacementConfirmed>(_onPlacementConfirmed);
    on<SmartHomePlacementCancelled>(_onPlacementCancelled);
  }

  final SmartHomeRepository _repository;
  StreamSubscription<void>? _devicesSubscription;

  Future<void> _onStarted(
    SmartHomeStarted event,
    Emitter<SmartHomeState> emit,
  ) async {
    emit(const SmartHomeLoading());
    await _devicesSubscription?.cancel();
    _devicesSubscription = _repository.watchDevices().listen(
      (devices) => add(SmartHomeDevicesUpdated(devices)),
      onError: (Object error) => add(SmartHomeStreamFailed(_messageFor(error))),
    );
  }

  void _onDevicesUpdated(
    SmartHomeDevicesUpdated event,
    Emitter<SmartHomeState> emit,
  ) {
    final current = state;
    final pendingPlacement = current is SmartHomeConnected
        ? current.pendingPlacement
        : null;
    emit(
      SmartHomeConnected(
        devices: event.devices,
        pendingPlacement: pendingPlacement,
      ),
    );
  }

  void _onStreamFailed(
    SmartHomeStreamFailed event,
    Emitter<SmartHomeState> emit,
  ) {
    emit(SmartHomeError(event.message));
  }

  Future<void> _onDeviceToggled(
    SmartHomeDeviceToggled event,
    Emitter<SmartHomeState> emit,
  ) async {
    try {
      await _repository.toggleDevice(event.id, event.isOn);
    } on SmartHomeFailure catch (failure) {
      emit(SmartHomeError(failure.message));
    }
  }

  Future<void> _onCoverActionRequested(
    SmartHomeCoverActionRequested event,
    Emitter<SmartHomeState> emit,
  ) async {
    try {
      await _repository.controlCover(event.id, event.action);
    } on SmartHomeFailure catch (failure) {
      emit(SmartHomeError(failure.message));
    }
  }

  Future<void> _onDeviceAssignedToRoom(
    SmartHomeDeviceAssignedToRoom event,
    Emitter<SmartHomeState> emit,
  ) async {
    final current = state;
    try {
      await _repository.assignDeviceToRoom(event.id, event.roomId);
      if (current is SmartHomeConnected) {
        emit(
          current.copyWith(
            devices: _updateDevice(
              current.devices,
              event.id,
              (device) => device.assignToRoom(event.roomId),
            ),
          ),
        );
      }
    } on SmartHomeFailure catch (failure) {
      emit(SmartHomeError(failure.message));
    }
  }

  Future<void> _onDeviceRemovedFromView(
    SmartHomeDeviceRemovedFromView event,
    Emitter<SmartHomeState> emit,
  ) async {
    final current = state;
    try {
      await _repository.removeFromView(event.id);
      if (current is SmartHomeConnected) {
        emit(
          current.copyWith(
            devices: _updateDevice(
              current.devices,
              event.id,
              (device) => device.removeFromView(),
            ),
          ),
        );
      }
    } on SmartHomeFailure catch (failure) {
      emit(SmartHomeError(failure.message));
    }
  }

  void _onPlacementStarted(
    SmartHomePlacementStarted event,
    Emitter<SmartHomeState> emit,
  ) {
    final current = state;
    if (current is! SmartHomeConnected) return;
    emit(
      current.copyWith(
        pendingPlacement: SmartHomePendingPlacement(
          device: event.device,
          roomId: event.roomId,
        ),
      ),
    );
  }

  Future<void> _onPlacementConfirmed(
    SmartHomePlacementConfirmed event,
    Emitter<SmartHomeState> emit,
  ) async {
    final current = state;
    if (current is! SmartHomeConnected) return;
    final pending = current.pendingPlacement;
    if (pending == null) return;
    emit(current.copyWith(clearPendingPlacement: true));
    try {
      await _repository.placeDevice(
        pending.device.id,
        pending.roomId,
        event.x,
        event.y,
      );
      emit(
        current.copyWith(
          clearPendingPlacement: true,
          devices: _updateDevice(
            current.devices,
            pending.device.id,
            (device) =>
                device.assignToRoom(pending.roomId).placeAt(event.x, event.y),
          ),
        ),
      );
    } on SmartHomeFailure catch (failure) {
      emit(SmartHomeError(failure.message));
    }
  }

  void _onPlacementCancelled(
    SmartHomePlacementCancelled event,
    Emitter<SmartHomeState> emit,
  ) {
    final current = state;
    if (current is! SmartHomeConnected) return;
    emit(current.copyWith(clearPendingPlacement: true));
  }

  List<SmartHomeDevice> _updateDevice(
    List<SmartHomeDevice> devices,
    String id,
    SmartHomeDevice Function(SmartHomeDevice device) update,
  ) => [
    for (final device in devices)
      if (device.id == id) update(device) else device,
  ];

  String _messageFor(Object error) =>
      error is SmartHomeFailure ? error.message : 'Unerwarteter Fehler: $error';

  @override
  Future<void> close() async {
    await _devicesSubscription?.cancel();
    return super.close();
  }
}
