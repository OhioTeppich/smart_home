import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../rooms/application/smart_home_bloc.dart';
import '../../../rooms/application/smart_home_event.dart';
import '../../../rooms/domain/entities/cover_action.dart';
import '../../../rooms/domain/entities/smart_home_device.dart';
import '../../../rooms/presentation/widgets/smart_home_device_ui.dart';

/// Compact dashboard tile for a Rollladen (cover): icon, name and three
/// inline mini buttons (auf/stop/zu) — smaller than the full-size buttons
/// `CoverControlRow` uses in the room device dialog, to fit a dashboard tile.
class QuickAccessCoverTile extends StatelessWidget {
  const QuickAccessCoverTile({required this.device, super.key});

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
        _MiniCoverButton(
          icon: Icons.keyboard_arrow_up_rounded,
          tooltip: 'Öffnen',
          onTap: () => context.read<SmartHomeBloc>().add(
            SmartHomeCoverActionRequested(device.id, CoverAction.open),
          ),
        ),
        const SizedBox(width: 3),
        _MiniCoverButton(
          icon: Icons.stop_rounded,
          tooltip: 'Stopp',
          onTap: () => context.read<SmartHomeBloc>().add(
            SmartHomeCoverActionRequested(device.id, CoverAction.stop),
          ),
        ),
        const SizedBox(width: 3),
        _MiniCoverButton(
          icon: Icons.keyboard_arrow_down_rounded,
          tooltip: 'Schließen',
          onTap: () => context.read<SmartHomeBloc>().add(
            SmartHomeCoverActionRequested(device.id, CoverAction.close),
          ),
        ),
      ],
    ),
  );
}

class _MiniCoverButton extends StatelessWidget {
  const _MiniCoverButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: SizedBox(
      width: 22,
      height: 22,
      child: Material(
        color: AppColors.line.withOpacity(.7),
        borderRadius: BorderRadius.circular(7),
        child: InkWell(
          borderRadius: BorderRadius.circular(7),
          onTap: onTap,
          child: Icon(icon, size: 13, color: AppColors.ink),
        ),
      ),
    ),
  );
}
