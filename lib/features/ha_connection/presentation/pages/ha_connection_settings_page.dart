import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../application/ha_connection_bloc.dart';
import '../../application/ha_connection_event.dart';
import '../../application/ha_connection_state.dart';

class HaConnectionSettingsPage extends StatefulWidget {
  const HaConnectionSettingsPage({super.key});

  @override
  State<HaConnectionSettingsPage> createState() =>
      _HaConnectionSettingsPageState();
}

class _HaConnectionSettingsPageState extends State<HaConnectionSettingsPage> {
  late final TextEditingController _urlController;
  late final TextEditingController _tokenController;
  bool _obscureToken = true;

  @override
  void initState() {
    super.initState();
    final state = context.read<HaConnectionBloc>().state;
    final saved = state is HaConnectionReady ? state.savedConfig : null;
    _urlController = TextEditingController(text: saved?.baseUrl ?? '');
    _tokenController = TextEditingController(text: saved?.token ?? '');
  }

  @override
  void dispose() {
    _urlController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.canvas,
    appBar: AppBar(
      backgroundColor: AppColors.canvas,
      title: const Text('Home Assistant-Verbindung'),
    ),
    body: BlocBuilder<HaConnectionBloc, HaConnectionState>(
      builder: (context, state) {
        if (state is! HaConnectionReady) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.savedConfig != null
                      ? 'Verbunden mit ${state.savedConfig!.baseUrl}'
                      : 'Keine Verbindung konfiguriert.',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.blueDark,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _urlController,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    labelText: 'Basis-URL',
                    hintText: 'https://homeassistant.local:8123',
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _tokenController,
                  obscureText: _obscureToken,
                  decoration: InputDecoration(
                    labelText: 'Langlebiger Zugriffstoken',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureToken
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () =>
                          setState(() => _obscureToken = !_obscureToken),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                if (state.testMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      state.testMessage!,
                      style: TextStyle(
                        color: state.testStatus == HaConnectionTestStatus.success
                            ? AppColors.green
                            : Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    OutlinedButton(
                      onPressed:
                          state.testStatus == HaConnectionTestStatus.inProgress
                          ? null
                          : _testConnection,
                      child: state.testStatus == HaConnectionTestStatus.inProgress
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Verbindung testen'),
                    ),
                    FilledButton(
                      onPressed: _save,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.ink,
                      ),
                      child: const Text('Speichern'),
                    ),
                    if (state.savedConfig != null)
                      TextButton(
                        onPressed: () => context
                            .read<HaConnectionBloc>()
                            .add(const HaConnectionCleared()),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Verbindung trennen'),
                      ),
                  ],
                ),
                ListenableBuilder(
                  listenable: _urlController,
                  builder: (context, _) =>
                      _urlController.text.trim().startsWith('http://')
                      ? const Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: Text(
                            'Hinweis: http:// überträgt den Zugriffstoken unverschlüsselt im Netzwerk. '
                            'https:// verwenden, wenn verfügbar.',
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 12,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );

  void _testConnection() => context.read<HaConnectionBloc>().add(
    HaConnectionTestRequested(
      baseUrl: _urlController.text,
      token: _tokenController.text,
    ),
  );

  void _save() => context.read<HaConnectionBloc>().add(
    HaConnectionSaveRequested(
      baseUrl: _urlController.text,
      token: _tokenController.text,
    ),
  );
}
