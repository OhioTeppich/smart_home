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
    final compact = MediaQuery.sizeOf(context).width < 980;
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
                padding: EdgeInsets.only(top: compact ? 92 : 104),
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
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.64),
            borderRadius: BorderRadius.circular(22),
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
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '30. Juli 2026',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
              Container(width: 1, height: 28, color: AppColors.line),
              const SizedBox(width: 12),
              _NavItem(
                icon: Icons.grid_view_rounded,
                label: 'Home',
                selected: section == AppSection.home,
                compact: compact,
                onTap: () => onSectionChanged(AppSection.home),
              ),
              const SizedBox(width: 5),
              _NavItem(
                icon: Icons.bolt_rounded,
                label: 'Energie',
                selected:
                    section == AppSection.energy ||
                    section == AppSection.energyAnalysis,
                compact: compact,
                onTap: () => onSectionChanged(AppSection.energy),
              ),
              const SizedBox(width: 5),
              _NavItem(
                icon: Icons.weekend_rounded,
                label: 'Wohnzimmer',
                selected: section == AppSection.livingRoom,
                compact: compact,
                onTap: () => onSectionChanged(AppSection.livingRoom),
              ),
              const SizedBox(width: 5),
              _NavItem(
                icon: Icons.bedroom_parent_outlined,
                label: 'Schlafzimmer',
                selected: section == AppSection.bedroom,
                compact: compact,
                onTap: () => onSectionChanged(AppSection.bedroom),
              ),
              const SizedBox(width: 5),
              _NavItem(
                icon: Icons.kitchen_outlined,
                label: 'Küche',
                selected: section == AppSection.kitchen,
                compact: compact,
                onTap: () => onSectionChanged(AppSection.kitchen),
              ),
              const SizedBox(width: 5),
              _NavItem(
                icon: Icons.bathtub_outlined,
                label: 'Bad',
                selected: section == AppSection.bathroom,
                compact: compact,
                onTap: () => onSectionChanged(AppSection.bathroom),
              ),
              const SizedBox(width: 5),
              _NavItem(
                icon: Icons.door_front_door_outlined,
                label: 'Flur',
                selected: section == AppSection.hallway,
                compact: compact,
                onTap: () => onSectionChanged(AppSection.hallway),
              ),
              const Spacer(),
              if (trailing != null) ...[
                Container(width: 1, height: 28, color: AppColors.line),
                const SizedBox(width: 15),
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
      height: 44,
      padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 14),
      decoration: BoxDecoration(
        color: selected ? AppColors.ink : Colors.transparent,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: selected ? Colors.white : AppColors.muted,
          ),
          if (!compact) ...[
            const SizedBox(width: 9),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.muted,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    ),
  );
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
          icon: const Icon(Icons.add_rounded),
          color: Colors.white,
          style: IconButton.styleFrom(
            backgroundColor: AppColors.ink,
            foregroundColor: Colors.white,
          ),
        )
      : FilledButton.icon(
          onPressed: onPressed,
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Gerät hinzufügen'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.ink,
            foregroundColor: Colors.white,
          ),
        );
}
