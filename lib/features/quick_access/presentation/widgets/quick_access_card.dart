import 'package:equatable/equatable.dart';
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

/// Gutter between tiles in the 2x2 grid, both horizontally and vertically.
/// The Rollladen tile stacks its three mini buttons under icon + name
/// (`QuickAccessCoverTile`) instead of putting everything in one row, so the
/// buttons can stay a comfortable tap size without needing a wider tile.
const kQuickAccessTileGap = 12.0;

/// What `QuickAccessCard` actually needs out of `SmartHomeBloc`'s state,
/// derived once per emission and compared by value — narrows the widget's
/// effective rebuild trigger from "any device anywhere changed" down to
/// "one of the pinned devices changed" (via `context.select`).
class _PinnedDevicesSnapshot extends Equatable {
  const _PinnedDevicesSnapshot({
    required this.resolved,
    required this.staleIds,
    required this.hasLoaded,
  });

  final List<SmartHomeDevice> resolved;
  final List<String> staleIds;
  final bool hasLoaded;

  @override
  List<Object?> get props => [resolved, staleIds, hasLoaded];
}

/// Renders each Schnellzugriff device as its own standalone tile — no
/// shared surrounding card, no title. Just the tiles, side by side.
class QuickAccessCard extends StatelessWidget {
  const QuickAccessCard({super.key});

  @override
  Widget build(BuildContext context) {
    final ids = context.select<QuickAccessBloc, List<String>>((bloc) {
      final state = bloc.state;
      return state is QuickAccessReady ? state.deviceIds : const <String>[];
    });

    final snapshot = context.select<SmartHomeBloc, _PinnedDevicesSnapshot>((
      bloc,
    ) {
      final state = bloc.state;
      final allDevices = state is SmartHomeConnected
          ? state.devices
          : const <SmartHomeDevice>[];
      final devicesById = {for (final device in allDevices) device.id: device};
      return _PinnedDevicesSnapshot(
        resolved: [
          for (final id in ids)
            if (devicesById[id] case final device?) device,
        ],
        staleIds: [for (final id in ids) if (!devicesById.containsKey(id)) id],
        hasLoaded: allDevices.isNotEmpty,
      );
    });
    final resolved = snapshot.resolved;

    // Storage may reference a device no longer known to Home Assistant
    // (removed/renamed). Only prune once we actually have a current,
    // non-empty device list — never while HA hasn't loaded yet, otherwise
    // a cold start with an empty stream would wipe the user's whole list.
    if (snapshot.hasLoaded && resolved.length != ids.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        for (final staleId in snapshot.staleIds) {
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

    return _QuickAccessGrid(devices: resolved);
  }
}

/// Lays [devices] out as a 2-column grid (two rows of two), padding an odd
/// trailing slot with an empty cell so the grid stays balanced.
class _QuickAccessGrid extends StatelessWidget {
  const _QuickAccessGrid({required this.devices});

  final List<SmartHomeDevice> devices;

  @override
  Widget build(BuildContext context) {
    final rows = <List<SmartHomeDevice?>>[
      for (var i = 0; i < devices.length; i += 2)
        [devices[i], i + 1 < devices.length ? devices[i + 1] : null],
    ];
    return Column(
      children: [
        for (final row in rows) ...[
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _tile(row[0])),
                const SizedBox(width: kQuickAccessTileGap),
                Expanded(child: _tile(row[1])),
              ],
            ),
          ),
          if (row != rows.last) const SizedBox(height: kQuickAccessTileGap),
        ],
      ],
    );
  }

  Widget _tile(SmartHomeDevice? device) {
    if (device == null) return const SizedBox.shrink();
    return device.type == SmartHomeDeviceType.cover
        ? QuickAccessCoverTile(device: device)
        : QuickAccessToggleTile(device: device);
  }
}
