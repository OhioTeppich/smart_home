import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../application/smart_home_bloc.dart';
import '../../application/smart_home_event.dart';
import '../../application/smart_home_state.dart';
import '../../domain/entities/smart_home_device.dart';
import 'smart_home_device_ui.dart';

class RoomDeviceList extends StatelessWidget {
  const RoomDeviceList({
    required this.state,
    required this.roomId,
    required this.roomName,
    super.key,
  });
  final SmartHomeConnected state;
  final String roomId;
  final String roomName;

  @override
  Widget build(BuildContext context) {
    final devices = state.devicesFor(roomId);
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.57),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(.78)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Alle Geräte',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      roomName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${devices.length}',
                style: const TextStyle(
                  color: AppColors.muted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: devices.isEmpty
                ? const Center(
                    child: Text(
                      'Noch keine Geräte hinzugefügt',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.muted, fontSize: 12),
                    ),
                  )
                : ListView.separated(
                    primary: false,
                    padding: EdgeInsets.zero,
                    itemCount: devices.length,
                    separatorBuilder: (_, index) =>
                        const Divider(height: 1, color: AppColors.line),
                    itemBuilder: (context, index) {
                      final device = devices[index];
                      return DeviceListItem(
                        device: device,
                        onToggle: device.canToggle
                            ? (value) => context.read<SmartHomeBloc>().add(
                                SmartHomeDeviceToggled(device.id, value),
                              )
                            : null,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class DeviceListItem extends StatelessWidget {
  const DeviceListItem({
    required this.device,
    required this.onToggle,
    super.key,
  });
  final SmartHomeDevice device;
  final ValueChanged<bool>? onToggle;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: device.isOn ? device.type.color : AppColors.line,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            device.type.icon,
            size: 18,
            color: device.isOn ? AppColors.ink : AppColors.muted,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                device.name,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                device.canToggle
                    ? (device.isOn ? 'Eingeschaltet' : 'Ausgeschaltet')
                    : 'Nur Anzeige',
                style: TextStyle(
                  color: device.isOn ? AppColors.green : AppColors.muted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        if (onToggle != null)
          Switch.adaptive(value: device.isOn, onChanged: onToggle)
        else
          const Icon(
            Icons.lock_outline_rounded,
            size: 16,
            color: AppColors.muted,
          ),
      ],
    ),
  );
}
