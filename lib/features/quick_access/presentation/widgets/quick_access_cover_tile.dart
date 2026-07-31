import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../rooms/application/smart_home_bloc.dart';
import '../../../rooms/application/smart_home_event.dart';
import '../../../rooms/domain/entities/cover_action.dart';
import '../../../rooms/domain/entities/smart_home_device.dart';
import '../../../rooms/presentation/widgets/smart_home_device_ui.dart';

/// Compact dashboard tile for a Rollladen (cover): icon + name on top, three
/// mini buttons (auf/stop/zu) stacked below spanning the full tile width —
/// keeps the buttons a comfortable tap size without widening the tile, since
/// `QuickAccessCard` sizes every tile the same regardless of device type.
class QuickAccessCoverTile extends StatelessWidget {
  const QuickAccessCoverTile({required this.device, super.key});

  final SmartHomeDevice device;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    decoration: BoxDecoration(
      color: device.type.color.withOpacity(.18),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: device.type.color.withOpacity(.35)),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
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
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _MiniCoverButton(
              icon: Icons.keyboard_arrow_up_rounded,
              tooltip: 'Öffnen',
              onTap: () => context.read<SmartHomeBloc>().add(
                SmartHomeCoverActionRequested(device.id, CoverAction.open),
              ),
            ),
            _MiniCoverButton(
              icon: Icons.stop_rounded,
              tooltip: 'Stopp',
              onTap: () => context.read<SmartHomeBloc>().add(
                SmartHomeCoverActionRequested(device.id, CoverAction.stop),
              ),
            ),
            _MiniCoverButton(
              icon: Icons.keyboard_arrow_down_rounded,
              tooltip: 'Schließen',
              onTap: () => context.read<SmartHomeBloc>().add(
                SmartHomeCoverActionRequested(device.id, CoverAction.close),
              ),
            ),
          ],
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
      width: 34,
      height: 34,
      child: Material(
        color: AppColors.line.withOpacity(.7),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Icon(icon, size: 18, color: AppColors.ink),
        ),
      ),
    ),
  );
}
