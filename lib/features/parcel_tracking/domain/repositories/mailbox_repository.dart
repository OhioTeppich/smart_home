import '../entities/parcel_candidate.dart';
import '../value_objects/mailbox_account.dart';

abstract class MailboxRepository {
  Future<List<MailboxAccount>> loadAccounts();

  Future<void> saveAccount(MailboxAccount account);

  Future<void> removeAccount(String accountId);

  /// Scans all saved accounts for new order-confirmation emails since each
  /// account's last successful scan. A failure on one account does not
  /// prevent the others from being scanned; throws a [ParcelTrackingFailure]
  /// subtype only if every account failed.
  Future<List<ParcelCandidate>> scanForCandidates();
}
