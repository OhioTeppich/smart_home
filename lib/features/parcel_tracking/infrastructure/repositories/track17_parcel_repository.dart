import 'dart:async';
import 'dart:io';

import '../../domain/entities/carrier.dart';
import '../../domain/entities/parcel.dart';
import '../../domain/entities/parcel_status.dart';
import '../../domain/failures/parcel_tracking_failure.dart';
import '../../domain/repositories/parcel_repository.dart';
import '../../domain/services/parcel_sorter.dart';
import '../data_sources/parcel_local_data_source.dart';
import '../data_sources/track17_api_key_local_data_source.dart';
import '../data_sources/track17_remote_data_source.dart';
import '../models/carrier_track17_code.dart';
import '../models/parcel_record_dto.dart';
import '../models/track17_status_dto.dart';

class Track17ParcelRepository implements ParcelRepository {
  Track17ParcelRepository(
    this._localDataSource,
    this._apiKeyDataSource,
    this._remoteDataSource,
  );

  static const _pollInterval = Duration(minutes: 10);

  final ParcelLocalDataSource _localDataSource;
  final Track17ApiKeyLocalDataSource _apiKeyDataSource;
  final Track17RemoteDataSource _remoteDataSource;

  /// Mirrors the parcels last pushed through [watchParcels]'s stream.
  final _byId = <String, Parcel>{};
  StreamController<List<Parcel>>? _activeController;
  Timer? _pollTimer;

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
      _pollTimer?.cancel();
      if (identical(_activeController, controller)) _activeController = null;
    };
    try {
      final records = await _localDataSource.readAll();
      _byId
        ..clear()
        ..addEntries(records.map((record) => MapEntry(record.id, record.toDomain())));
      if (!controller.isClosed) controller.add(sortParcelsForDisplay(_byId.values.toList()));
    } catch (error) {
      if (!controller.isClosed) {
        controller.addError(
          error is ParcelTrackingFailure ? error : ParcelUnexpectedFailure('$error'),
        );
      }
    }
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_pollInterval, (_) => unawaited(_pollSilently()));
  }

  /// Background polling failures (no connectivity, key revoked, ...) are not
  /// surfaced through the stream — that would wipe the last-known list for
  /// an error nobody explicitly triggered. A manual refresh surfaces the
  /// same failure through [refreshAll] instead.
  Future<void> _pollSilently() async {
    try {
      await refreshAll();
    } catch (_) {
      // Ignored — see method doc.
    }
  }

  @override
  Future<List<Parcel>> fetchParcels() async {
    final records = await _localDataSource.readAll();
    return sortParcelsForDisplay([
      for (final record in records) record.toDomain(),
    ]);
  }

  @override
  Future<void> addParcel({
    required Carrier carrier,
    required String trackingNumber,
    String? description,
  }) => _guard(() async {
    final trimmedNumber = trackingNumber.trim();
    final trimmedDescription = description?.trim();
    final id = '${carrier.name}:$trimmedNumber';
    final now = DateTime.now();

    final carrierCode = carrier.track17Code;
    if (carrierCode != null) {
      await _remoteDataSource.register(carrierCode, trimmedNumber);
    }

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
  });

  @override
  Future<void> removeParcel(String id) async {
    _byId.remove(id);
    await _persist();
    _emit();
  }

  @override
  Future<void> refreshParcel(String id) => _guard(() async {
    final parcel = _byId[id];
    final carrierCode = parcel?.carrier.track17Code;
    if (parcel == null || carrierCode == null) return;
    final statuses = await _remoteDataSource.fetchStatuses([
      (carrierCode: carrierCode, trackingNumber: parcel.trackingNumber),
    ]);
    _applyStatusResults(statuses);
  });

  @override
  Future<void> refreshAll() => _guard(() async {
    final refs = [
      for (final parcel in _byId.values)
        if (parcel.carrier.track17Code case final code?)
          (carrierCode: code, trackingNumber: parcel.trackingNumber),
    ];
    if (refs.isEmpty) return;
    final statuses = await _remoteDataSource.fetchStatuses(refs);
    _applyStatusResults(statuses);
  });

  @override
  Future<bool> hasApiKeyConfigured() async {
    final apiKey = await _apiKeyDataSource.read();
    return apiKey != null && apiKey.isNotEmpty;
  }

  @override
  Future<void> configureApiKey(String apiKey) =>
      _apiKeyDataSource.write(apiKey);

  @override
  Future<void> clearApiKey() => _apiKeyDataSource.clear();

  void _applyStatusResults(List<Track17StatusDto> results) {
    if (results.isEmpty) return;
    final now = DateTime.now();
    for (final result in results) {
      final matchId = _byId.keys.firstWhere(
        (id) => _byId[id]!.trackingNumber == result.trackingNumber,
        orElse: () => '',
      );
      if (matchId.isEmpty) continue;
      _byId[matchId] = _byId[matchId]!.copyWith(
        status: result.toParcelStatus(),
        lastUpdate: now,
      );
    }
    unawaited(_persist());
    _emit();
  }

  Future<void> _persist() async {
    await _localDataSource.writeAll([
      for (final parcel in _byId.values) ParcelRecordDto.fromDomain(parcel),
    ]);
  }

  void _emit() {
    final controller = _activeController;
    if (controller != null && !controller.isClosed) {
      controller.add(sortParcelsForDisplay(_byId.values.toList()));
    }
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on ParcelTrackingFailure {
      rethrow;
    } on TimeoutException {
      throw const ParcelProviderUnreachableFailure();
    } on SocketException {
      throw const ParcelProviderUnreachableFailure();
    } catch (error) {
      throw ParcelUnexpectedFailure(error.toString());
    }
  }
}
