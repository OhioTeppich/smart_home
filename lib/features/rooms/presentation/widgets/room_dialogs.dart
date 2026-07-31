import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../application/smart_home_bloc.dart';
import '../../application/smart_home_event.dart';
import '../../application/smart_home_state.dart';
import '../../domain/entities/cover_action.dart';
import '../../domain/entities/smart_home_device.dart';
import 'smart_home_device_ui.dart';

const _roomLabels = <String, String>{
  'livingRoom': 'Wohnzimmer',
  'bedroom': 'Schlafzimmer',
  'kitchen': 'Küche',
  'bathroom': 'Bad',
  'hallway': 'Flur',
};

/// The devices `AddDeviceDialog` offers, compared by value via
/// `context.select` so it only rebuilds when this filtered set actually
/// changes, not on every unrelated Home Assistant event.
class _AvailableDevices extends Equatable {
  const _AvailableDevices(this.devices);

  final List<SmartHomeDevice> devices;

  @override
  List<Object?> get props => [devices];
}

/// Devices are never invented by hand anymore — Home Assistant is the only
/// source of device existence. This dialog just lets the user place an
/// already-assigned-but-unplaced device from [roomId] onto the room map.
class AddDeviceDialog extends StatefulWidget {
  const AddDeviceDialog({required this.roomId, super.key});
  final String roomId;

  @override
  State<AddDeviceDialog> createState() => _AddDeviceDialogState();
}

class _AddDeviceDialogState extends State<AddDeviceDialog> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final available = context.select<SmartHomeBloc, _AvailableDevices>((bloc) {
      final state = bloc.state;
      final devices = state is SmartHomeConnected
          ? state.devices
                .where(
                  (device) =>
                      (device.roomId == widget.roomId ||
                          device.roomId == null) &&
                      !device.isPlaced,
                )
                .toList()
          : const <SmartHomeDevice>[];
      return _AvailableDevices(devices);
    }).devices;
    final query = _query.trim().toLowerCase();
    final filtered = query.isEmpty
        ? available
        : available
              .where(
                (device) =>
                    device.name.toLowerCase().contains(query) ||
                    device.type.label.toLowerCase().contains(query),
              )
              .toList();

    return AlertDialog(
      title: const Text('Gerät hinzufügen'),
      content: SizedBox(
        width: 380,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (available.isNotEmpty) ...[
                TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Gerät suchen…',
                    prefixIcon: Icon(Icons.search),
                    isDense: true,
                  ),
                  onChanged: (value) => setState(() => _query = value),
                ),
                const SizedBox(height: 12),
              ],
              available.isEmpty
                  ? const Text(
                      'Keine unplatzierten Geräte für diesen Raum gefunden. Geräte '
                      'werden automatisch aus Home Assistant übernommen, sobald ihr '
                      'Name auf diesen Raum hindeutet, oder lassen sich im '
                      'Geräte-Dialog manuell zuordnen.',
                    )
                  : filtered.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text('Keine Geräte gefunden.'),
                    )
                  : ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 360),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: filtered.length,
                        separatorBuilder: (_, index) =>
                            const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final device = filtered[index];
                          return ListTile(
                            leading: Icon(
                              device.type.icon,
                              color: device.type.color,
                            ),
                            title: Text(device.name),
                            subtitle: Text(device.type.label),
                            onTap: () {
                              context.read<SmartHomeBloc>().add(
                                SmartHomePlacementStarted(
                                  device,
                                  widget.roomId,
                                ),
                              );
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Schließen'),
        ),
      ],
    );
  }
}

class DeviceInfoDialog extends StatefulWidget {
  const DeviceInfoDialog({
    required this.device,
    required this.roomId,
    super.key,
  });
  final SmartHomeDevice device;
  final String roomId;
  @override
  State<DeviceInfoDialog> createState() => _DeviceInfoDialogState();
}

