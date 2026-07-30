import 'dart:async';

import '../../../../core/home_assistant/ha_client_exceptions.dart';
import '../../../../core/home_assistant/ha_rest_client.dart';
import '../../../../core/home_assistant/ha_websocket_client.dart';
import '../../../ha_connection/domain/value_objects/ha_connection_config.dart';
import '../../domain/entities/smart_home_device.dart';
import '../../domain/failures/smart_home_failure.dart';
import '../../domain/repositories/smart_home_repository.dart';
import '../data_sources/ha_area_alias_mapper.dart';
import '../data_sources/ha_device_overlay_local_data_source.dart';
import '../models/ha_entity_state_dto.dart';

/// [config] is fixed for the lifetime of an instance — the composition
/// root rebuilds this repository (and the `SmartHomeBloc` on top of it)
/// whenever the Home Assistant connection config changes. `config == null`
/// means "not configured": every method behaves as a trivial empty/no-op
/// implementation instead of a mock fallback.
class HomeAssistantSmartHomeRepository implements SmartHomeRepository {
  HomeAssistantSmartHomeRepository({
    required HaConnectionConfig? config,
    HaRestClient? restClient,
    HaWebSocketClient? webSocketClient,
    HaAreaAliasMapper? areaAliasMapper,
    HaDeviceOverlayLocalDataSource? overlayDataSource,
  }) : _config = config,
       _restClient = restClient ?? HaRestClient(),
       _webSocketClient = webSocketClient ?? HaWebSocketClient(),
       _areaAliasMapper = areaAliasMapper ?? const HaAreaAliasMapper(),
       _overlayDataSource = overlayDataSource ?? HaDeviceOverlayLocalDataSource();

  final HaConnectionConfig? _config;
  final HaRestClient _restClient;
  final HaWebSocketClient _webSocketClient;
  final HaAreaAliasMapper _areaAliasMapper;
  final HaDeviceOverlayLocalDataSource _overlayDataSource;

  @override
  Future<List<SmartHomeDevice>> fetchDevices() async {
    final config = _config;
    if (config == null) return const [];
    try {
      final states = await _restClient.fetchStates(
        baseUrl: config.baseUrl,
        token: config.token,
      );
      final overlays = await _overlayDataSource.readAll();
      return states
          .map(HaEntityStateDto.fromJson)
          .map((dto) => _applyOverlay(dto, overlays[dto.entityId]))
          .toList();
    } on HaAuthException {
      throw const SmartHomeUnauthorizedFailure();
    } on HaTimeoutException {
      throw const SmartHomeConnectionFailure();
    } on HaConnectionException {
      throw const SmartHomeConnectionFailure();
    } on HaProtocolException catch (error) {
      throw SmartHomeUnexpectedFailure(error.message);
    }
  }

  @override
  Stream<List<SmartHomeDevice>> watchDevices() {
    final config = _config;
    if (config == null) return Stream.value(const []);

    late final StreamController<List<SmartHomeDevice>> controller;
    controller = StreamController<List<SmartHomeDevice>>(
      onListen: () => unawaited(_startWatching(config, controller)),
    );
    return controller.stream;
  }

  Future<void> _startWatching(
    HaConnectionConfig config,
    StreamController<List<SmartHomeDevice>> controller,
  ) async {
    final byId = <String, SmartHomeDevice>{};
    StreamSubscription<Map<String, dynamic>>? eventSubscription;
    controller.onCancel = () => eventSubscription?.cancel();

    try {
      for (final device in await fetchDevices()) {
        byId[device.id] = device;
      }
      if (!controller.isClosed) controller.add(byId.values.toList());
    } catch (error) {
      if (!controller.isClosed) {
        controller.addError(
          error is SmartHomeFailure ? error : SmartHomeUnexpectedFailure('$error'),
        );
      }
    }

    eventSubscription = _webSocketClient
        .events(
          baseUrl: config.baseUrl,
          token: config.token,
          eventType: 'state_changed',
        )
        .listen(
          (event) async {
            final data = event['data'];
            final entityId = data is Map ? data['entity_id'] as String? : null;
            final newState = data is Map ? data['new_state'] : null;
            if (entityId == null || newState is! Map<String, dynamic>) return;
            final overlays = await _overlayDataSource.readAll();
            byId[entityId] = _applyOverlay(
              HaEntityStateDto.fromJson(newState),
              overlays[entityId],
            );
            if (!controller.isClosed) controller.add(byId.values.toList());
          },
          onError: (Object error) {
            if (!controller.isClosed) controller.addError(_mapClientFailure(error));
          },
          cancelOnError: false,
        );
  }

  SmartHomeDevice _applyOverlay(HaEntityStateDto dto, HaDeviceOverlay? overlay) {
    final heuristicRoomId = _areaAliasMapper.match(
      entityId: dto.entityId,
      friendlyName: dto.attributes['friendly_name'] as String?,
    );
    final roomId = (overlay?.hasRoomOverride ?? false)
        ? overlay!.roomId
        : heuristicRoomId;
    var device = dto.toDomain(roomId: roomId);
    if (overlay?.x != null && overlay?.y != null) {
      device = device.placeAt(overlay!.x!, overlay.y!);
    }
    if (overlay != null && overlay.switchCount > 0) {
      device = device.copyWith(switchCount: overlay.switchCount);
    }
    return device;
  }

  @override
  Future<void> toggleDevice(String id, bool isOn) async {
    final config = _config;
    if (config == null) throw const SmartHomeUnconfiguredFailure();
    try {
      await _restClient.callService(
        baseUrl: config.baseUrl,
        token: config.token,
        domain: id.split('.').first,
        service: isOn ? 'turn_on' : 'turn_off',
        entityId: id,
      );
    } on HaAuthException {
      throw const SmartHomeUnauthorizedFailure();
    } on HaTimeoutException {
      throw const SmartHomeConnectionFailure();
    } on HaConnectionException {
      throw const SmartHomeConnectionFailure();
    } on HaProtocolException catch (error) {
      throw SmartHomeUnexpectedFailure(error.message);
    }
    await _overlayDataSource.incrementSwitchCount(id);
  }

  @override
  Future<void> assignDeviceToRoom(String id, String? roomId) =>
      _overlayDataSource.setRoomOverride(id, roomId);

  @override
  Future<void> placeDevice(String id, String roomId, double x, double y) =>
      _overlayDataSource.setPlacement(id, roomId, x, y);

  @override
  Future<void> removeFromView(String id) => _overlayDataSource.clearView(id);

  SmartHomeFailure _mapClientFailure(Object error) {
    if (error is HaAuthException) return const SmartHomeUnauthorizedFailure();
    if (error is HaTimeoutException || error is HaConnectionException) {
      return const SmartHomeConnectionFailure();
    }
    if (error is HaProtocolException) return SmartHomeUnexpectedFailure(error.message);
    return SmartHomeUnexpectedFailure('$error');
  }
}
