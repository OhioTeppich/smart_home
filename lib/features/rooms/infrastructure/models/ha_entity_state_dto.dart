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
    return SmartHomeDevice(
      id: entityId,
      name: friendlyName ?? _humanize(entityId),
      type: _mapType(domain),
      status: _isUnavailable ? 'Nicht verfügbar' : 'Online',
      // Home Assistant does not universally expose power/energy on every
      // entity; best-effort read of common integration attribute names,
      // 0 otherwise.
      powerWatts: _numericAttribute('current_power_w') ?? 0,
      dailyKwh: _numericAttribute('today_energy_kwh') ?? 0,
      lastUpdated: 'gerade eben',
      roomId: roomId,
      isOn: _deriveIsOn(),
    );
  }

  bool get _isUnavailable => state == 'unavailable' || state == 'unknown';

  double? _numericAttribute(String key) {
    final value = attributes[key];
    return value is num ? value.toDouble() : null;
  }

  bool _deriveIsOn() {
    if (_isUnavailable) return false;
    if (domain == 'media_player') return state != 'off' && state != 'idle';
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
