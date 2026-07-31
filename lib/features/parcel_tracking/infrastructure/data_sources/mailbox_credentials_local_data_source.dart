import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/value_objects/mailbox_account.dart';

/// Account metadata (label/host/port/username) lives in `SharedPreferences`;
/// the app password per account is sensitive and lives in secure storage,
/// keyed by account id — same split as `HaConnectionLocalDataSource`.
class MailboxCredentialsLocalDataSource {
  MailboxCredentialsLocalDataSource({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const _accountsPrefsKey = 'parcel_tracking_mailbox_accounts';
  static const _lastScanPrefsKeyPrefix = 'parcel_tracking_mailbox_last_scan_';

  final FlutterSecureStorage _secureStorage;

  Future<List<MailboxAccount>> readAll() async {
    final prefs = await SharedPreferences.getInstance();
    final metas = _readMetas(prefs);
    final accounts = <MailboxAccount>[];
    for (final meta in metas) {
      final id = meta['id'] as String;
      final appPassword = await _secureStorage.read(key: _passwordKey(id)) ?? '';
      accounts.add(
        MailboxAccount(
          id: id,
          label: meta['label'] as String,
          host: meta['host'] as String,
          port: meta['port'] as int,
          username: meta['username'] as String,
          appPassword: appPassword,
          useSsl: meta['useSsl'] as bool? ?? true,
        ),
      );
    }
    return accounts;
  }

  Future<void> save(MailboxAccount account) async {
    final prefs = await SharedPreferences.getInstance();
    final metas = _readMetas(prefs)
      ..removeWhere((meta) => meta['id'] == account.id)
      ..add({
        'id': account.id,
        'label': account.label,
        'host': account.host,
        'port': account.port,
        'username': account.username,
        'useSsl': account.useSsl,
      });
    await prefs.setString(_accountsPrefsKey, jsonEncode(metas));
    await _secureStorage.write(
      key: _passwordKey(account.id),
      value: account.appPassword,
    );
  }

  Future<void> remove(String accountId) async {
    final prefs = await SharedPreferences.getInstance();
    final metas = _readMetas(prefs)
      ..removeWhere((meta) => meta['id'] == accountId);
    await prefs.setString(_accountsPrefsKey, jsonEncode(metas));
    await _secureStorage.delete(key: _passwordKey(accountId));
    await prefs.remove(_lastScanKey(accountId));
  }

  Future<DateTime?> readLastScan(String accountId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_lastScanKey(accountId));
    return raw == null ? null : DateTime.parse(raw);
  }

  Future<void> writeLastScan(String accountId, DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastScanKey(accountId), time.toIso8601String());
  }

  List<Map<String, dynamic>> _readMetas(SharedPreferences prefs) {
    final raw = prefs.getString(_accountsPrefsKey);
    if (raw == null) return [];
    return (jsonDecode(raw) as List<dynamic>).cast<Map<String, dynamic>>();
  }

  String _passwordKey(String id) => 'mailbox_app_password_$id';

  String _lastScanKey(String id) => '$_lastScanPrefsKeyPrefix$id';
}
