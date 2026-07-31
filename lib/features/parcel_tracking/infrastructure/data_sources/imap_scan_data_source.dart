import 'dart:async';
import 'dart:io';

import 'package:enough_mail/enough_mail.dart';

import '../../domain/failures/parcel_tracking_failure.dart';
import '../../domain/value_objects/mailbox_account.dart';

class RawScannedEmail {
  const RawScannedEmail({
    required this.subject,
    required this.senderAddress,
    required this.receivedAt,
    required this.bodyText,
  });

  final String subject;
  final String senderAddress;
  final DateTime receivedAt;
  final String bodyText;
}

/// Reads recent inbox emails over IMAP with an app-specific password. Never
/// persists anything itself — the caller decides what, if anything, from
/// the returned emails is worth keeping.
class ImapScanDataSource {
  static const _maxMessages = 50;
  static const _maxBodyLength = 5000;
  static const _monthAbbreviations = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  Future<List<RawScannedEmail>> fetchRecentEmails({
    required MailboxAccount account,
    required DateTime since,
  }) async {
    final client = ImapClient(isLogEnabled: false);
    try {
      await client
          .connectToServer(account.host, account.port, isSecure: account.useSsl)
          .timeout(const Duration(seconds: 15));
      try {
        await client
            .login(account.username, account.appPassword)
            .timeout(const Duration(seconds: 15));
      } on ImapException {
        throw MailboxAuthFailure(account.label);
      }
      await client.selectInbox();
      final searchResult = await client
          .searchMessages(searchCriteria: 'SINCE ${_imapDate(since)}')
          .timeout(const Duration(seconds: 15));
      final sequence = searchResult.matchingSequence;
      if (sequence == null || sequence.isEmpty) return const [];
      final fetchResult = await client
          .fetchMessages(sequence, 'BODY.PEEK[]')
          .timeout(const Duration(seconds: 30));
      return fetchResult.messages.take(_maxMessages).map(_toRawEmail).toList();
    } on TimeoutException {
      throw MailboxConnectionFailure(account.label);
    } on SocketException {
      throw MailboxConnectionFailure(account.label);
    } on ImapException {
      throw MailboxAuthFailure(account.label);
    } finally {
      try {
        await client.logout();
      } catch (_) {
        // Best-effort — the connection may already be broken.
      }
      await client.disconnect();
    }
  }

  RawScannedEmail _toRawEmail(MimeMessage mime) => RawScannedEmail(
    subject: mime.decodeSubject() ?? '',
    senderAddress: mime.fromEmail ?? '',
    receivedAt: mime.decodeDate() ?? DateTime.now(),
    bodyText: _truncate(mime.decodeTextPlainPart() ?? ''),
  );

  String _truncate(String text) =>
      text.length <= _maxBodyLength ? text : text.substring(0, _maxBodyLength);

  String _imapDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}-'
      '${_monthAbbreviations[date.month - 1]}-'
      '${date.year}';
}
