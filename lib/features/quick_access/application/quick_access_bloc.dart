import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/quick_access_limits.dart';
import '../domain/repositories/quick_access_repository.dart';
import 'quick_access_event.dart';
import 'quick_access_state.dart';

class QuickAccessBloc extends Bloc<QuickAccessEvent, QuickAccessState> {
  QuickAccessBloc(this._repository) : super(const QuickAccessInitial()) {
    on<QuickAccessStarted>(_onStarted);
    on<QuickAccessDeviceAdded>(_onDeviceAdded);
    on<QuickAccessDeviceRemoved>(_onDeviceRemoved);
  }

  final QuickAccessRepository _repository;

  Future<void> _onStarted(
    QuickAccessStarted event,
    Emitter<QuickAccessState> emit,
  ) async {
    emit(const QuickAccessLoadInProgress());
    final ids = await _repository.loadDeviceIds();
    emit(QuickAccessReady(deviceIds: ids));
  }

  Future<void> _onDeviceAdded(
    QuickAccessDeviceAdded event,
    Emitter<QuickAccessState> emit,
  ) async {
    final current = state;
    if (current is! QuickAccessReady) return;
    if (current.deviceIds.contains(event.deviceId)) return;
    if (current.deviceIds.length >= kQuickAccessMaxDevices) return;
    final next = [...current.deviceIds, event.deviceId];
    await _repository.saveDeviceIds(next);
    emit(current.copyWith(deviceIds: next));
  }

  Future<void> _onDeviceRemoved(
    QuickAccessDeviceRemoved event,
    Emitter<QuickAccessState> emit,
  ) async {
    final current = state;
    if (current is! QuickAccessReady) return;
    final next = [
      for (final id in current.deviceIds)
        if (id != event.deviceId) id,
    ];
    await _repository.saveDeviceIds(next);
    emit(current.copyWith(deviceIds: next));
  }
}
