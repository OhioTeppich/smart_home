import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../application/spotify_bloc.dart';
import '../../application/spotify_event.dart';
import '../../application/spotify_state.dart';

class SpotifySettingsPage extends StatefulWidget {
  const SpotifySettingsPage({super.key});

  @override
  State<SpotifySettingsPage> createState() => _SpotifySettingsPageState();
}

class _SpotifySettingsPageState extends State<SpotifySettingsPage> {
  late final TextEditingController _clientIdController;
  late final TextEditingController _redirectUriController;

  @override
  void initState() {
    super.initState();
    final config = context.read<SpotifyBloc>().state.authConfig;
    _clientIdController = TextEditingController(text: config?.clientId ?? '');
    _redirectUriController = TextEditingController(
      text: config?.redirectUri ?? '${Uri.base.origin}/auth.html',
    );
  }

  @override
  void dispose() {
    _clientIdController.dispose();
    _redirectUriController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.canvas,
    appBar: AppBar(
      backgroundColor: AppColors.canvas,
      title: const Text('Spotify-Verbindung'),
    ),
    body: BlocBuilder<SpotifyBloc, SpotifyState>(
      builder: (context, state) {
        final connected = state is SpotifyIdle || state is SpotifyPlaying;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  connected ? 'Verbunden mit Spotify' : 'Nicht verbunden.',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.blueDark,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _clientIdController,
                  decoration: const InputDecoration(labelText: 'Client-ID'),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _redirectUriController,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(labelText: 'Redirect-URI'),
                ),
                const SizedBox(height: 8),
                if (state is SpotifyUnauthenticated && state.error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      state.error!.message,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton(
                      onPressed: _saveConfig,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.ink,
                      ),
                      child: const Text('Speichern'),
                    ),
                    if (!connected)
                      OutlinedButton(
                        onPressed: state is SpotifyAuthenticating
                            ? null
                            : () => context.read<SpotifyBloc>().add(
                                const SpotifyLoginRequested(),
                              ),
                        child: state is SpotifyAuthenticating
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Mit Spotify verbinden'),
                      ),
                    if (connected)
                      TextButton(
                        onPressed: () => context.read<SpotifyBloc>().add(
                          const SpotifyLogoutRequested(),
                        ),
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('Verbindung trennen'),
                      ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text(
                    'Client-ID im Spotify-Developer-Dashboard anlegen und die '
                    'Redirect-URI dort exakt wie oben eintragen.',
                    style: TextStyle(color: AppColors.muted, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );

  void _saveConfig() => context.read<SpotifyBloc>().add(
    SpotifyConfigSaveRequested(
      clientId: _clientIdController.text,
      redirectUri: _redirectUriController.text,
    ),
  );
}
