import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../application/parcel_tracking_bloc.dart';
import '../../application/parcel_tracking_event.dart';
import '../../application/parcel_tracking_state.dart';

/// The API key is write-only here — once saved it is never read back and
/// shown again, unlike the Home Assistant token field. It's a third-party
/// secret, not a local network credential, so there's less reason to ever
/// need to re-view it on screen.
class Track17SettingsPage extends StatefulWidget {
  const Track17SettingsPage({super.key});

  @override
  State<Track17SettingsPage> createState() => _Track17SettingsPageState();
}

class _Track17SettingsPageState extends State<Track17SettingsPage> {
  final _apiKeyController = TextEditingController();
  bool _obscureApiKey = true;

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.canvas,
    appBar: AppBar(
      backgroundColor: AppColors.canvas,
      title: const Text('Sendungsverfolgung einrichten'),
    ),
    body: BlocBuilder<ParcelTrackingBloc, ParcelTrackingState>(
      builder: (context, state) {
        final isConfigured =
            state is ParcelTrackingReady && state.isConfigured;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isConfigured
                      ? 'API-Key hinterlegt.'
                      : 'Kein API-Key hinterlegt.',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.blueDark,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '17Track verfolgt Sendungen für DHL, Hermes, DPD, GLS und '
                  'UPS. Ein kostenloser API-Key kann auf 17track.net erstellt '
                  'werden.',
                  style: TextStyle(color: AppColors.muted, fontSize: 12),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _apiKeyController,
                  obscureText: _obscureApiKey,
                  decoration: InputDecoration(
                    labelText: '17Track API-Key',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureApiKey
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () =>
                          setState(() => _obscureApiKey = !_obscureApiKey),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton(
                      onPressed: _save,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.ink,
                      ),
                      child: const Text('Speichern'),
                    ),
                    if (isConfigured)
                      TextButton(
                        onPressed: () => context.read<ParcelTrackingBloc>().add(
                          const ParcelTrackingApiKeyCleared(),
                        ),
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('API-Key entfernen'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ),
  );

  void _save() {
    final apiKey = _apiKeyController.text.trim();
    if (apiKey.isEmpty) return;
    context.read<ParcelTrackingBloc>().add(
      ParcelTrackingApiKeySaveRequested(apiKey),
    );
    _apiKeyController.clear();
    Navigator.of(context).pop();
  }
}
