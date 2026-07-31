enum SmartHomeDeviceType {
  lamp,
  bulb,
  television,
  plug,
  sensor,
  climate,
  cover,
  other,
}

extension SmartHomeDeviceTypeLabel on SmartHomeDeviceType {
  String get label => switch (this) {
    SmartHomeDeviceType.lamp => 'Lampe',
    SmartHomeDeviceType.bulb => 'Smart-Birne',
    SmartHomeDeviceType.television => 'Fernseher',
    SmartHomeDeviceType.plug => 'Steckdose',
    SmartHomeDeviceType.sensor => 'Sensor',
    SmartHomeDeviceType.climate => 'Klimasteuerung',
    SmartHomeDeviceType.cover => 'Rollladen',
    SmartHomeDeviceType.other => 'Sonstiges',
  };
}

/// `id` holds the Home Assistant `entity_id` (e.g. `light.wohnzimmer_lampe`)
/// once devices come from Home Assistant — there is no separate identity
/// field, so every existing lookup by `id` keeps working unchanged.
class SmartHomeDevice {
  const SmartHomeDevice({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.powerWatts,
    required this.dailyKwh,
    required this.lastUpdated,
    this.roomId,
    this.switchCount = 0,
    this.isOn = true,
    this.x,
    this.y,
    this.coverPosition,
    this.coverRawState,
  });

  final String id;
  final String name;
  final SmartHomeDeviceType type;
  final String status;
  final double powerWatts;
  final double dailyKwh;
  final String lastUpdated;

  /// Local room assignment (Home Assistant area heuristic or manual
  /// override). `null` means the device is not shown in any room yet.
  final String? roomId;
  final int switchCount;
  final bool isOn;

  /// Local, room-relative placement on the room map. `null` means the
  /// device is assigned to a room (or not) but has not been placed yet.
  final double? x;
  final double? y;

  /// How far a `cover` is open, `0`–`100`. `null` if Home Assistant doesn't
  /// report a position for this cover (not every integration supports it).
  final double? coverPosition;

  /// The raw Home Assistant `cover` state (`open`/`closed`/`opening`/
  /// `closing`/...) — used as a status fallback when [coverPosition] is
  /// unavailable. `null` for every non-`cover` device.
  final String? coverRawState;

  bool get isPlaced => x != null && y != null;

  bool get canToggle => switch (type) {
    SmartHomeDeviceType.lamp ||
    SmartHomeDeviceType.bulb ||
    SmartHomeDeviceType.television ||
    SmartHomeDeviceType.plug => true,
    SmartHomeDeviceType.sensor ||
    SmartHomeDeviceType.climate ||
    SmartHomeDeviceType.cover ||
    SmartHomeDeviceType.other => false,
  };

  SmartHomeDevice copyWith({
    String? roomId,
    bool clearRoomId = false,
    bool? isOn,
    String? lastUpdated,
    int? switchCount,
    double? x,
    double? y,
    bool clearPlacement = false,
    double? coverPosition,
    String? coverRawState,
  }) => SmartHomeDevice(
    id: id,
    name: name,
    type: type,
    status: status,
    powerWatts: powerWatts,
    dailyKwh: dailyKwh,
    lastUpdated: lastUpdated ?? this.lastUpdated,
    roomId: clearRoomId ? null : (roomId ?? this.roomId),
    switchCount: switchCount ?? this.switchCount,
    isOn: isOn ?? this.isOn,
    x: clearPlacement ? null : (x ?? this.x),
    y: clearPlacement ? null : (y ?? this.y),
    coverPosition: coverPosition ?? this.coverPosition,
    coverRawState: coverRawState ?? this.coverRawState,
  );

  SmartHomeDevice withPowerState(bool nextIsOn) => copyWith(
    isOn: nextIsOn,
    lastUpdated: 'gerade eben',
    switchCount: switchCount + 1,
  );

  SmartHomeDevice placeAt(double nextX, double nextY) => copyWith(
    x: nextX.clamp(0.04, 0.96).toDouble(),
    y: nextY.clamp(0.06, 0.94).toDouble(),
  );

  /// Reassigning a device to a (possibly different, possibly no) room
  /// always drops its placement: `x`/`y` are relative to a specific room's
  /// map image, so a stale position from another room would be meaningless.
  SmartHomeDevice assignToRoom(String? nextRoomId) => nextRoomId == null
      ? copyWith(clearRoomId: true, clearPlacement: true)
      : copyWith(roomId: nextRoomId, clearPlacement: true);

  /// Drops both room assignment and placement — the device falls back into
  /// the "not assigned" pool `AddDeviceDialog` offers.
  SmartHomeDevice removeFromView() =>
      copyWith(clearRoomId: true, clearPlacement: true);
}
