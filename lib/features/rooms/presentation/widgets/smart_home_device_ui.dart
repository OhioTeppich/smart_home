import 'package:flutter/material.dart';

import '../../domain/entities/smart_home_device.dart';

extension SmartHomeDeviceUi on SmartHomeDeviceType {
  IconData get icon => switch (this) {
    SmartHomeDeviceType.lamp => Icons.light_rounded,
    SmartHomeDeviceType.bulb => Icons.lightbulb_outline_rounded,
    SmartHomeDeviceType.television => Icons.tv_rounded,
    SmartHomeDeviceType.plug => Icons.power_rounded,
    SmartHomeDeviceType.sensor => Icons.sensors_rounded,
    SmartHomeDeviceType.other => Icons.devices_other_rounded,
  };

  Color get color => switch (this) {
    SmartHomeDeviceType.lamp => const Color(0xFFE7C9B7),
    SmartHomeDeviceType.bulb => const Color(0xFFF2DE9B),
    SmartHomeDeviceType.television => const Color(0xFFCFC8DA),
    SmartHomeDeviceType.plug => const Color(0xFFAECBD1),
    SmartHomeDeviceType.sensor => const Color(0xFF8BB29A),
    SmartHomeDeviceType.other => const Color(0xFFD8D8D8),
  };
}
