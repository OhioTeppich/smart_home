import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../rooms/application/smart_home_bloc.dart';
import '../../../rooms/application/smart_home_state.dart';
import '../../../rooms/domain/entities/smart_home_device.dart';
import '../../application/home_controller.dart';
import 'home_card.dart';

extension _HomeDeviceStyle on SmartHomeDeviceType {
  IconData get icon => switch (this) {
        SmartHomeDeviceType.lamp => Icons.light_rounded,
        SmartHomeDeviceType.bulb => Icons.lightbulb_outline_rounded,
        SmartHomeDeviceType.television => Icons.tv_rounded,
        SmartHomeDeviceType.plug => Icons.power_rounded,
        SmartHomeDeviceType.sensor => Icons.sensors_rounded,
        SmartHomeDeviceType.climate => Icons.thermostat_rounded,
        SmartHomeDeviceType.cover => Icons.blinds_rounded,
        SmartHomeDeviceType.other => Icons.devices_other_rounded,
      };

  Color get color => switch (this) {
        SmartHomeDeviceType.lamp => const Color(0xFFE7C9B7),
        SmartHomeDeviceType.bulb => const Color(0xFFF2DE9B),
        SmartHomeDeviceType.television => const Color(0xFFCFC8DA),
        SmartHomeDeviceType.plug => const Color(0xFFAECBD1),
        SmartHomeDeviceType.sensor => const Color(0xFF8BB29A),
        SmartHomeDeviceType.climate => const Color(0xFFD3AECB),
        SmartHomeDeviceType.cover => const Color(0xFFB9C2A4),
        SmartHomeDeviceType.other => const Color(0xFFD8D8D8),
      };
}

class TopDevicesCard extends StatelessWidget {
  const TopDevicesCard({super.key});

  @override
  Widget build(BuildContext context) {
    final overview = HomeScope.of(context);
    final smartHome = context.watch<SmartHomeBloc>().state;
    final allDevices = smartHome is SmartHomeConnected
        ? smartHome.devices
        : const <SmartHomeDevice>[];
    final devices = overview.rankedDevices(allDevices);
    return HomeCard(
      child: SizedBox(
        height: 214,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HomeCardTitle(
              icon: Icons.devices_other_rounded,
              title: 'Top-Geräte',
              trailing: 'Heute',
            ),
            const SizedBox(height: 5),
            DropdownButton<DeviceRanking>(
              value: overview.ranking,
              isDense: true,
              isExpanded: true,
              underline: const SizedBox.shrink(),
              items: const [
                DropdownMenuItem(
                  value: DeviceRanking.consumption,
                  child: Text('Nach Verbrauch'),
                ),
                DropdownMenuItem(
                  value: DeviceRanking.power,
                  child: Text('Nach Leistung'),
                ),
                DropdownMenuItem(
                  value: DeviceRanking.switches,
                  child: Text('Nach Schaltvorgängen'),
                ),
              ],
              onChanged: (value) {
                if (value != null) overview.setRanking(value);
              },
            ),
            const SizedBox(height: 3),
            if (devices.isEmpty)
              const Text(
                'Noch keine Geräte angelegt.',
                style: TextStyle(color: AppColors.muted, fontSize: 12),
              )
            else
              ...devices.map(
                (device) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Container(
                        width: 25,
                        height: 25,
                        decoration: BoxDecoration(
                          color: device.type.color,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(device.type.icon, size: 14),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          device.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      Text(
                        _deviceValue(device, overview.ranking),
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

String _deviceValue(SmartHomeDevice device, DeviceRanking ranking) =>
    switch (ranking) {
      DeviceRanking.consumption => '${device.dailyKwh.toStringAsFixed(2)} kWh',
      DeviceRanking.power => '${device.powerWatts.round()} W',
      DeviceRanking.switches => '${device.switchCount}×',
    };
