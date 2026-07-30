import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/device_usage.dart';
import '../../domain/entities/energy_dashboard_data.dart';
import '../../domain/entities/energy_point.dart';
import '../../domain/repositories/energy_repository.dart';

class InMemoryEnergyRepository implements EnergyRepository {
  const InMemoryEnergyRepository();

  static const _hourly = <EnergyPoint>[
    EnergyPoint('00', 0.31, 220),
    EnergyPoint('02', 0.24, 190),
    EnergyPoint('04', 0.22, 170),
    EnergyPoint('06', 0.44, 420),
    EnergyPoint('08', 0.56, 570),
    EnergyPoint('10', 0.38, 340),
    EnergyPoint('12', 0.61, 640),
    EnergyPoint('14', 0.49, 480),
    EnergyPoint('16', 0.72, 760),
    EnergyPoint('18', 0.93, 980),
    EnergyPoint('20', 0.76, 810),
    EnergyPoint('22', 0.48, 470),
  ];

  static const _week = <EnergyPoint>[
    EnergyPoint('Mo', 7.8, 980),
    EnergyPoint('Di', 8.6, 1050),
    EnergyPoint('Mi', 6.9, 840),
    EnergyPoint('Do', 9.4, 1190),
    EnergyPoint('Fr', 8.1, 1020),
    EnergyPoint('Sa', 10.2, 1320),
    EnergyPoint('So', 7.4, 910),
  ];

  static const _month = <EnergyPoint>[
    EnergyPoint('1', 8.3, 980),
    EnergyPoint('5', 9.1, 1080),
    EnergyPoint('10', 7.4, 890),
    EnergyPoint('15', 9.8, 1240),
    EnergyPoint('20', 8.7, 1120),
    EnergyPoint('25', 10.1, 1310),
    EnergyPoint('30', 7.9, 970),
  ];

  static const _devices = <DeviceUsage>[
    DeviceUsage(
      name: 'Wärmepumpe',
      kwh: 1.84,
      share: 30,
      icon: Icons.thermostat_rounded,
      color: AppColors.peach,
    ),
    DeviceUsage(
      name: 'Küche',
      kwh: 1.12,
      share: 18,
      icon: Icons.restaurant_rounded,
      color: AppColors.blue,
    ),
    DeviceUsage(
      name: 'Waschmaschine',
      kwh: .86,
      share: 14,
      icon: Icons.local_laundry_service_rounded,
      color: AppColors.lavender,
    ),
    DeviceUsage(
      name: 'Unterhaltung',
      kwh: .64,
      share: 10,
      icon: Icons.tv_rounded,
      color: AppColors.green,
    ),
    DeviceUsage(
      name: 'Beleuchtung',
      kwh: .48,
      share: 8,
      icon: Icons.lightbulb_outline_rounded,
      color: AppColors.peach,
    ),
    DeviceUsage(
      name: 'Router',
      kwh: .12,
      share: 2,
      icon: Icons.router_rounded,
      color: AppColors.blue,
    ),
  ];

  @override
  EnergyDashboardData get dashboardData => const EnergyDashboardData(
    hourly: _hourly,
    week: _week,
    month: _month,
    deviceUsages: _devices,
  );
}
