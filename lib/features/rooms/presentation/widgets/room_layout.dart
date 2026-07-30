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
      const minimumListWidth = 300.0;
      const gap = 18.0;
      final sideBySide = constraints.maxWidth >= 1050;
      final mapCardWidth = sideBySide
          ? (constraints.maxWidth - minimumListWidth - gap > 900
                ? 900.0
                : constraints.maxWidth - minimumListWidth - gap)
          : constraints.maxWidth;
      final listWidth = sideBySide
          ? constraints.maxWidth - mapCardWidth - gap
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
