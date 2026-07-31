import 'dart:async';

import '../../domain/entities/carrier.dart';
import '../../domain/entities/parcel.dart';
import '../../domain/entities/parcel_status.dart';
import '../../domain/failures/parcel_tracking_failure.dart';
import '../../domain/repositories/parcel_repository.dart';
import '../data_sources/parcel_local_data_source.dart';
import '../models/parcel_record_dto.dart';

/// 17Track polling is not wired up yet (see Milestone 3) — [refreshParcel]
/// and [refreshAll] are no-ops for now, and every added parcel stays at
/// [ParcelStatus.unknown] until then.
class Track17ParcelRepository implements ParcelRepository {
  Track17ParcelRepository(this._localDataSource);

  final ParcelLocalDataSource _localDataSource;

  /// Mirrors the parcels last pushed through [watchParcels]'s stream.
  final _byId = <String, Parcel>{};
  StreamController<List<Parcel>>? _activeController;

  @override
  Stream<List<Parcel>> watchParcels() {
    late final StreamController<List<Parcel>> controller;
    controller = StreamController<List<Parcel>>(
      onListen: () => unawaited(_startWatching(controller)),
    );
    _activeController = controller;
    return controller.stream;
  }

  Future<void> _startWatching(StreamController<List<Parcel>> controller) async {
    controller.onCancel = () {
      if (identical(_activeController, controller)) _activeController = null;
    };
    try {
      final records = await _localDataSource.readAll();
      _byId
        ..clear()
        ..addEntries(records.map((record) => MapEntry(record.id, record.toDomain())));
      if (!controller.isClosed) controller.add(_byId.values.toList());
    } catch (error) {
      if (!controller.isClosed) {
        controller.addError(
          error is ParcelTrackingFailure ? error : ParcelUnexpectedFailure('$error'),
        );
      }
    }
  }

  @override
  Future<List<Parcel>> fetchParcels() async {
    final records = await _localDataSource.readAll();
    return [for (final record in records) record.toDomain()];
  }

  @override
  Future<void> addParcel({
    required Carrier carrier,
    required String trackingNumber,
    String? description,
  }) async {
    final trimmedNumber = trackingNumber.trim();
    final trimmedDescription = description?.trim();
    final id = '${carrier.name}:$trimmedNumber';
    final now = DateTime.now();
    _byId[id] = Parcel(
      id: id,
      carrier: carrier,
      trackingNumber: trimmedNumber,
      status: ParcelStatus.unknown,
      lastUpdate: now,
      addedAt: now,
      description: (trimmedDescription == null || trimmedDescription.isEmpty)
          ? null
          : trimmedDescription,
    );
    await _persist();
    _emit();
  }

  @override
  Future<void> removeParcel(String id) async {
    _byId.remove(id);
    await _persist();
    _emit();
  }

  @override
  Future<void> refreshParcel(String id) async {}

  @override
  Future<void> refreshAll() async {}

  Future<void> _persist() async {
    await _localDataSource.writeAll([
      for (final parcel in _byId.values) ParcelRecordDto.fromDomain(parcel),
    ]);
  }

  void _emit() {
    final controller = _activeController;
    if (controller != null && !controller.isClosed) {
      controller.add(_byId.values.toList());
    }
  }
}
