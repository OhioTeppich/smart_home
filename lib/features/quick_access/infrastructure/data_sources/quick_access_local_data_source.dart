import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Local-only, ordered list of Home Assistant `entity_id`s the user picked
/// for the dashboard's Schnellzugriff widget. Home Assistant has no concept
/// of this list — it only exists here.
class QuickAccessLocalDataSource {
  static const _prefsKey = 'quick_access_device_ids';

  Future<List<String>> readIds() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.cast<String>();
  }

  Future<void> writeIds(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(ids));
  }
}
