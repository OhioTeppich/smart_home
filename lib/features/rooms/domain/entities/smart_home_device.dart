enum SmartHomeDeviceType { lamp, bulb, television, plug, sensor, other }

extension SmartHomeDeviceTypeLabel on SmartHomeDeviceType {
  String get label => switch (this) {
    SmartHomeDeviceType.lamp => 'Lampe',
    SmartHomeDeviceType.bulb => 'Smart-Birne',
    SmartHomeDeviceType.television => 'Fernseher',
    SmartHomeDeviceType.plug => 'Steckdose',
    SmartHomeDeviceType.sensor => 'Sensor',
    SmartHomeDeviceType.other => 'Sonstiges',
  };
}

class SmartHomeDevice {
  const SmartHomeDevice({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.powerWatts,
    required this.dailyKwh,
    required this.lastUpdated,
    this.switchCount = 0,
    this.isOn = true,
    this.x,
    this.y,
  });

  final String id;
  final String name;
  final SmartHomeDeviceType type;
  final String status;
  final double powerWatts;
  final double dailyKwh;
  final String lastUpdated;
  final int switchCount;
  final bool isOn;
  final double? x;
  final double? y;

  bool get canToggle => switch (type) {
    SmartHomeDeviceType.lamp ||
    SmartHomeDeviceType.bulb ||
    SmartHomeDeviceType.television ||
    SmartHomeDeviceType.plug => true,
    SmartHomeDeviceType.sensor || SmartHomeDeviceType.other => false,
  };

  SmartHomeDevice withPowerState(bool nextIsOn) => SmartHomeDevice(
    id: id,
    name: name,
    type: type,
    status: status,
    powerWatts: powerWatts,
    dailyKwh: dailyKwh,
    lastUpdated: 'gerade eben',
    switchCount: switchCount + 1,
    isOn: nextIsOn,
    x: x,
    y: y,
  );

  SmartHomeDevice placeAt(double nextX, double nextY) => SmartHomeDevice(
    id: id,
    name: name,
    type: type,
    status: status,
    powerWatts: powerWatts,
    dailyKwh: dailyKwh,
    lastUpdated: lastUpdated,
    switchCount: switchCount,
    isOn: isOn,
    x: nextX.clamp(0.04, 0.96).toDouble(),
    y: nextY.clamp(0.06, 0.94).toDouble(),
  );
}
