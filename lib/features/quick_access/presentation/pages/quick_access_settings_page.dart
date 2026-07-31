import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../rooms/application/smart_home_bloc.dart';
import '../../../rooms/application/smart_home_state.dart';
import '../../../rooms/domain/entities/smart_home_device.dart';
import '../../../rooms/presentation/widgets/smart_home_device_ui.dart';
import '../../application/quick_access_bloc.dart';
import '../../application/quick_access_event.dart';
import '../../application/quick_access_state.dart';
import '../../domain/quick_access_limits.dart';

/// Lets the user add/remove devices for the dashboard's Schnellzugriff
/// widget. Only devices already controllable elsewhere in the app
/// (schaltbare Geräte plus Rollläden) can be picked, up to
/// `kQuickAccessMaxDevices`.
class QuickAccessSettingsPage extends StatefulWidget {
  const QuickAccessSettingsPage({super.key});

  @override
  State<QuickAccessSettingsPage> createState() =>
      _QuickAccessSettingsPageState();
}

class _QuickAccessSettingsPageState extends State<QuickAccessSettingsPage> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quickAccessState = context.watch<QuickAccessBloc>().state;
    final smartHomeState = context.watch<SmartHomeBloc>().state;
    final currentIds = quickAccessState is QuickAccessReady
        ? quickAccessState.deviceIds
        : const <String>[];
    final allDevices = smartHomeState is SmartHomeConnected
        ? smartHomeState.devices
        : const <SmartHomeDevice>[];
    final devicesById = {for (final device in allDevices) device.id: device};
    final currentDevices = [
      for (final id in currentIds)
        if (devicesById[id] case final device?) device,
    ];

    final query = _query.trim().toLowerCase();
    final candidates = allDevices
        .where(
          (device) =>
              (device.canToggle || device.type == SmartHomeDeviceType.cover) &&
              !currentIds.contains(device.id) &&
              (query.isEmpty ||
                  device.name.toLowerCase().contains(query) ||
                  device.type.label.toLowerCase().contains(query)),
        )
        .toList();

    final atLimit = currentIds.length >= kQuickAccessMaxDevices;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        title: const Text('Schnellzugriff verwalten'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${currentIds.length}/$kQuickAccessMaxDevices Geräte ausgewählt',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.blueDark,
                ),
              ),
              const SizedBox(height: 16),
              if (currentDevices.isEmpty)
                const Text(
                  'Noch keine Geräte ausgewählt.',
                  style: TextStyle(color: AppColors.muted),
                )
              else
                ...currentDevices.map(
                  (device) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(device.type.icon, color: device.type.color),
                    title: Text(device.name),
                    subtitle: Text(device.type.label),
                    trailing: IconButton(
                      icon: const Icon(Icons.close_rounded),
                      tooltip: 'Entfernen',
                      onPressed: () => context.read<QuickAccessBloc>().add(
                        QuickAccessDeviceRemoved(device.id),
                      ),
                    ),
                  ),
                ),
              const Divider(height: 32),
              const Text(
                'Gerät hinzufügen',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              if (atLimit)
                Text(
                  'Maximal $kQuickAccessMaxDevices Geräte erreicht. '
                  'Zuerst ein Gerät entfernen, um ein anderes hinzuzufügen.',
                  style: const TextStyle(color: AppColors.muted),
                )
              else ...[
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Gerät suchen…',
                    prefixIcon: Icon(Icons.search),
                    isDense: true,
                  ),
                  onChanged: (value) => setState(() => _query = value),
                ),
                const SizedBox(height: 8),
                if (candidates.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'Keine passenden Geräte gefunden.',
                      style: TextStyle(color: AppColors.muted),
                    ),
                  )
                else
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 360),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: candidates.length,
                      separatorBuilder: (_, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final device = candidates[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            device.type.icon,
                            color: device.type.color,
                          ),
                          title: Text(device.name),
                          subtitle: Text(device.type.label),
                          onTap: () => context.read<QuickAccessBloc>().add(
                            QuickAccessDeviceAdded(device.id),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
