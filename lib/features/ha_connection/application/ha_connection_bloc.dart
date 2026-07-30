import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/failures/ha_connection_failure.dart';
import '../domain/repositories/ha_connection_repository.dart';
import '../domain/value_objects/ha_connection_config.dart';
import 'ha_connection_event.dart';
import 'ha_connection_state.dart';

class HaConnectionBloc extends Bloc<HaConnectionEvent, HaConnectionState> {
  HaConnectionBloc(this._repository) : super(const HaConnectionInitial()) {
    on<HaConnectionStarted>(_onStarted);
    on<HaConnectionTestRequested>(_onTestRequested);
    on<HaConnectionSaveRequested>(_onSaveRequested);
    on<HaConnectionCleared>(_onCleared);
  }

  final HaConnectionRepository _repository;

  Future<void> _onStarted(
    HaConnectionStarted event,
    Emitter<HaConnectionState> emit,
  ) async {
    emit(const HaConnectionLoadInProgress());
    final config = await _repository.loadConfig();
    emit(HaConnectionReady(savedConfig: config));
  }

  Future<void> _onTestRequested(
    HaConnectionTestRequested event,
    Emitter<HaConnectionState> emit,
  ) async {
    final current = state;
    if (current is! HaConnectionReady) return;
    final config = HaConnectionConfig.tryCreate(
      baseUrl: event.baseUrl,
      token: event.token,
    );
    if (config == null) {
      emit(
        current.copyWith(
          testStatus: HaConnectionTestStatus.failure,
          testMessage: const HaConnectionInvalidConfigFailure().message,
        ),
      );
      return;
    }
    emit(
      current.copyWith(
        testStatus: HaConnectionTestStatus.inProgress,
        clearTestMessage: true,
      ),
    );
    try {
      await _repository.testConnection(config);
      emit(
        current.copyWith(
          testStatus: HaConnectionTestStatus.success,
          testMessage: 'Verbindung erfolgreich.',
        ),
      );
    } on HaConnectionFailure catch (failure) {
      emit(
        current.copyWith(
          testStatus: HaConnectionTestStatus.failure,
          testMessage: failure.message,
        ),
      );
    }
  }

  Future<void> _onSaveRequested(
    HaConnectionSaveRequested event,
    Emitter<HaConnectionState> emit,
  ) async {
    final current = state;
    if (current is! HaConnectionReady) return;
    final config = HaConnectionConfig.tryCreate(
      baseUrl: event.baseUrl,
      token: event.token,
    );
    if (config == null) {
      emit(
        current.copyWith(
          testStatus: HaConnectionTestStatus.failure,
          testMessage: const HaConnectionInvalidConfigFailure().message,
        ),
      );
      return;
    }
    await _repository.saveConfig(config);
    emit(HaConnectionReady(savedConfig: config));
  }

  Future<void> _onCleared(
    HaConnectionCleared event,
    Emitter<HaConnectionState> emit,
  ) async {
    await _repository.clearConfig();
    emit(const HaConnectionReady(savedConfig: null));
  }
}
