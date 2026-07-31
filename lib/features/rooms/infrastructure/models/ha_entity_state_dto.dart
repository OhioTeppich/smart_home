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
  SmartHomeDevice toDomain({required String? roomId}) {
    final friendlyName = attributes['friendly_name'] as String?;
    final attributeEnergy = _numericAttribute('today_energy_kwh');
    final sensorEnergy = _sensorEnergyKwh;
    return SmartHomeDevice(
      id: entityId,
      name: friendlyName ?? _humanize(entityId),
      type: _mapType(domain),
      status: _isUnavailable ? 'Nicht verfügbar' : 'Online',
      // Home Assistant does not universally expose power/energy on every
      // entity; best-effort read of common integration attribute names on
      // the entity itself, falling back to a standalone `sensor.*` entity's
      // own state (device_class power/energy — the pattern most
      // power-monitoring plugs, e.g. Shelly, actually use) — 0 otherwise.
      powerWatts: _numericAttribute('current_power_w') ?? _sensorPowerWatts ?? 0,
      dailyKwh: attributeEnergy ?? sensorEnergy ?? 0,
      dailyKwhIsCumulative:
          attributeEnergy == null && sensorEnergy != null && _isCumulativeEnergy,
      lastUpdated: 'gerade eben',
      roomId: roomId,
      isOn: _deriveIsOn(),
      coverPosition: domain == 'cover'
          ? _numericAttribute('current_position')
          : null,
      coverRawState: domain == 'cover' ? state : null,
    );
  }

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
