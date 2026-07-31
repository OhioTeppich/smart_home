import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../rooms/application/smart_home_bloc.dart';
import '../../../rooms/application/smart_home_event.dart';
import '../../../rooms/domain/entities/smart_home_device.dart';
import '../../../rooms/presentation/widgets/smart_home_device_ui.dart';

/// Compact dashboard tile for a toggleable device (Lampe/Birne/Fernseher/
/// Steckdose): icon, name and an inline on/off switch — no dialog needed.
class QuickAccessToggleTile extends StatelessWidget {
  const QuickAccessToggleTile({required this.device, super.key});

  final SmartHomeDevice device;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    decoration: BoxDecoration(
      color: device.type.color.withOpacity(.18),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: device.type.color.withOpacity(.35)),
    ),
    child: Row(
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: device.type.color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(device.type.icon, size: 16),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            device.name,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 40,
          height: 24,
          child: FittedBox(
            fit: BoxFit.fill,
            child: Switch.adaptive(
              value: device.isOn,
              onChanged: (value) => context.read<SmartHomeBloc>().add(
                SmartHomeDeviceToggled(device.id, value),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