class _DeviceInfoDialogState extends State<DeviceInfoDialog> {
  late bool isOn = widget.device.isOn;
  late String? selectedRoomId = widget.device.roomId;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: isOn ? widget.device.type.color : AppColors.line,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            widget.device.type.icon,
            color: isOn ? AppColors.ink : AppColors.muted,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(widget.device.name)),
      ],
    ),
    content: SizedBox(
      width: 380,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InfoRow(label: 'Gerätetyp', value: widget.device.type.label),
          InfoRow(label: 'Verbindung', value: widget.device.status),
          InfoRow(
            label: 'Aktuelle Leistung',
            value:
                '${isOn ? widget.device.powerWatts.toStringAsFixed(0) : '0'} W',
          ),
          InfoRow(
            label: widget.device.dailyKwhIsCumulative
                ? 'Zählerstand gesamt'
                : 'Verbrauch heute',
            value:
                '${widget.device.dailyKwh.toStringAsFixed(2).replaceAll('.', ',')} kWh',
          ),
          InfoRow(
            label: 'Letzte Aktualisierung',
            value: isOn == widget.device.isOn
                ? widget.device.lastUpdated
                : 'gerade eben',
          ),
          const Divider(height: 20),
          DropdownButtonFormField<String>(
            initialValue: selectedRoomId,
            decoration: const InputDecoration(labelText: 'Raum'),
            hint: const Text('Nicht zugeordnet'),
            items: _roomLabels.entries
                .map(
                  (entry) => DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value == null || value == selectedRoomId) return;
              setState(() => selectedRoomId = value);
              context.read<SmartHomeBloc>().add(
                SmartHomeDeviceAssignedToRoom(widget.device.id, value),
              );
            },
          ),
          const SizedBox(height: 8),
          if (widget.device.type == SmartHomeDeviceType.cover)
            CoverControlRow(
              device: widget.device,
              onAction: (action) => context.read<SmartHomeBloc>().add(
                SmartHomeCoverActionRequested(widget.device.id, action),
              ),
            )
          else if (widget.device.canToggle)
            PowerToggleRow(
              value: isOn,
              subtitle: isOn
                  ? 'Gerät ist eingeschaltet'
                  : 'Gerät ist ausgeschaltet',
              onChanged: (value) {
                setState(() => isOn = value);
                context.read<SmartHomeBloc>().add(
                  SmartHomeDeviceToggled(widget.device.id, value),
                );
              },
            )
          else
            const InfoRow(label: 'Schalten', value: 'Nicht unterstützt'),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _removeDevice,
              icon: const Icon(Icons.delete_outline_rounded),
              label: const Text('Gerät von der Oberfläche entfernen'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
          ),
        ],
      ),
    ),
  );

  Future<void> _removeDevice() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gerät entfernen?'),
        content: Text('„${widget.device.name}“ wird aus diesem Raum entfernt.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Entfernen'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    context.read<SmartHomeBloc>().add(
      SmartHomeDeviceRemovedFromView(widget.device.id),
    );
    Navigator.pop(context);
  }
}

class PowerToggleRow extends StatefulWidget {
  const PowerToggleRow({
    required this.value,
    required this.onChanged,
    required this.subtitle,
    super.key,
  });
  final bool value;
  final ValueChanged<bool> onChanged;
  final String subtitle;
  @override
  State<PowerToggleRow> createState() => _PowerToggleRowState();
}

class _PowerToggleRowState extends State<PowerToggleRow> {
  bool hovering = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => hovering = true),
    onExit: (_) => setState(() => hovering = false),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      decoration: BoxDecoration(
        color: hovering ? AppColors.blue.withOpacity(.18) : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: SwitchListTile.adaptive(
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
        title: const Text('Ein-/Ausschalten'),
        subtitle: Text(widget.subtitle),
        value: widget.value,
        onChanged: widget.onChanged,
        tileColor: Colors.transparent,
        hoverColor: Colors.transparent,
      ),
    ),
  );
}

class CoverControlRow extends StatelessWidget {
  const CoverControlRow({
    required this.device,
    required this.onAction,
    super.key,
  });
  final SmartHomeDevice device;
  final ValueChanged<CoverAction> onAction;

  String get _statusLabel {
    final position = device.coverPosition;
    if (position != null) return '${position.round()}% geöffnet';
    return switch (device.coverRawState) {
      'open' => 'Offen',
      'closed' => 'Geschlossen',
      'opening' => 'Wird geöffnet …',
      'closing' => 'Wird geschlossen …',
      _ => 'Unbekannt',
    };
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      InfoRow(label: 'Position', value: _statusLabel),
      const SizedBox(height: 8),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton.filledTonal(
            onPressed: () => onAction(CoverAction.open),
            icon: const Icon(Icons.keyboard_arrow_up_rounded),
            tooltip: 'Öffnen',
          ),
          IconButton.filledTonal(
            onPressed: () => onAction(CoverAction.stop),
            icon: const Icon(Icons.stop_rounded),
            tooltip: 'Stopp',
          ),
          IconButton.filledTonal(
            onPressed: () => onAction(CoverAction.close),
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
            tooltip: 'Schließen',
          ),
        ],
      ),
    ],
  );
}

class InfoRow extends StatelessWidget {
  const InfoRow({required this.label, required this.value, super.key});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(color: AppColors.muted)),
        ),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    ),
  );
}
