import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../application/mailbox_bloc.dart';
import '../../application/mailbox_event.dart';
import '../../application/mailbox_state.dart';
import '../../domain/value_objects/mailbox_account.dart';

class MailboxSettingsPage extends StatefulWidget {
  const MailboxSettingsPage({super.key});

  @override
  State<MailboxSettingsPage> createState() => _MailboxSettingsPageState();
}

class _MailboxSettingsPageState extends State<MailboxSettingsPage> {
  final _labelController = TextEditingController();
  final _hostController = TextEditingController();
  final _portController = TextEditingController(text: '993');
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _labelController.dispose();
    _hostController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _fillGmail() {
    _labelController.text = 'Gmail';
    _hostController.text = 'imap.gmail.com';
    _portController.text = '993';
  }

  void _fillTOnline() {
    _labelController.text = 'T-Online';
    _hostController.text = 'secureimap.t-online.de';
    _portController.text = '993';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.canvas,
    appBar: AppBar(
      backgroundColor: AppColors.canvas,
      title: const Text('E-Mail-Postfächer für Paketerkennung'),
    ),
    body: BlocBuilder<MailboxBloc, MailboxState>(
      builder: (context, state) {
        final accounts = state is MailboxReady ? state.accounts : const <MailboxAccount>[];
        final isScanning = state is MailboxReady && state.isScanning;
        final lastScanError = state is MailboxReady ? state.lastScanError : null;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Das App-Passwort gibt vollen Lesezugriff aufs gesamte '
                  'Postfach, nicht nur auf Bestell-Mails. E-Mail-Inhalte '
                  'werden nur im Speicher ausgewertet und nie gespeichert — '
                  'nur bestätigte Trackingnummern werden übernommen.',
                  style: TextStyle(color: AppColors.muted, fontSize: 12),
                ),
                const SizedBox(height: 20),
                if (accounts.isEmpty)
                  const Text(
                    'Noch keine Postfächer verbunden.',
                    style: TextStyle(color: AppColors.muted),
                  )
                else
                  ...accounts.map(
                    (account) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.email_outlined),
                      title: Text(account.label),
                      subtitle: Text('${account.username} · ${account.host}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.close_rounded),
                        tooltip: 'Entfernen',
                        onPressed: () => context.read<MailboxBloc>().add(
                          MailboxAccountRemoved(account.id),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: _fillGmail,
                      child: const Text('Gmail'),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: _fillTOnline,
                      child: const Text('T-Online'),
                    ),
                  ],
                ),
                const Divider(height: 32),
                const Text(
                  'Postfach hinzufügen',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _labelController,
                  decoration: const InputDecoration(labelText: 'Bezeichnung'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _hostController,
                  decoration: const InputDecoration(labelText: 'IMAP-Server'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _portController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Port'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'E-Mail-Adresse'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'App-Passwort',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _save,
                  style: FilledButton.styleFrom(backgroundColor: AppColors.ink),
                  child: const Text('Postfach speichern'),
                ),
                const Divider(height: 32),
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: isScanning || accounts.isEmpty
                          ? null
                          : () => context.read<MailboxBloc>().add(
                              const MailboxScanRequested(),
                            ),
                      child: isScanning
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Jetzt scannen'),
                    ),
                  ],
                ),
                if (lastScanError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      lastScanError,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    ),
  );

  void _save() {
    final account = MailboxAccount.tryCreate(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      label: _labelController.text,
      host: _hostController.text,
      port: int.tryParse(_portController.text.trim()) ?? 993,
      username: _usernameController.text,
      appPassword: _passwordController.text,
    );
    if (account == null) return;
    context.read<MailboxBloc>().add(MailboxAccountSaveRequested(account));
    _labelController.clear();
    _hostController.clear();
    _portController.text = '993';
    _usernameController.clear();
    _passwordController.clear();
  }
}
