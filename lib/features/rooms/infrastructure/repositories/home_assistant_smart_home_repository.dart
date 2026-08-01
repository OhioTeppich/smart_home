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

/// Result of a Home Assistant entity registry lookup (`config/entity_registry
/// /list`), which `/api/states` itself does not expose: which entities are
/// diagnostic/config (hidden from the app) and which entities share a
/// physical Home Assistant device (`device_id`) with which others — used to
/// fold a companion power/energy `sensor.*` entity (e.g. a Shelly plug's
/// separate "Leistung" sensor) into its sibling switch/light/etc. device.
class _RegistryInfo {
  const _RegistryInfo({
    required this.diagnosticEntityIds,
    required this.siblingsByEntityId,
  });

  const _RegistryInfo.empty()
    : diagnosticEntityIds = const {},
      siblingsByEntityId = const {};

  final Set<String> diagnosticEntityIds;

  /// entityId -> the other entity ids on the same Home Assistant device.
  /// Only contains entries for entities whose device has 2+ entities.
  final Map<String, Set<String>> siblingsByEntityId;
}

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

  /// Latest raw state per entity, including companion power/energy sensor
  /// entities that get folded into a sibling device and therefore never
  /// appear in [_byId] on their own (see [_isAbsorbedCompanion]) — kept
  /// around so a live update to just the companion sensor, or just the host,
  /// can still recompute the merged wattage/energy without waiting for both
  /// to change together.
  final _rawById = <String, HaEntityStateDto>{};

  /// Cached for the repository's lifetime; falls back to [_RegistryInfo.
  /// empty] if the registry lookup fails, so a transient error only skips
  /// the diagnostic filter and companion-sensor merge instead of hard
  /// failing the whole device list. Retried at most once per
  /// [_registryInfoRetryCooldown] — without this, a single failure would
  /// otherwise be retried on every incoming `state_changed` event, each
  /// opening a fresh WebSocket connect + auth handshake.
  _RegistryInfo? _registryInfoCache;

  /// When the last registry fetch failed, holds the time of that failure so
  /// [_registryInfo] can wait out [_registryInfoRetryCooldown] instead of
  /// re-opening a full WebSocket connect + auth handshake on every single
  /// incoming `state_changed` event.
  DateTime? _registryInfoFailedAt;

  static const _registryInfoRetryCooldown = Duration(seconds: 60);

  Future<_RegistryInfo> _registryInfo(HaConnectionConfig config) async {
    final cached = _registryInfoCache;
    if (cached != null) return cached;
    final failedAt = _registryInfoFailedAt;
    if (failedAt != null &&
        DateTime.now().difference(failedAt) < _registryInfoRetryCooldown) {
      return const _RegistryInfo.empty();
    }
    try {
      final entries = await _webSocketClient.fetchEntityRegistry(
        baseUrl: config.baseUrl,
        token: config.token,
      );
      final diagnosticIds = <String>{};
      final entityIdsByDeviceId = <String, Set<String>>{};
      for (final entry in entries) {
        final entityId = entry['entity_id'] as String?;
        if (entityId == null) continue;
        if (entry['entity_category'] == 'diagnostic' ||
            entry['entity_category'] == 'config') {
          diagnosticIds.add(entityId);
        }
        final deviceId = entry['device_id'] as String?;
        if (deviceId == null) continue;
        entityIdsByDeviceId.putIfAbsent(deviceId, () => {}).add(entityId);
      }
      final siblings = <String, Set<String>>{
        for (final ids in entityIdsByDeviceId.values)
          if (ids.length > 1)
            for (final id in ids) id: {...ids}..remove(id),
      };
      final info = _RegistryInfo(
        diagnosticEntityIds: diagnosticIds,
        siblingsByEntityId: siblings,
      );
      _registryInfoCache = info;
      _registryInfoFailedAt = null;
      return info;
    } catch (_) {
      _registryInfoFailedAt = DateTime.now();
      return const _RegistryInfo.empty();
    }
  }

  /// A companion power/energy sensor (see [HaEntityStateDto.isPowerSensor]/
  /// [HaEntityStateDto.isEnergySensor]) is folded into a sibling device
  /// instead of being shown as its own tile whenever that sibling is known
  /// and isn't itself a plain sensor (i.e. there's an actual switch/light/
  /// etc. to fold it into).
  bool _isAbsorbedCompanion(HaEntityStateDto dto, _RegistryInfo registry) {
    if (!dto.isPowerSensor && !dto.isEnergySensor) return false;
    final siblingIds = registry.siblingsByEntityId[dto.entityId] ?? const {};
    return siblingIds.any((id) {
      final siblingDomain = _rawById[id]?.domain;
      return siblingDomain != null && siblingDomain != 'sensor';
    });
  }

  /// Builds the domain [SmartHomeDevice] for [dto], folding in a sibling
  /// power/energy sensor's reading (looked up in [_rawById]) whenever [dto]
  /// reports none of its own.
  SmartHomeDevice _buildDevice(
    HaEntityStateDto dto,
    _RegistryInfo registry,
    HaDeviceOverlay? overlay,
  ) {
    final siblingIds = registry.siblingsByEntityId[dto.entityId] ?? const {};
    HaEntityStateDto? powerSensor;
    HaEntityStateDto? energySensor;
    for (final id in siblingIds) {
      final sibling = _rawById[id];
      if (sibling == null) continue;
      if (sibling.isPowerSensor) powerSensor = sibling;
      if (sibling.isEnergySensor) energySensor = sibling;
    }
    return _applyOverlay(
      dto,
      overlay,
      companionPowerWatts: powerSensor?.ownPowerWatts,
      companionDailyKwh: energySensor?.ownDailyKwh,
      companionDailyKwhIsCumulative: energySensor?.ownDailyKwhIsCumulative ?? false,
    );
  }

  @override
  Future<List<SmartHomeDevice>> fetchDevices() async {
    final config = _config;
    if (config == null) return const [];
    try {
      final registry = await _registryInfo(config);
      final states = await _restClient.fetchStates(
        baseUrl: config.baseUrl,
        token: config.token,
      );
      final overlays = await _overlayDataSource.readAll();
      // Diagnostic/config entities are only hidden from becoming their own
      // tile below — they must still be cached here first, otherwise a
      // diagnostic-categorized companion power/energy sensor (common for
      // Shelly plugs) would never be visible to _buildDevice's sibling
      // lookup and its sibling device would show 0 W/kWh forever.
      final dtos = states
          .where((json) => _isDomainSupported(json['entity_id'] as String))
          .map(HaEntityStateDto.fromJson)
          .toList();
      for (final dto in dtos) {
        _rawById[dto.entityId] = dto;
      }
      return dtos
          .where(
            (dto) =>
                !registry.diagnosticEntityIds.contains(dto.entityId) &&
                !_isAbsorbedCompanion(dto, registry),
          )
          .map((dto) => _buildDevice(dto, registry, overlays[dto.entityId]))
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
      _rawById.clear();
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
            final registry = await _registryInfo(config);
            final dto = HaEntityStateDto.fromJson(newState);
            // Cached regardless of diagnostic status — see fetchDevices for
            // why a diagnostic-categorized companion sensor must still be
            // visible to sibling lookups.
            _rawById[entityId] = dto;
            final overlays = await _overlayDataSource.readAll();

            if (_isAbsorbedCompanion(dto, registry)) {
              // Folded into a sibling device, never shown on its own —
              // refresh whichever host sibling(s) are already known so the
              // merged wattage/energy picks up this reading right away.
              _byId.remove(entityId);
              for (final siblingId in registry.siblingsByEntityId[entityId] ?? const {}) {
                final siblingDto = _rawById[siblingId];
                if (siblingDto == null || siblingDto.domain == 'sensor') continue;
                _byId[siblingId] = _buildDevice(siblingDto, registry, overlays[siblingId]);
              }
            } else if (registry.diagnosticEntityIds.contains(entityId)) {
              _byId.remove(entityId);
            } else {
              _byId[entityId] = _buildDevice(dto, registry, overlays[entityId]);
            }
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

  SmartHomeDevice _applyOverlay(
    HaEntityStateDto dto,
    HaDeviceOverlay? overlay, {
    double? companionPowerWatts,
    double? companionDailyKwh,
    bool companionDailyKwhIsCumulative = false,
  }) {
    final heuristicRoomId = _areaAliasMapper.match(
      entityId: dto.entityId,
      friendlyName: dto.attributes['friendly_name'] as String?,
    );
    final roomId = (overlay?.hasRoomOverride ?? false)
        ? overlay!.roomId
        : heuristicRoomId;
    var device = dto.toDomain(
      roomId: roomId,
      companionPowerWatts: companionPowerWatts,
      companionDailyKwh: companionDailyKwh,
      companionDailyKwhIsCumulative: companionDailyKwhIsCumulative,
    );
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
