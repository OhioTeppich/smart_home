import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:smart_home/features/parcel_tracking/application/parcel_tracking_bloc.dart';
import 'package:smart_home/features/parcel_tracking/application/parcel_tracking_event.dart';
import 'package:smart_home/features/parcel_tracking/application/parcel_tracking_state.dart';
import 'package:smart_home/features/parcel_tracking/domain/entities/carrier.dart';
import 'package:smart_home/features/parcel_tracking/domain/entities/parcel.dart';
import 'package:smart_home/features/parcel_tracking/domain/entities/parcel_status.dart';
import 'package:smart_home/features/parcel_tracking/domain/failures/parcel_tracking_failure.dart';
import 'package:smart_home/features/parcel_tracking/domain/repositories/parcel_repository.dart';

class _FakeParcelRepository implements ParcelRepository {
  final _controller = StreamController<List<Parcel>>.broadcast();
  List<Parcel> parcels = [];
  bool apiKeyConfigured = false;
  bool throwOnHasApiKeyConfigured = false;
  Object? addParcelError;
  Object? refreshError;
  final calls = <String>[];

  @override
  Stream<List<Parcel>> watchParcels() => _controller.stream;

  @override
  Future<List<Parcel>> fetchParcels() async => parcels;

  @override
  Future<void> addParcel({
    required Carrier carrier,
    required String trackingNumber,
    String? description,
  }) async {
    calls.add('addParcel');
    if (addParcelError != null) throw addParcelError!;
    final parcel = Parcel(
      id: '$carrier:$trackingNumber',
      carrier: carrier,
      trackingNumber: trackingNumber,
      status: ParcelStatus.unknown,
      lastUpdate: DateTime.now(),
      addedAt: DateTime.now(),
      description: description,
    );
    parcels = [...parcels, parcel];
    _controller.add(parcels);
  }

  @override
  Future<void> removeParcel(String id) async {
    parcels = parcels.where((p) => p.id != id).toList();
    _controller.add(parcels);
  }

  @override
  Future<void> refreshParcel(String id) async {
    calls.add('refreshParcel');
    if (refreshError != null) throw refreshError!;
  }

  @override
  Future<void> refreshAll() async {
    calls.add('refreshAll');
    if (refreshError != null) throw refreshError!;
  }

  @override
  Future<bool> hasApiKeyConfigured() async {
    if (throwOnHasApiKeyConfigured) throw StateError('boom');
    return apiKeyConfigured;
  }

  @override
  Future<void> configureApiKey(String apiKey) async {
    apiKeyConfigured = true;
  }

  @override
  Future<void> clearApiKey() async {
    apiKeyConfigured = false;
  }

  void emitParcels(List<Parcel> value) {
    parcels = value;
    _controller.add(value);
  }

  void emitStreamError(Object error) => _controller.addError(error);

  Future<void> dispose() => _controller.close();
}

Parcel _parcel(String id) => Parcel(
  id: id,
  carrier: Carrier.dhl,
  trackingNumber: id,
  status: ParcelStatus.unknown,
  lastUpdate: DateTime.now(),
  addedAt: DateTime.now(),
);

void main() {
  late _FakeParcelRepository repository;
  late ParcelTrackingBloc bloc;

  setUp(() {
    repository = _FakeParcelRepository();
  });

  tearDown(() async {
    await bloc.close();
    await repository.dispose();
  });

  test('initial state is ParcelTrackingInitial', () {
    bloc = ParcelTrackingBloc(repository);
    expect(bloc.state, isA<ParcelTrackingInitial>());
  });

  test('Started emits Ready reflecting repository parcels and api key state', () async {
    repository.apiKeyConfigured = true;
    bloc = ParcelTrackingBloc(repository);

    bloc.add(const ParcelTrackingStarted());
    await Future.delayed(Duration.zero);
    repository.emitParcels([_parcel('a')]);
    await Future.delayed(Duration.zero);

    final state = bloc.state;
    expect(state, isA<ParcelTrackingReady>());
    expect((state as ParcelTrackingReady).parcels.map((p) => p.id), ['a']);
    expect(state.isConfigured, isTrue);
  });

  test('a failed api-key check does not block the parcel stream', () async {
    repository.throwOnHasApiKeyConfigured = true;
    bloc = ParcelTrackingBloc(repository);

    bloc.add(const ParcelTrackingStarted());
    await Future.delayed(Duration.zero);
    repository.emitParcels([_parcel('a')]);
    await Future.delayed(Duration.zero);

    final state = bloc.state;
    expect(state, isA<ParcelTrackingReady>());
    expect((state as ParcelTrackingReady).isConfigured, isFalse);
  });

  test('ParcelAdded failure surfaces ParcelTrackingError', () async {
    repository.addParcelError = const ParcelProviderApiKeyMissingFailure();
    bloc = ParcelTrackingBloc(repository);
    bloc.add(const ParcelTrackingStarted());
    await Future.delayed(Duration.zero);
    repository.emitParcels([]);
    await Future.delayed(Duration.zero);

    bloc.add(
      const ParcelTrackingParcelAdded(
        carrier: Carrier.dhl,
        trackingNumber: '12345',
      ),
    );
    await Future.delayed(Duration.zero);

    expect(bloc.state, isA<ParcelTrackingError>());
  });

  test('stream error emits ParcelTrackingError', () async {
    bloc = ParcelTrackingBloc(repository);
    bloc.add(const ParcelTrackingStarted());
    await Future.delayed(Duration.zero);

    repository.emitStreamError(const ParcelProviderUnreachableFailure());
    await Future.delayed(Duration.zero);

    expect(bloc.state, isA<ParcelTrackingError>());
  });
}
