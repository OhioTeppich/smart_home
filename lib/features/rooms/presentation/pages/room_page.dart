import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/horizontal_page_scaffold.dart';
import '../../../ha_connection/application/ha_connection_bloc.dart';
import '../../../ha_connection/application/ha_connection_state.dart';
import '../../../ha_connection/presentation/pages/ha_connection_settings_page.dart';
import '../../application/smart_home_bloc.dart';
import '../../application/smart_home_event.dart';
import '../../application/smart_home_state.dart';
import '../../domain/entities/smart_home_device.dart';
import '../widgets/room_layout.dart';

/// What `RoomPage` actually needs out of `SmartHomeBloc`'s state, derived
/// once per emission and compared by value via `context.select`. Narrows
/// the rebuild trigger from "any device anywhere changed" down to "this
/// room's devices, or the placement flow, changed" — without this, all six
/// room pages mounted at once in `AppShell`'s `PageView` would rebuild in
/// lockstep on every unrelated Home Assistant event.
sealed class _RoomView extends Equatable {
  const _RoomView();
}

class _RoomViewLoading extends _RoomView {
  const _RoomViewLoading();

  @override
  List<Object?> get props => [];
}

class _RoomViewError extends _RoomView {
  const _RoomViewError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class _RoomViewConnected extends _RoomView {
  const _RoomViewConnected({
    required this.devices,
    required this.isPlacing,
    required this.pendingPlacementDevice,
  });

  final List<SmartHomeDevice> devices;
  final bool isPlacing;
  final SmartHomeDevice? pendingPlacementDevice;

  @override
  List<Object?> get props => [devices, isPlacing, pendingPlacementDevice];
}

class RoomPage extends StatelessWidget {
  const RoomPage({
    this.roomId = 'livingRoom',
    this.roomName = 'Wohnzimmer',
    this.imageAsset = 'assets/images/living-room.png',
    super.key,
  });

  final String roomId;
  final String roomName;
  final String? imageAsset;

  @override
  Widget build(BuildContext context) {
    final connection = context.watch<HaConnectionBloc>().state;

    if (connection is HaConnectionReady && connection.savedConfig == null) {
      return const _RoomStatusMessage(
        icon: Icons.link_off_rounded,
        title: 'Keine Home Assistant-Verbindung',
        message:
            'Verbinde die App zuerst über die Einstellungen mit Home Assistant, '
            'um echte Geräte in diesem Raum zu sehen.',
        showSettingsAction: true,
      );
    }

    final view = context.select<SmartHomeBloc, _RoomView>((bloc) {
      final state = bloc.state;
      return switch (state) {
        SmartHomeInitial() || SmartHomeLoading() => const _RoomViewLoading(),
        SmartHomeError(:final message) => _RoomViewError(message),
        SmartHomeConnected() => _RoomViewConnected(
          devices: state.devicesFor(roomId),
          isPlacing: state.isPlacing,
          pendingPlacementDevice: state.pendingPlacement?.device,
        ),
      };
    });

    return switch (view) {
      _RoomViewLoading() => const _RoomStatusMessage(
        icon: Icons.hourglass_top_rounded,
        title: 'Verbindung wird hergestellt',
        message: 'Geräte werden von Home Assistant geladen …',
      ),
      _RoomViewError(:final message) => _RoomStatusMessage(
        icon: Icons.cloud_off_rounded,
        title: 'Verbindung unterbrochen',
        message: message,
      ),
      _RoomViewConnected(
        :final devices,
        :final isPlacing,
        :final pendingPlacementDevice,
      ) =>
        HorizontalPageScaffold(
          sections: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isPlacing) ...[
                  PlacementBanner(device: pendingPlacementDevice!),
                  const SizedBox(height: 12),
                ],
                RoomLayout(
                  devices: devices,
                  isPlacing: isPlacing,
                  roomId: roomId,
                  roomName: roomName,
                  imageAsset: imageAsset,
                ),
              ],
            ),
          ],
        ),
    };
  }
}

class _RoomStatusMessage extends StatelessWidget {
  const _RoomStatusMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.showSettingsAction = false,
  });

  final IconData icon;
  final String title;
  final String message;
  final bool showSettingsAction;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40, color: AppColors.muted),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.muted),
          ),
          if (showSettingsAction) ...[
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => Navigator.of(context).push<void>(
                MaterialPageRoute(
                  builder: (_) => const HaConnectionSettingsPage(),
                ),
              ),
              style: FilledButton.styleFrom(backgroundColor: AppColors.ink),
              child: const Text('Zu den Einstellungen'),
            ),
          ],
        ],
      ),
    ),
  );
}

class PlacementBanner extends StatelessWidget {
  const PlacementBanner({required this.device, super.key});
  final SmartHomeDevice device;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(.57),
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: Colors.white.withOpacity(.78)),
    ),
    child: Row(
      children: [
        const Icon(Icons.touch_app_rounded, color: AppColors.blueDark),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Tippe auf die Karte, um „${device.name}“ zu platzieren.',
          ),
        ),
        TextButton(
          onPressed: () => context.read<SmartHomeBloc>().add(
            const SmartHomePlacementCancelled(),
          ),
          child: const Text('Abbrechen'),
        ),
      ],
    ),
  );
}
