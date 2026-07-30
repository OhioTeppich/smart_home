import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class AppColors {
  static const canvas = Color(0xFFF4F7F6);
  static const surface = Color(0xFFFFFFFF);
  static const ink = Color(0xFF171C1B);
  static const muted = Color(0xFF7B8885);
  static const line = Color(0xFFE5EBE9);
  static const blue = Color(0xFFAECBD1);
  static const blueDark = Color(0xFF4D7379);
  static const peach = Color(0xFFE7C9B7);
  static const lavender = Color(0xFFCFC8DA);
  static const green = Color(0xFF8BB29A);
  static const brown = Color(0xFF735C4F);
}

class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.canvas,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.ink,
      brightness: Brightness.light,
    ),
    fontFamily: 'Arial',
  );
}

class SmartHomeScrollBehavior extends MaterialScrollBehavior {
  const SmartHomeScrollBehavior();

  @override
  Set<ui.PointerDeviceKind> get dragDevices => {
    ui.PointerDeviceKind.touch,
    ui.PointerDeviceKind.mouse,
    ui.PointerDeviceKind.stylus,
  };
}
