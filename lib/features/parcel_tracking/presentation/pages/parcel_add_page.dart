import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../application/parcel_tracking_bloc.dart';
import '../../application/parcel_tracking_event.dart';
import '../../domain/entities/carrier.dart';

class ParcelAddPage extends StatefulWidget {
  const ParcelAddPage({super.key});

  @override
  State<ParcelAddPage> createState() => _ParcelAddPageState();
}

class _ParcelAddPageState extends State<ParcelAddPage> {
  Carrier _carrier = Carrier.dhl;
  final _numberController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _numberController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.canvas,
    appBar: AppBar(
      backgroundColor: AppColors.canvas,
      title: const Text('Paket hinzufügen'),
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<Carrier>(
              initialValue: _carrier,
              decoration: const InputDecoration(labelText: 'Dienstleister'),
              items: [
                for (final carrier in Carrier.values)
                  DropdownMenuItem(value: carrier, child: Text(carrier.label)),
              ],
              onChanged: (value) =>
                  setState(() => _carrier = value ?? _carrier),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _numberController,
              decoration: const InputDecoration(labelText: 'Sendungsnummer'),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Beschreibung (optional)',
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _submit,
              style: FilledButton.styleFrom(backgroundColor: AppColors.ink),
              child: const Text('Hinzufügen'),
            ),
          ],
        ),
      ),
    ),
  );

  void _submit() {
    final number = _numberController.text.trim();
    if (number.isEmpty) return;
    final description = _descriptionController.text.trim();
    context.read<ParcelTrackingBloc>().add(
      ParcelTrackingParcelAdded(
        carrier: _carrier,
        trackingNumber: number,
        description: description.isEmpty ? null : description,
      ),
    );
    Navigator.of(context).pop();
  }
}
