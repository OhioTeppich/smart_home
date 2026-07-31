import 'package:flutter/material.dart';

import '../../domain/entities/smart_home_device.dart';
import 'room_device_list.dart';
import 'room_map.dart';

class RoomLayout extends StatelessWidget {
  const RoomLayout({
    required this.devices,
    required this.isPlacing,
    required this.roomId,
    required this.roomName,
    this.imageAsset,
    super.key,
  });
  final List<SmartHomeDevice> devices;
  final bool isPlacing;
  final String roomId;
  final String roomName;
  final String? imageAsset;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      const gap = 18.0;
      final sideBySide = constraints.maxWidth >= 760;
      final availableWidth = sideBySide
          ? constraints.maxWidth - gap
          : constraints.maxWidth;
      final mapCardWidth = sideBySide
          ? availableWidth * 0.75
          : constraints.maxWidth;
      final listWidth = sideBySide
          ? availableWidth * 0.25
          : constraints.maxWidth;
      final cardHeight = (mapCardWidth - 44) / 1.5 + 44;
      final list = SizedBox(
        width: listWidth,
        height: cardHeight,
        child: RoomDeviceList(devices: devices, roomName: roomName),
      );

      if (sideBySide) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: mapCardWidth,
              child: RoomMap(
                devices: devices,
                isPlacing: isPlacing,
                roomId: roomId,
                roomName: roomName,
                imageAsset: imageAsset,
              ),
            ),
            const SizedBox(width: gap),
            list,
          ],
        );
      }
      return Column(
        children: [
          RoomMap(
            devices: devices,
            isPlacing: isPlacing,
            roomId: roomId,
            roomName: roomName,
            imageAsset: imageAsset,
          ),
          const SizedBox(height: gap),
          list,
        ],
      );
    },
  );
}
