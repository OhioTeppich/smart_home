import '../../domain/entities/smart_home_device.dart';

class HaEntityStateDto {
  const HaEntityStateDto({
    required this.entityId,
    required this.state,
    required this.attributes,
  });

  factory HaEntityStateDto.fromJson(Map<String, dynamic> json) =>
      HaEntityStateDto(
        entityId: json['entity_id'] as String,
        state: json['state'] as String? ?? 'unknown',
        attributes:
            (json['attributes'] as Map?)?.cast<String, dynamic>() ??
            const {},
      );

  final String entityId;
  final String state;
  final Map<String, dynamic> attributes;

  String get domain => entityId.split('.').first;

  /// [roomId] is the already-resolved room (area alias heuristic or manual
  /// override) — this DTO only knows about the raw Home Assistant state.
  ///
  /// [companionPowerWatts]/[companionDailyKwh] let the repository fold in a
  /// sibling `sensor.*` entity's reading (same Home Assistant device, e.g. a
  /// Shelly plug's separate "Leistung"/"Energie" sensor) when this entity
  /// reports no power/energy of its own — see
  /// `HomeAssistantSmartHomeRepository._buildDevice`.
  SmartHomeDevice toDomain({
    required String? roomId,
    double? companionPowerWatts,
    double? companionDailyKwh,
    bool companionDailyKwhIsCumulative = false,
  }) {
    final friendlyName = attributes['friendly_name'] as String?;
    final resolvedDailyKwh = ownDailyKwh;
    return SmartHomeDevice(
      id: entityId,
      name: friendlyName ?? _humanize(entityId),
      type: _mapType(domain),
      status: _isUnavailable ? 'Nicht verfügbar' : 'Online',
      powerWatts: ownPowerWatts ?? companionPowerWatts ?? 0,
      dailyKwh: resolvedDailyKwh ?? companionDailyKwh ?? 0,
      dailyKwhIsCumulative: resolvedDailyKwh != null
          ? ownDailyKwhIsCumulative
          : companionDailyKwhIsCumulative,
      lastUpdated: 'gerade eben',
      roomId: roomId,
      isOn: _deriveIsOn(),
      coverPosition: domain == 'cover'
          ? _numericAttribute('current_position')
          : null,
      coverRawState: domain == 'cover' ? state : null,
    );
  }

  /// Best-effort read of common integration attribute names on the entity
  /// itself, falling back to a standalone `sensor.*` entity's own state
  /// (device_class power — the pattern most power-monitoring plugs, e.g.
  /// Shelly, actually use). `null` if this entity reports no power at all.
  double? get ownPowerWatts => _numericAttribute('current_power_w') ?? _sensorPowerWatts;

  /// Same idea for today's energy consumption. `null` if this entity
  /// reports none.
  double? get ownDailyKwh => _numericAttribute('today_energy_kwh') ?? _sensorEnergyKwh;

  bool get ownDailyKwhIsCumulative =>
      _numericAttribute('today_energy_kwh') == null &&
      _sensorEnergyKwh != null &&
      _isCumulativeEnergy;

  /// A standalone `sensor.*` entity reporting instantaneous power draw
  /// (device_class `power`) — the companion-sensor half of a Shelly-style
  /// plug/switch pairing that `HomeAssistantSmartHomeRepository` folds back
  /// into its sibling device.
  bool get isPowerSensor => domain == 'sensor' && _deviceClass == 'power';

  /// Same idea for a standalone energy-consumption sensor (device_class
  /// `energy`).
  bool get isEnergySensor => domain == 'sensor' && _deviceClass == 'energy';

  bool get _isUnavailable => state == 'unavailable' || state == 'unknown';

  double? _numericAttribute(String key) {
    final value = attributes[key];
    return value is num ? value.toDouble() : null;
  }

  String? get _deviceClass => attributes['device_class'] as String?;
  String? get _unitOfMeasurement =>
      attributes['unit_of_measurement'] as String?;
  bool get _isCumulativeEnergy => attributes['state_class'] == 'total_increasing';

  /// A standalone power-monitoring `sensor.*` entity (device_class `power`)
  /// reports its wattage as its own state, not as an attribute on some
  /// other entity.
  double? get _sensorPowerWatts {
    if (domain != 'sensor' || _deviceClass != 'power') return null;
    final value = double.tryParse(state);
    if (value == null) return null;
    return _unitOfMeasurement == 'kW' ? value * 1000 : value;
  }

  /// Same idea for energy (device_class `energy`) — commonly a lifetime
  /// meter reading (`state_class: total_increasing`), see
  /// [SmartHomeDevice.dailyKwhIsCumulative].
  double? get _sensorEnergyKwh {
    if (domain != 'sensor' || _deviceClass != 'energy') return null;
    final value = double.tryParse(state);
    if (value == null) return null;
    return switch (_unitOfMeasurement) {
      'Wh' => value / 1000,
      'MWh' => value * 1000,
      _ => value,
    };
  }

  bool _deriveIsOn() {
    if (_isUnavailable) return false;
    if (domain == 'media_player') return state != 'off' && state != 'idle';
    if (domain == 'cover') return state == 'open' || state == 'opening';
    return state == 'on';
  }

  static SmartHomeDeviceType _mapType(String domain) => switch (domain) {
    'light' => SmartHomeDeviceType.bulb,
    'switch' => SmartHomeDeviceType.plug,
    'media_player' => SmartHomeDeviceType.television,
    'sensor' || 'binary_sensor' => SmartHomeDeviceType.sensor,
    'climate' => SmartHomeDeviceType.climate,
    'cover' => SmartHomeDeviceType.cover,
    _ => SmartHomeDeviceType.other,
  };

  static String _humanize(String entityId) {
    final slug = entityId.split('.').skip(1).join('.');
    final words = slug
        .split(RegExp('[_.]'))
        .where((word) => word.isNotEmpty);
    if (words.isEmpty) return entityId;
    return words
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
