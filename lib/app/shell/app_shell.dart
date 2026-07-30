import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../features/energy/application/energy_dashboard_controller.dart';
import '../../features/energy/domain/entities/energy_point.dart';
import '../../features/energy/presentation/pages/energy_analysis_page.dart'
    as energyAnalysis;
import '../../features/energy/presentation/pages/energy_overview_page.dart'
    as energyOverview;
import '../../features/energy/presentation/widgets/energy_period_selector.dart';
import '../../features/home/presentation/pages/home_page.dart' as home;
import '../../features/rooms/domain/entities/smart_home_device.dart';
import '../../features/rooms/presentation/pages/room_page.dart';
import '../../features/rooms/presentation/state/smart_home_scope.dart';
import '../../features/rooms/presentation/widgets/room_dialogs.dart';

enum AppSection {
  home,
  energy,
  livingRoom,
  bedroom,
  kitchen,
  bathroom,
  hallway,
  energyAnalysis,
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  AppSection section = AppSection.home;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 1100;
    final period = EnergyScope.of(context).period;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFDDECEF),
                  AppColors.canvas,
                  Color(0xFFF7F9F8),
                ],
                stops: [0, .62, 1],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(top: compact ? 108 : 124),
                child: _buildPage(compact, period),
              ),
            ),
          ),
          Positioned(
            top: 16,
            left: compact ? 16 : 34,
            right: compact ? 16 : 34,
            child: AppNavigationBar(
              section: section,
              compact: compact,
              onSectionChanged: (value) => setState(() => section = value),
              trailing: _buildNavigationTrailing(period, compact),
            ),
          ),
        ],
      ),
    );
  }

  Widget? _buildNavigationTrailing(Period period, bool compact) {
    if (_isRoom(section)) {
      return _AddDeviceButton(
        compact: compact,
        onPressed: _addDeviceToCurrentRoom,
      );
    }
    if (section == AppSection.energy || section == AppSection.energyAnalysis) {
      return EnergyPeriodSelector(
        value: period,
        onChanged: EnergyScope.of(context).selectPeriod,
      );
    }
    if (section == AppSection.home) {
      return const _LiveClock();
    }
    return null;
  }

  Widget _buildPage(bool compact, Period period) => switch (section) {
    AppSection.home => const home.HomePage(),
    AppSection.energy => energyOverview.OverviewPage(
      compact: compact,
      period: period,
      onDetails: () => setState(() => section = AppSection.energyAnalysis),
    ),
    AppSection.energyAnalysis => energyAnalysis.AnalysisPage(period: period),
    AppSection.livingRoom => const RoomPage(),
    AppSection.bedroom => const RoomPage(
      roomId: 'bedroom',
      roomName: 'Schlafzimmer',
      imageAsset: null,
    ),
    AppSection.kitchen => const RoomPage(
      roomId: 'kitchen',
      roomName: 'Küche',
      imageAsset: null,
    ),
    AppSection.bathroom => const RoomPage(
      roomId: 'bathroom',
      roomName: 'Bad',
      imageAsset: null,
    ),
    AppSection.hallway => const RoomPage(
      roomId: 'hallway',
      roomName: 'Flur',
      imageAsset: null,
    ),
  };

  Future<void> _addDeviceToCurrentRoom() async {
    final device = await showDialog<SmartHomeDevice>(
      context: context,
      builder: (_) => const AddDeviceDialog(),
    );
    if (device != null && mounted) {
      SmartHomeScope.of(
        context,
      ).startPlacement(device, roomId: _roomId(section));
    }
  }

  bool _isRoom(AppSection value) =>
      value == AppSection.livingRoom ||
      value == AppSection.bedroom ||
      value == AppSection.kitchen ||
      value == AppSection.bathroom ||
      value == AppSection.hallway;

  String _roomId(AppSection value) => switch (value) {
    AppSection.bedroom => 'bedroom',
    AppSection.kitchen => 'kitchen',
    AppSection.bathroom => 'bathroom',
    AppSection.hallway => 'hallway',
    _ => 'livingRoom',
  };
}

class AppNavigationBar extends StatelessWidget {
  const AppNavigationBar({
    required this.section,
    required this.compact,
    required this.onSectionChanged,
    this.trailing,
    super.key,
  });

