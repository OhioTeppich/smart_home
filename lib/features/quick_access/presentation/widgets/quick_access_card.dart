import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../rooms/application/smart_home_bloc.dart';
import '../../../rooms/application/smart_home_state.dart';
import '../../../rooms/domain/entities/smart_home_device.dart';
import '../../application/quick_access_bloc.dart';
import '../../application/quick_access_event.dart';
import '../../application/quick_access_state.dart';
import '../pages/quick_access_settings_page.dart';
import 'quick_access_cover_tile.dart';
import 'quick_access_toggle_tile.dart';

/// Uniform tile width, sized for the widest case (a Rollladen tile with
/// three inline mini buttons alongside icon + name). At the 780px reference
/// width where `HomeOverview`'s second row activates, 736px are available
/// (see `kQuickAccessMaxDevices` in `quick_access_limits.dart` for the full
/// arithmetic):
///   3 * 180 + 2 * 12 = 564 <= 736  (fits)
///   4 * 180 + 3 * 12 = 756 >  736  (would wrap)
const kQuickAccessTileWidth = 180.0;
const kQuickAccessTileGap = 12.0;

/// Renders each Schnellzugriff device as its own standalone tile — no
/// shared surrounding card, no title. Just the tiles, side by side.
class QuickAccessCard extends StatelessWidget {
  const QuickAccessCard({super.key});

  @override
  Widget build(BuildContext context) {
    final quickAccessState = context.watch<QuickAccessBloc>().state;
    final smartHomeState = context.watch<SmartHomeBloc>().state;
    final ids = quickAccessState is QuickAccessReady
        ? quickAccessState.deviceIds
        : const <String>[];
    final allDevices = smartHomeState is SmartHomeConnected
        ? smartHomeState.devices
        : const <SmartHomeDevice>[];
    final devicesById = {for (final device in allDevices) device.id: device};
    final resolved = [
      for (final id in ids)
        if (devicesById[id] case final device?) device,
    ];

    // Storage may reference a device no longer known to Home Assistant
    // (removed/renamed). Only prune once we actually have a current,
    // non-empty device list — never while HA hasn't loaded yet, otherwise
    // a cold start with an empty stream would wipe the user's whole list.
    if (allDevices.isNotEmpty && resolved.length != ids.length) {
      final staleIds = ids.where((id) => !devicesById.containsKey(id));
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        for (final staleId in staleIds) {
          context.read<QuickAccessBloc>().add(QuickAccessDeviceRemoved(staleId));
        }
      });
    }

    if (resolved.isEmpty) {
      return Row(
        children: [
          const Expanded(
            child: Text(
              'Noch keine Geräte im Schnellzugriff.',
              style: TextStyle(color: AppColors.muted, fontSize: 12),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).push<void>(
              MaterialPageRoute(builder: (_) => const QuickAccessSettingsPage()),
            ),
            child: const Text('Geräte auswählen'),
          ),
        ],
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final device in resolved) ...[
            SizedBox(
              width: kQuickAccessTileWidth,
              child: device.type == SmartHomeDeviceType.cover
                  ? QuickAccessCoverTile(device: device)
                  : QuickAccessToggleTile(device: device),
            ),
            const SizedBox(width: kQuickAccessTileGap),
          ],
        ],
      ),
    );
  }
}
