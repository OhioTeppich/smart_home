import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/parcel_record_dto.dart';

/// Local-only persistence for tracked parcels, so the card has data on cold
/// start before any network round trip to the tracking provider.
class ParcelLocalDataSource {
  static const _prefsKey = 'parcel_tracking_records';

  Future<List<ParcelRecordDto>> readAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .cast<Map<String, dynamic>>()
        .map(ParcelRecordDto.fromJson)
        .toList();
  }

  Future<void> writeAll(List<ParcelRecordDto> records) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefsKey,
      jsonEncode([for (final record in records) record.toJson()]),
    );
  }
}