  final AppSection section;
  final bool compact;
  final ValueChanged<AppSection> onSectionChanged;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.64),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Colors.white.withOpacity(.88)),
            boxShadow: [
              BoxShadow(
                color: AppColors.blueDark.withOpacity(.09),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  '30. Juli 2026',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
              Container(width: 1, height: 34, color: AppColors.line),
              const SizedBox(width: 14),
              _NavItem(
                icon: Icons.grid_view_rounded,
                label: 'Home',
                selected: section == AppSection.home,
                compact: compact,
                onTap: () => onSectionChanged(AppSection.home),
              ),
              const SizedBox(width: 6),
              _NavItem(
                icon: Icons.bolt_rounded,
                label: 'Energie',
                selected:
                    section == AppSection.energy ||
                    section == AppSection.energyAnalysis,
                compact: compact,
                onTap: () => onSectionChanged(AppSection.energy),
              ),
              const SizedBox(width: 6),
              _RoomsNavItem(
                section: section,
                compact: compact,
                onSectionChanged: onSectionChanged,
              ),
              const Spacer(),
              if (trailing != null) ...[
                Container(width: 1, height: 34, color: AppColors.line),
                const SizedBox(width: 17),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.compact,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool selected;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(13),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: 56,
      padding: EdgeInsets.symmetric(horizontal: compact ? 14 : 17),
      decoration: BoxDecoration(
        color: selected ? AppColors.ink : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 22,
            color: selected ? Colors.white : AppColors.muted,
          ),
          if (!compact) ...[
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.muted,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

class _RoomSpec {
  const _RoomSpec(this.section, this.icon, this.label);
  final AppSection section;
  final IconData icon;
  final String label;
}

const _rooms = [
  _RoomSpec(AppSection.livingRoom, Icons.weekend_rounded, 'Wohnzimmer'),
  _RoomSpec(AppSection.bedroom, Icons.bedroom_parent_outlined, 'Schlafzimmer'),
  _RoomSpec(AppSection.kitchen, Icons.kitchen_outlined, 'Küche'),
  _RoomSpec(AppSection.bathroom, Icons.bathtub_outlined, 'Bad'),
  _RoomSpec(AppSection.hallway, Icons.door_front_door_outlined, 'Flur'),
];

class _RoomsNavItem extends StatefulWidget {
  const _RoomsNavItem({
    required this.section,
    required this.compact,
    required this.onSectionChanged,
  });

  final AppSection section;
  final bool compact;
  final ValueChanged<AppSection> onSectionChanged;

  @override
  State<_RoomsNavItem> createState() => _RoomsNavItemState();
}

class _RoomsNavItemState extends State<_RoomsNavItem> {
  final _overlayController = OverlayPortalController();
  final _link = LayerLink();

  bool get _isRoomSection =>
      _rooms.any((room) => room.section == widget.section);

  void _select(AppSection section) {
    widget.onSectionChanged(section);
    _overlayController.hide();
  }

  @override
  Widget build(BuildContext context) {
    final selected = _isRoomSection;
    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _overlayController,
        overlayChildBuilder: (context) => Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _overlayController.hide,
              ),
            ),
            CompositedTransformFollower(
              link: _link,
              showWhenUnlinked: false,
              offset: const Offset(0, 64),
              child: _RoomsDropdownPanel(
                current: widget.section,
                onSelect: _select,
              ),
            ),
          ],
        ),
        child: InkWell(
          onTap: _overlayController.toggle,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 56,
            padding: EdgeInsets.symmetric(
              horizontal: widget.compact ? 14 : 17,
            ),
            decoration: BoxDecoration(
              color: selected ? AppColors.ink : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.other_houses_rounded,
                  size: 22,
                  color: selected ? Colors.white : AppColors.muted,
                ),
                if (!widget.compact) ...[
                  const SizedBox(width: 10),
                  Text(
                    'Räume',
                    style: TextStyle(
                      color: selected ? Colors.white : AppColors.muted,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.expand_more_rounded,
                    size: 20,
                    color: selected ? Colors.white : AppColors.muted,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoomsDropdownPanel extends StatelessWidget {
  const _RoomsDropdownPanel({required this.current, required this.onSelect});

  final AppSection current;
  final ValueChanged<AppSection> onSelect;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Material(
        color: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              width: 240,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.88),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(.9)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.blueDark.withOpacity(.12),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final room in _rooms)
                    _RoomsDropdownItem(
                      room: room,
                      selected: room.section == current,
                      onTap: () => onSelect(room.section),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoomsDropdownItem extends StatelessWidget {
  const _RoomsDropdownItem({
    required this.room,
    required this.selected,
    required this.onTap,
  });

  final _RoomSpec room;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(13),
    child: Container(
      width: double.infinity,
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: selected ? AppColors.ink : Colors.transparent,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          Icon(
            room.icon,
            size: 20,
            color: selected ? Colors.white : AppColors.muted,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              room.label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.ink,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _LiveClock extends StatefulWidget {
  const _LiveClock();

  @override
  State<_LiveClock> createState() => _LiveClockState();
}

class _LiveClockState extends State<_LiveClock> {
  late Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hh = _now.hour.toString().padLeft(2, '0');
    final mm = _now.minute.toString().padLeft(2, '0');
    final ss = _now.second.toString().padLeft(2, '0');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Text(
        '$hh:$mm:$ss',
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 15,
          fontFeatures: [ui.FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

class _AddDeviceButton extends StatelessWidget {
  const _AddDeviceButton({required this.compact, required this.onPressed});
  final bool compact;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => compact
      ? IconButton(
          onPressed: onPressed,
          tooltip: 'Gerät hinzufügen',
          icon: const Icon(Icons.add_rounded, size: 22),
          color: Colors.white,
          style: IconButton.styleFrom(
            backgroundColor: AppColors.ink,
            foregroundColor: Colors.white,
            minimumSize: const Size(48, 48),
          ),
        )
      : FilledButton.icon(
          onPressed: onPressed,
          icon: const Icon(Icons.add_rounded, size: 20),
          label: const Text('Gerät hinzufügen'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.ink,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            textStyle: const TextStyle(fontSize: 14),
          ),
        );
}
