import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Local-only data laid over Home Assistant's raw entity state, keyed by
/// entity id: manual room override (wins against the area alias
/// heuristic), room-relative placement, and the app's own toggle counter.
/// None of this exists in Home Assistant.
class HaDeviceOverlay {
  const HaDeviceOverlay({
    this.roomId,
    this.hasRoomOverride = false,
    this.x,
    this.y,
    this.switchCount = 0,
  });

  final String? roomId;
  final bool hasRoomOverride;
  final double? x;
  final double? y;
  final int switchCount;
}

class HaDeviceOverlayLocalDataSource {
  static const _prefsKey = 'ha_device_overlay';

  /// Loaded lazily on first [readAll]/[_update] call, then kept for this
  /// instance's lifetime — the repository calls [readAll] on every
  /// `state_changed` websocket event, so without this cache every live HA
  /// update would re-read and re-decode the whole overlay blob from
  /// `SharedPreferences`, even though it only ever changes via explicit
  /// user actions (toggle/assign/place/remove) that already go through
  /// [_update] and keep this same map in sync.
  Map<String, HaDeviceOverlay>? _cache;

  Future<Map<String, HaDeviceOverlay>> readAll() async {
    final cached = _cache;
    if (cached != null) return cached;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    final loaded = raw == null ? <String, HaDeviceOverlay>{} : _decode(raw);
    _cache = loaded;
    return loaded;
  }

  Map<String, HaDeviceOverlay> _decode(String raw) {
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map((entityId, value) {
      final entry = (value as Map).cast<String, dynamic>();
      return MapEntry(
        entityId,
        HaDeviceOverlay(
          roomId: entry['roomId'] as String?,
          hasRoomOverride: entry.containsKey('roomId'),
          x: (entry['x'] as num?)?.toDouble(),
          y: (entry['y'] as num?)?.toDouble(),
          switchCount: entry['switchCount'] as int? ?? 0,
        ),
      );
    });
  }

  Future<void> setRoomOverride(String entityId, String? roomId) =>
      _update(entityId, (current) => HaDeviceOverlay(
        roomId: roomId,
        hasRoomOverride: true,
        switchCount: current.switchCount,
      ));

  Future<void> setPlacement(
    String entityId,
    String roomId,
    double x,
    double y,
  ) => _update(entityId, (current) => HaDeviceOverlay(
    roomId: roomId,
    hasRoomOverride: true,
    x: x,
    y: y,
    switchCount: current.switchCount,
  ));

  Future<void> clearView(String entityId) => _update(entityId, (current) => HaDeviceOverlay(
    roomId: null,
    hasRoomOverride: true,
    switchCount: current.switchCount,
  ));

  Future<void> incrementSwitchCount(String entityId) => _update(
    entityId,
    (current) => HaDeviceOverlay(
      roomId: current.roomId,
      hasRoomOverride: current.hasRoomOverride,
      x: current.x,
      y: current.y,
      switchCount: current.switchCount + 1,
    ),
  );

  Future<void> _update(
    String entityId,
    HaDeviceOverlay Function(HaDeviceOverlay current) transform,
  ) async {
    final overlays = await readAll();
    final current = overlays[entityId] ?? const HaDeviceOverlay();
    overlays[entityId] = transform(current);
    await _write(overlays);
  }

  Future<void> _write(Map<String, HaDeviceOverlay> overlays) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = <String, dynamic>{};
    for (final entry in overlays.entries) {
      final overlay = entry.value;
      final entryJson = <String, dynamic>{};
      if (overlay.hasRoomOverride) entryJson['roomId'] = overlay.roomId;
      if (overlay.x != null) entryJson['x'] = overlay.x;
      if (overlay.y != null) entryJson['y'] = overlay.y;
      if (overlay.switchCount != 0) entryJson['switchCount'] = overlay.switchCount;
      if (entryJson.isNotEmpty) encoded[entry.key] = entryJson;
    }
    await prefs.setString(_prefsKey, jsonEncode(encoded));
  }
}
