import 'package:equatable/equatable.dart';

import '../domain/entities/parcel_candidate.dart';
import '../domain/value_objects/mailbox_account.dart';

sealed class MailboxEvent extends Equatable {
  const MailboxEvent();

  @override
  List<Object?> get props => [];
}

class MailboxStarted extends MailboxEvent {
  const MailboxStarted();
}

class MailboxAccountSaveRequested extends MailboxEvent {
  const MailboxAccountSaveRequested(this.account);

  final MailboxAccount account;

  @override
  List<Object?> get props => [account];
}

class MailboxAccountRemoved extends MailboxEvent {
  const MailboxAccountRemoved(this.accountId);

  final String accountId;

  @override
  List<Object?> get props => [accountId];
}

/// Dispatched both by the manual "Jetzt scannen" button and by the
/// foreground scan timer.
class MailboxScanRequested extends MailboxEvent {
  const MailboxScanRequested();
}

class MailboxCandidateConfirmed extends MailboxEvent {
  const MailboxCandidateConfirmed(this.candidate);

  final ParcelCandidate candidate;

  @override
  List<Object?> get props => [candidate];
}

class MailboxCandidateDismissed extends MailboxEvent {
  const MailboxCandidateDismissed(this.candidateId);

  final String candidateId;

  @override
  List<Object?> get props => [candidateId];
}
