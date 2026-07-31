import 'dart:async';

import '../../../../core/home_assistant/ha_client_exceptions.dart';
import '../../../../core/home_assistant/ha_rest_client.dart';
import '../../../../core/home_assistant/ha_websocket_client.dart';
import '../../../ha_connection/domain/value_objects/ha_connection_config.dart';
import '../../domain/entities/cover_action.dart';
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
  /// Only these Home Assistant domains are surfaced as devices — everything
  /// else (automations, zones, persons, updates, `sun.sun`, ...) is dropped
  /// rather than shown as a generic "Sonstiges" device.
  static const _supportedDomains = {
    'light',
    'switch',
    'media_player',
    'sensor',
    'binary_sensor',
    'climate',
    'cover',
  };

  static bool _isDomainSupported(String entityId) =>
      _supportedDomains.contains(entityId.split('.').first);

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

  /// Mirrors the devices last pushed through [watchDevices]'s stream.
  /// [placeDevice]/[assignDeviceToRoom]/[removeFromView]/[toggleDevice] only
  /// ever touch local overlay storage — Home Assistant never echoes those
  /// back as a `state_changed` event — so without also patching this cache
  /// directly, the *next* unrelated live update would overwrite it with the
  /// stale pre-mutation snapshot and the change would appear to "undo
  /// itself" a moment after the user made it.
  final _byId = <String, SmartHomeDevice>{};
  StreamController<List<SmartHomeDevice>>? _activeController;

  /// Entity ids whose `entity_category` is `diagnostic` or `config` — Home
  /// Assistant's own convention for "not a primary device the user cares
  /// about" (e.g. `sensor.backup_last_successful_backup`,
  /// `update.home_assistant_core`). Cached for the repository's lifetime;
  /// left `null` (and re-fetched next call) if the registry lookup fails,
  /// so a transient error only skips this extra filter instead of hard
  /// failing the whole device list.
  Set<String>? _diagnosticEntityIdsCache;

  Future<Set<String>> _diagnosticEntityIds(HaConnectionConfig config) async {
    final cached = _diagnosticEntityIdsCache;
    if (cached != null) return cached;
    try {
      final entries = await _webSocketClient.fetchEntityRegistry(
        baseUrl: config.baseUrl,
        token: config.token,
      );
      final ids = entries
          .where(
            (entry) =>
                entry['entity_category'] == 'diagnostic' ||
                entry['entity_category'] == 'config',
          )
          .map((entry) => entry['entity_id'] as String)
          .toSet();
      _diagnosticEntityIdsCache = ids;
      return ids;
    } catch (_) {
      return const {};
    }
  }

  @override
  Future<List<SmartHomeDevice>> fetchDevices() async {
    final config = _config;
    if (config == null) return const [];
    try {
      final states = await _restClient.fetchStates(
        baseUrl: config.baseUrl,
        token: config.token,
      );
      final diagnosticIds = await _diagnosticEntityIds(config);
      final overlays = await _overlayDataSource.readAll();
      return states
          .where((json) {
            final id = json['entity_id'] as String;
            return _isDomainSupported(id) && !diagnosticIds.contains(id);
          })
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
    _activeController = controller;
    return controller.stream;
  }

  Future<void> _startWatching(
    HaConnectionConfig config,
    StreamController<List<SmartHomeDevice>> controller,
  ) async {
    StreamSubscription<Map<String, dynamic>>? eventSubscription;
    controller.onCancel = () {
      eventSubscription?.cancel();
      if (identical(_activeController, controller)) _activeController = null;
    };

    try {
      _byId.clear();
      for (final device in await fetchDevices()) {
        _byId[device.id] = device;
      }
      if (!controller.isClosed) controller.add(_byId.values.toList());
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
            if (!_isDomainSupported(entityId)) return;
            final diagnosticIds = await _diagnosticEntityIds(config);
            if (diagnosticIds.contains(entityId)) return;
            final overlays = await _overlayDataSource.readAll();
            _byId[entityId] = _applyOverlay(
              HaEntityStateDto.fromJson(newState),
              overlays[entityId],
            );
            if (!controller.isClosed) controller.add(_byId.values.toList());
          },
          onError: (Object error) {
            if (!controller.isClosed) controller.addError(_mapClientFailure(error));
          },
          cancelOnError: false,
        );
  }

  /// Applies a local-only change (placement, room override, removal, ...)
  /// directly to the live cache and re-emits, so it survives the next
  /// unrelated `state_changed` push instead of being clobbered by it.
  void _mutateCache(String id, SmartHomeDevice Function(SmartHomeDevice) update) {
    final device = _byId[id];
    if (device == null) return;
    _byId[id] = update(device);
    final controller = _activeController;
    if (controller != null && !controller.isClosed) {
      controller.add(_byId.values.toList());
    }
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
    _mutateCache(id, (device) => device.withPowerState(isOn));
  }

  @override
  Future<void> controlCover(String id, CoverAction action) async {
    final config = _config;
    if (config == null) throw const SmartHomeUnconfiguredFailure();
    try {
      await _restClient.callService(
        baseUrl: config.baseUrl,
        token: config.token,
        domain: 'cover',
        service: switch (action) {
          CoverAction.open => 'open_cover',
          CoverAction.close => 'close_cover',
          CoverAction.stop => 'stop_cover',
        },
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
    // No cache patch here, unlike toggleDevice/placeDevice/... — a cover's
    // position/state genuinely changes on the Home Assistant side, so the
    // real `state_changed` events (opening → open/closed, position ticking
    // down/up) will arrive via the live stream shortly.
  }

  @override
  Future<void> assignDeviceToRoom(String id, String? roomId) async {
    await _overlayDataSource.setRoomOverride(id, roomId);
    _mutateCache(id, (device) => device.assignToRoom(roomId));
  }

  @override
  Future<void> placeDevice(String id, String roomId, double x, double y) async {
    await _overlayDataSource.setPlacement(id, roomId, x, y);
    _mutateCache(id, (device) => device.assignToRoom(roomId).placeAt(x, y));
  }

  @override
  Future<void> removeFromView(String id) async {
    await _overlayDataSource.clearView(id);
    _mutateCache(id, (device) => device.removeFromView());
  }

  SmartHomeFailure _mapClientFailure(Object error) {
    if (error is HaAuthException) return const SmartHomeUnauthorizedFailure();
    if (error is HaTimeoutException || error is HaConnectionException) {
      return const SmartHomeConnectionFailure();
    }
    if (error is HaProtocolException) return SmartHomeUnexpectedFailure(error.message);
    return SmartHomeUnexpectedFailure('$error');
  }
}
