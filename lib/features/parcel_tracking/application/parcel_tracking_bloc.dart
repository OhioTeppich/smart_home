import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/entities/parcel.dart';
import '../domain/failures/parcel_tracking_failure.dart';
import '../domain/repositories/parcel_repository.dart';
import 'parcel_tracking_event.dart';
import 'parcel_tracking_state.dart';

class ParcelTrackingBloc extends Bloc<ParcelTrackingEvent, ParcelTrackingState> {
  ParcelTrackingBloc(this._repository) : super(const ParcelTrackingInitial()) {
    on<ParcelTrackingStarted>(_onStarted);
    on<ParcelTrackingParcelsUpdated>(_onParcelsUpdated);
    on<ParcelTrackingStreamFailed>(_onStreamFailed);
    on<ParcelTrackingParcelAdded>(_onParcelAdded);
    on<ParcelTrackingParcelRemoved>(_onParcelRemoved);
    on<ParcelTrackingRefreshRequested>(_onRefreshRequested);
    on<ParcelTrackingRefreshAllRequested>(_onRefreshAllRequested);
  }

  final ParcelRepository _repository;
  StreamSubscription<List<Parcel>>? _parcelsSubscription;

  Future<void> _onStarted(
    ParcelTrackingStarted event,
    Emitter<ParcelTrackingState> emit,
  ) async {
    emit(const ParcelTrackingLoading());
    await _parcelsSubscription?.cancel();
    _parcelsSubscription = _repository.watchParcels().listen(
      (parcels) => add(ParcelTrackingParcelsUpdated(parcels)),
      onError: (Object error) =>
          add(ParcelTrackingStreamFailed(_messageFor(error))),
    );
  }

  void _onParcelsUpdated(
    ParcelTrackingParcelsUpdated event,
    Emitter<ParcelTrackingState> emit,
  ) {
    emit(ParcelTrackingReady(parcels: event.parcels));
  }

  void _onStreamFailed(
    ParcelTrackingStreamFailed event,
    Emitter<ParcelTrackingState> emit,
  ) {
    emit(ParcelTrackingError(event.message));
  }

  Future<void> _onParcelAdded(
    ParcelTrackingParcelAdded event,
    Emitter<ParcelTrackingState> emit,
  ) async {
    try {
      await _repository.addParcel(
        carrier: event.carrier,
        trackingNumber: event.trackingNumber,
        description: event.description,
      );
    } on ParcelTrackingFailure catch (failure) {
      emit(ParcelTrackingError(failure.message));
    }
  }

  Future<void> _onParcelRemoved(
    ParcelTrackingParcelRemoved event,
    Emitter<ParcelTrackingState> emit,
  ) async {
    try {
      await _repository.removeParcel(event.id);
    } on ParcelTrackingFailure catch (failure) {
      emit(ParcelTrackingError(failure.message));
    }
  }

  Future<void> _onRefreshRequested(
    ParcelTrackingRefreshRequested event,
    Emitter<ParcelTrackingState> emit,
  ) async {
    final current = state;
    if (current is! ParcelTrackingReady) return;
    emit(current.copyWith(isRefreshing: true));
    try {
      await _repository.refreshParcel(event.id);
    } on ParcelTrackingFailure catch (failure) {
      emit(ParcelTrackingError(failure.message));
      return;
    }
    final afterRefresh = state;
    if (afterRefresh is ParcelTrackingReady) {
      emit(afterRefresh.copyWith(isRefreshing: false));
    }
  }

  Future<void> _onRefreshAllRequested(
    ParcelTrackingRefreshAllRequested event,
    Emitter<ParcelTrackingState> emit,
  ) async {
    final current = state;
    if (current is! ParcelTrackingReady) return;
    emit(current.copyWith(isRefreshing: true));
    try {
      await _repository.refreshAll();
    } on ParcelTrackingFailure catch (failure) {
      emit(ParcelTrackingError(failure.message));
      return;
    }
    final afterRefresh = state;
    if (afterRefresh is ParcelTrackingReady) {
      emit(afterRefresh.copyWith(isRefreshing: false));
    }
  }

  String _messageFor(Object error) => error is ParcelTrackingFailure
      ? error.message
      : 'Unerwarteter Fehler: $error';

  @override
  Future<void> close() async {
    await _parcelsSubscription?.cancel();
    return super.close();
  }
}
