import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'app/app_scale.dart';
import 'app/shell/app_shell.dart';
import 'features/energy/application/energy_dashboard_controller.dart';
import 'features/energy/infrastructure/repositories/in_memory_energy_repository.dart';
import 'features/rooms/application/controllers/smart_home_controller.dart';
import 'features/rooms/infrastructure/repositories/in_memory_smart_home_repository.dart';
import 'features/rooms/presentation/state/smart_home_scope.dart';
import 'features/home/application/home_controller.dart';

class SmartHomeApp extends StatelessWidget {
  const SmartHomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Home',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const SmartHomeScrollBehavior(),
      theme: AppTheme.light,
      builder: (context, child) =>
          AppScale(scale: 1.12, child: child ?? const SizedBox.shrink()),
      home: EnergyScope(
        controller: EnergyDashboardController(const InMemoryEnergyRepository()),
        child: SmartHomeScope(
          controller: SmartHomeController(InMemorySmartHomeRepository()),
          child: HomeScope(
            controller: HomeController()..start(),
            child: const AppShell(),
          ),
        ),
      ),
    );
  }
}
