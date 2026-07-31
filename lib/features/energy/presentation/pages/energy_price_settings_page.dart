import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../application/energy_dashboard_controller.dart';

class EnergyPriceSettingsPage extends StatefulWidget {
  const EnergyPriceSettingsPage({super.key});

  @override
  State<EnergyPriceSettingsPage> createState() =>
      _EnergyPriceSettingsPageState();
}

class _EnergyPriceSettingsPageState extends State<EnergyPriceSettingsPage> {
  final _priceController = TextEditingController();
  bool _prefilled = false;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_prefilled) return;
    _prefilled = true;
    final price = EnergyScope.of(context).pricePerKwh;
    if (price != null) {
      _priceController.text = price.toString().replaceAll('.', ',');
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.canvas,
    appBar: AppBar(
      backgroundColor: AppColors.canvas,
      title: const Text('Energiepreis'),
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Preis pro Kilowattstunde, um die Kosten der Geräte zu berechnen.',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.blueDark,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Preis pro kWh',
                hintText: '0,30',
                suffixText: '€',
                errorText: _error,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(backgroundColor: AppColors.ink),
              child: const Text('Speichern'),
            ),
          ],
        ),
      ),
    ),
  );

  void _save() {
    final normalized = _priceController.text.trim().replaceAll(',', '.');
    final value = double.tryParse(normalized);
    if (value == null || value < 0) {
      setState(() => _error = 'Bitte gültigen Preis eingeben.');
      return;
    }
    setState(() => _error = null);
    EnergyScope.of(context).setPricePerKwh(value);
    Navigator.of(context).pop();
  }
}
