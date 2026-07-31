import 'package:flutter/material.dart';

import '../../application/smart_home_state.dart';
import 'room_device_list.dart';
import 'room_map.dart';

class RoomLayout extends StatelessWidget {
  const RoomLayout({
    required this.state,
    required this.roomId,
    required this.roomName,
    this.imageAsset,
    super.key,
  });
  final SmartHomeConnected state;
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
        child: RoomDeviceList(state: state, roomId: roomId, roomName: roomName),
      );

      if (sideBySide) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: mapCardWidth,
              child: RoomMap(
                state: state,
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
            state: state,
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
