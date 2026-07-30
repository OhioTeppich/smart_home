import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../application/smart_home_bloc.dart';
import '../../application/smart_home_event.dart';
import '../../application/smart_home_state.dart';
import '../../domain/entities/smart_home_device.dart';
import 'room_dialogs.dart';
import 'smart_home_device_ui.dart';

class RoomMap extends StatelessWidget {
  const RoomMap({
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
  Widget build(BuildContext context) {
    final placedDevices = state
        .devicesFor(roomId)
        .where((device) => device.isPlaced)
        .toList();
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.57),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(.78)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = width / 1.5;
          return SizedBox(
            width: width,
            height: height,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (imageAsset != null)
                    Image.asset(imageAsset!, fit: BoxFit.cover)
                  else
                    RoomPlaceholder(roomName: roomName),
                  if (state.isPlacing)
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapUp: (details) => context.read<SmartHomeBloc>().add(
                        SmartHomePlacementConfirmed(
                          details.localPosition.dx / width,
                          details.localPosition.dy / height,
                        ),
                      ),
                      child: Container(
                        color: AppColors.blueDark.withOpacity(.08),
                      ),
                    ),
                  if (placedDevices.isEmpty && !state.isPlacing)
                    const Center(child: EmptyMapHint()),
                  ...placedDevices.map(
                    (device) => Positioned(
                      left: device.x! * width - 24,
                      top: device.y! * height - 24,
                      child: DeviceMarker(device: device, roomId: roomId),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class RoomPlaceholder extends StatelessWidget {
  const RoomPlaceholder({required this.roomName, super.key});
  final String roomName;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFEAF1F0), Color(0xFFD7E4E5)],
      ),
    ),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            size: 38,
            color: AppColors.blueDark.withOpacity(.7),
          ),
          const SizedBox(height: 10),
          Text(
            'Kein Bild für $roomName',
            style: const TextStyle(
              color: AppColors.blueDark,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Geräte können trotzdem platziert werden',
            style: TextStyle(color: AppColors.muted, fontSize: 12),
          ),
        ],
      ),
    ),
  );
}

class EmptyMapHint extends StatelessWidget {
  const EmptyMapHint({super.key});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(.9),
      borderRadius: BorderRadius.circular(15),
    ),
    child: const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.add_location_alt_outlined, color: AppColors.blueDark),
        SizedBox(width: 9),
        SizedBox(
          width: 280,
          child: Text(
            'Füge ein Gerät hinzu, um es hier zu platzieren',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
}

class DeviceMarker extends StatefulWidget {
  const DeviceMarker({required this.device, required this.roomId, super.key});
  final SmartHomeDevice device;
  final String roomId;
  @override
  State<DeviceMarker> createState() => _DeviceMarkerState();
}

class _DeviceMarkerState extends State<DeviceMarker> {
  bool hovering = false;
  @override
  Widget build(BuildContext context) {
    final device = widget.device;
    final isOn = device.isOn;
    return MouseRegion(
      onEnter: (_) => setState(() => hovering = true),
      onExit: (_) => setState(() => hovering = false),
      child: AnimatedScale(
        scale: hovering ? 1.08 : 1,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Semantics(
              button: true,
              label:
                  '${device.name}, ${isOn ? 'eingeschaltet' : 'ausgeschaltet'}',
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isOn ? device.type.color : AppColors.line,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isOn ? Colors.white : AppColors.muted,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(hovering ? .22 : .12),
                      blurRadius: hovering ? 14 : 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    splashColor: AppColors.blueDark.withOpacity(.24),
                    highlightColor: AppColors.blue.withOpacity(.18),
                    onTap: () => showDialog<void>(
                      context: context,
                      builder: (_) => DeviceInfoDialog(
                        device: device,
                        roomId: widget.roomId,
                      ),
                    ),
                    child: Icon(
                      device.type.icon,
                      color: isOn ? AppColors.ink : AppColors.muted,
                      size: 23,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: -3,
              top: -3,
              child: Container(
                width: 17,
                height: 17,
                decoration: BoxDecoration(
                  color: isOn ? AppColors.green : AppColors.muted,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Icon(
                  isOn ? Icons.power_rounded : Icons.power_off_rounded,
                  size: 9,
                  color: Colors.white,
                ),
              ),
            ),
            if (hovering)
              Positioned(
                bottom: 57,
                left: -45,
                child: HoverInfo(device: device),
              ),
          ],
        ),
      ),
    );
  }
}

class HoverInfo extends StatelessWidget {
  const HoverInfo({required this.device, super.key});
  final SmartHomeDevice device;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(.94),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColors.blue.withOpacity(.7)),
      boxShadow: [
        BoxShadow(
          color: AppColors.blueDark.withOpacity(.16),
          blurRadius: 12,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          device.isOn ? Icons.power_rounded : Icons.power_off_rounded,
          size: 13,
          color: device.isOn ? AppColors.green : AppColors.muted,
        ),
        const SizedBox(width: 6),
        Text(
          '${device.name} · ${device.isOn ? 'An' : 'Aus'}',
          style: const TextStyle(
            color: AppColors.ink,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}
