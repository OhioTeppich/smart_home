import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/smart_home_device.dart';
import '../state/smart_home_scope.dart';
import '../widgets/room_layout.dart';

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
    final compact = MediaQuery.sizeOf(context).width < 700;
    final controller = SmartHomeScope.of(context);
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        compact ? 24 : 44,
        32,
        compact ? 24 : 52,
        42,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            roomName,
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 24),
          if (controller.isPlacing) ...[
            PlacementBanner(device: controller.pendingDevice!),
            const SizedBox(height: 12),
          ],
          RoomLayout(
            controller: controller,
            roomId: roomId,
            roomName: roomName,
            imageAsset: imageAsset,
          ),
        ],
      ),
    );
  }
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
          onPressed: SmartHomeScope.of(context).cancelPlacement,
          child: const Text('Abbrechen'),
        ),
      ],
    ),
  );
}
