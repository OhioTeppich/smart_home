import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../application/controllers/smart_home_controller.dart';
import '../../domain/entities/smart_home_device.dart';
import 'smart_home_device_ui.dart';

class AddDeviceDialog extends StatefulWidget {
  const AddDeviceDialog({super.key});
  @override
  State<AddDeviceDialog> createState() => _AddDeviceDialogState();
}

class _AddDeviceDialogState extends State<AddDeviceDialog> {
  SmartHomeDeviceType type = SmartHomeDeviceType.lamp;
  late final nameController = TextEditingController(text: type.label);

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('SmartHome-Gerät hinzufügen'),
    content: SizedBox(
      width: 380,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<SmartHomeDeviceType>(
            value: type,
            decoration: const InputDecoration(labelText: 'Gerätetyp'),
            items: SmartHomeDeviceType.values
                .map(
                  (item) =>
                      DropdownMenuItem(value: item, child: Text(item.label)),
                )
                .toList(),
            onChanged: (value) => setState(() {
              type = value!;
              if (nameController.text.isEmpty ||
                  SmartHomeDeviceType.values.any(
                    (item) => item.label == nameController.text,
                  ))
                nameController.text = type.label;
            }),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Abbrechen'),
      ),
      FilledButton(
        onPressed: _submit,
        child: const Text('Weiter zur Platzierung'),
      ),
    ],
  );

  void _submit() {
    final name = nameController.text.trim().isEmpty
        ? type.label
        : nameController.text.trim();
    Navigator.pop(
      context,
      SmartHomeDevice(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: name,
        type: type,
        status: 'Online',
        powerWatts: switch (type) {
          SmartHomeDeviceType.lamp || SmartHomeDeviceType.bulb => 9,
          SmartHomeDeviceType.television => 82,
          SmartHomeDeviceType.plug => 24,
          SmartHomeDeviceType.sensor => 1,
          SmartHomeDeviceType.other => 18,
        },
        dailyKwh: switch (type) {
          SmartHomeDeviceType.lamp || SmartHomeDeviceType.bulb => .18,
          SmartHomeDeviceType.television => .64,
          SmartHomeDeviceType.plug => .31,
          SmartHomeDeviceType.sensor => .02,
          SmartHomeDeviceType.other => .2,
        },
        lastUpdated: 'gerade eben',
        isOn: type != SmartHomeDeviceType.sensor,
      ),
    );
  }
}

class DeviceInfoDialog extends StatefulWidget {
  const DeviceInfoDialog({
    required this.device,
    required this.controller,
    required this.roomId,
    super.key,
  });
  final SmartHomeDevice device;
  final SmartHomeController controller;
  final String roomId;
  @override
  State<DeviceInfoDialog> createState() => _DeviceInfoDialogState();
}

class _DeviceInfoDialogState extends State<DeviceInfoDialog> {
  late bool isOn = widget.device.isOn;

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
    content: Column(
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
          label: 'Verbrauch heute',
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
        if (widget.device.canToggle)
          PowerToggleRow(
            value: isOn,
            subtitle: isOn
                ? 'Gerät ist eingeschaltet'
                : 'Gerät ist ausgeschaltet',
            onChanged: (value) {
              setState(() => isOn = value);
              widget.controller.toggleDevice(
                widget.device.id,
                value,
                roomId: widget.roomId,
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
    widget.controller.removeDevice(widget.device.id, roomId: widget.roomId);
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
