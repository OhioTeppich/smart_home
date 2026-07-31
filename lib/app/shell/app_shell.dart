import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../../features/energy/application/energy_dashboard_controller.dart';
import '../../features/energy/domain/entities/energy_point.dart';
import '../../features/energy/presentation/pages/energy_analysis_page.dart'
    as energyAnalysis;
import '../../features/energy/presentation/pages/energy_overview_page.dart'
    as energyOverview;
import '../../features/energy/presentation/widgets/energy_period_selector.dart';
import '../../features/ha_connection/presentation/pages/ha_connection_settings_page.dart';
import '../../features/home/presentation/pages/home_page.dart' as home;
import '../../features/rooms/presentation/pages/room_page.dart';
import '../../features/rooms/presentation/widgets/room_dialogs.dart';
import 'app_navigation.dart';
import 'app_navigation_bloc.dart';
import 'app_navigation_event.dart';
import 'app_section.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => AppNavigationBloc(),
    child: const _AppShellView(),
  );
}

class _AppShellView extends StatefulWidget {
  const _AppShellView();

  @override
  State<_AppShellView> createState() => _AppShellViewState();
}

class _AppShellViewState extends State<_AppShellView> {
  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 1100;
    final period = EnergyScope.of(context).period;
    final section = context.watch<AppNavigationBloc>().state.section;

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
                padding: const EdgeInsets.only(top: 96, bottom: 16),
                child: _buildPage(section, compact, period),
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
              onSectionChanged: (value) => context
                  .read<AppNavigationBloc>()
                  .add(AppNavigationSectionSelected(value)),
              trailing: _buildNavigationTrailing(section, period, compact),
              onOpenSettings: _openHaConnectionSettings,
            ),
          ),
        ],
      ),
    );
  }

  Widget? _buildNavigationTrailing(
    AppSection section,
    Period period,
    bool compact,
  ) {
    if (_isRoom(section)) {
      return _AddDeviceButton(
        compact: compact,
        onPressed: () => _addDeviceToCurrentRoom(section),
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

  Widget _buildPage(AppSection section, bool compact, Period period) =>
      switch (section) {
        AppSection.home => const home.HomePage(),
        AppSection.energy => energyOverview.OverviewPage(
          compact: compact,
          period: period,
          onDetails: () => context.read<AppNavigationBloc>().add(
            const AppNavigationSectionSelected(AppSection.energyAnalysis),
          ),
        ),
        AppSection.energyAnalysis => energyAnalysis.AnalysisPage(
          period: period,
        ),
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

  void _openHaConnectionSettings() {
    Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => const HaConnectionSettingsPage()),
    );
  }

  Future<void> _addDeviceToCurrentRoom(AppSection section) async {
    await showDialog<void>(
      context: context,
      builder: (_) => AddDeviceDialog(roomId: _roomId(section)),
    );
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
