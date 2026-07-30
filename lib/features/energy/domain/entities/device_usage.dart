import 'package:flutter/material.dart';

class DeviceUsage {
  const DeviceUsage({
    required this.name,
    required this.kwh,
    required this.share,
    required this.icon,
    required this.color,
  });

  final String name;
  final double kwh;
  final int share;
  final IconData icon;
  final Color color;
}
