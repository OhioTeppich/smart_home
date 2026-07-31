import '../../domain/entities/parcel_candidate.dart';
import '../../domain/failures/parcel_tracking_failure.dart';
import '../../domain/repositories/mailbox_repository.dart';
import '../../domain/repositories/parcel_repository.dart';
import '../../domain/services/tracking_number_extractor.dart';
import '../../domain/value_objects/mailbox_account.dart';
import '../data_sources/imap_scan_data_source.dart';
import '../data_sources/mailbox_credentials_local_data_source.dart';

class ImapMailboxRepository implements MailboxRepository {
  ImapMailboxRepository(
    this._credentialsDataSource,
    this._imapDataSource,
    this._extractor,
    this._parcelRepository,
  );

  /// How far back to look on an account's very first scan.
  static const _initialScanWindow = Duration(days: 14);

  final MailboxCredentialsLocalDataSource _credentialsDataSource;
  final ImapScanDataSource _imapDataSource;
  final TrackingNumberExtractor _extractor;
  final ParcelRepository _parcelRepository;

  @override
  Future<List<MailboxAccount>> loadAccounts() => _credentialsDataSource.readAll();

  @override
  Future<void> saveAccount(MailboxAccount account) =>
      _credentialsDataSource.save(account);

  @override
  Future<void> removeAccount(String accountId) =>
      _credentialsDataSource.remove(accountId);

  @override
  Future<List<ParcelCandidate>> scanForCandidates() async {
    final accounts = await _credentialsDataSource.readAll();
    if (accounts.isEmpty) return const [];

    final trackedNumbers = (await _parcelRepository.fetchParcels())
        .map((parcel) => parcel.trackingNumber)
        .toSet();

    final candidatesById = <String, ParcelCandidate>{};
    ParcelTrackingFailure? lastFailure;
    var anySucceeded = false;

    for (final account in accounts) {
      try {
        final since =
            await _credentialsDataSource.readLastScan(account.id) ??
            DateTime.now().subtract(_initialScanWindow);
        final emails = await _imapDataSource.fetchRecentEmails(
          account: account,
          since: since,
        );
        for (final email in emails) {
          final matches = _extractor.extract(
            subject: email.subject,
            bodyText: email.bodyText,
            senderAddress: email.senderAddress,
          );
          for (final match in matches) {
            if (trackedNumbers.contains(match.trackingNumber)) continue;
            final id = '${match.carrier.name}:${match.trackingNumber}';
            candidatesById[id] = ParcelCandidate(
              id: id,
              carrier: match.carrier,
              trackingNumber: match.trackingNumber,
              sourceEmailSubject: email.subject,
              sourceReceivedAt: email.receivedAt,
              sourceAccountLabel: account.label,
            );
          }
        }
        await _credentialsDataSource.writeLastScan(account.id, DateTime.now());
        anySucceeded = true;
      } on ParcelTrackingFailure catch (failure) {
        lastFailure = failure;
      }
    }

    if (!anySucceeded && lastFailure != null) throw lastFailure;
    return candidatesById.values.toList();
  }
}
