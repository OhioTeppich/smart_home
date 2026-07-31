import 'package:flutter_test/flutter_test.dart';
import 'package:smart_home/features/parcel_tracking/domain/value_objects/mailbox_account.dart';

void main() {
  group('MailboxAccount.tryCreate', () {
    test('accepts valid input and trims label/host/username', () {
      final account = MailboxAccount.tryCreate(
        id: 'acc-1',
        label: ' Gmail ',
        host: ' imap.gmail.com ',
        port: 993,
        username: ' user@gmail.com ',
        appPassword: 'app-password',
      );

      expect(account, isNotNull);
      expect(account!.label, 'Gmail');
      expect(account.host, 'imap.gmail.com');
      expect(account.username, 'user@gmail.com');
    });

    test('rejects an empty app password', () {
      final account = MailboxAccount.tryCreate(
        id: 'acc-1',
        label: 'Gmail',
        host: 'imap.gmail.com',
        port: 993,
        username: 'user@gmail.com',
        appPassword: '',
      );

      expect(account, isNull);
    });

    test('rejects a non-positive port', () {
      final account = MailboxAccount.tryCreate(
        id: 'acc-1',
        label: 'Gmail',
        host: 'imap.gmail.com',
        port: 0,
        username: 'user@gmail.com',
        appPassword: 'app-password',
      );

      expect(account, isNull);
    });

    test('rejects an empty host', () {
      final account = MailboxAccount.tryCreate(
        id: 'acc-1',
        label: 'Gmail',
        host: '   ',
        port: 993,
        username: 'user@gmail.com',
        appPassword: 'app-password',
      );

      expect(account, isNull);
    });
  });
}
