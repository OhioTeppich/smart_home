import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../features/energy/presentation/pages/energy_price_settings_page.dart';
import '../../features/ha_connection/presentation/pages/ha_connection_settings_page.dart';
import '../../features/parcel_tracking/presentation/pages/parcel_list_page.dart';
import '../../features/parcel_tracking/presentation/pages/track17_settings_page.dart';
import '../../features/quick_access/presentation/pages/quick_access_settings_page.dart';
import '../../features/spotify/presentation/pages/spotify_settings_page.dart';

/// Minimal hub the settings gear icon opens: a list of navigable settings
/// sections. Kept outside any single feature since it references both
/// `ha_connection` and `quick_access`.
class SettingsHubPage extends StatelessWidget {
  const SettingsHubPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.canvas,
    appBar: AppBar(
      backgroundColor: AppColors.canvas,
      title: const Text('Einstellungen'),
    ),
    body: ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.settings_outlined),
          title: const Text('Home Assistant-Verbindung'),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => Navigator.of(context).push<void>(
            MaterialPageRoute(
              builder: (_) => const HaConnectionSettingsPage(),
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.flash_on_rounded),
          title: const Text('Schnellzugriff verwalten'),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => Navigator.of(context).push<void>(
            MaterialPageRoute(
              builder: (_) => const QuickAccessSettingsPage(),
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.euro_rounded),
          title: const Text('Energiepreis'),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => Navigator.of(context).push<void>(
            MaterialPageRoute(
              builder: (_) => const EnergyPriceSettingsPage(),
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.music_note_rounded),
          title: const Text('Spotify-Verbindung'),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => Navigator.of(context).push<void>(
            MaterialPageRoute(builder: (_) => const SpotifySettingsPage()),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.local_shipping_outlined),
          title: const Text('Pakete verwalten'),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => Navigator.of(context).push<void>(
            MaterialPageRoute(builder: (_) => const ParcelListPage()),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.vpn_key_outlined),
          title: const Text('Sendungsverfolgung einrichten'),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => Navigator.of(context).push<void>(
            MaterialPageRoute(builder: (_) => const Track17SettingsPage()),
          ),
        ),
      ],
    ),
  );
}
