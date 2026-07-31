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
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    decoration: BoxDecoration(
      color: device.type.color.withOpacity(.18),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: device.type.color.withOpacity(.35)),
    ),
    child: Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: device.type.color,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(device.type.icon, size: 12),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            device.name,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
          ),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 34,
          height: 20,
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
