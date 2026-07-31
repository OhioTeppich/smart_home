import 'package:equatable/equatable.dart';

import '../domain/entities/parcel_candidate.dart';
import '../domain/value_objects/mailbox_account.dart';

sealed class MailboxState extends Equatable {
  const MailboxState();

  @override
  List<Object?> get props => [];
}

class MailboxInitial extends MailboxState {
  const MailboxInitial();
}

class MailboxLoading extends MailboxState {
  const MailboxLoading();
}

class MailboxReady extends MailboxState {
  const MailboxReady({
    required this.accounts,
    required this.pendingCandidates,
    this.isScanning = false,
    this.lastScanError,
  });

  final List<MailboxAccount> accounts;
  final List<ParcelCandidate> pendingCandidates;
  final bool isScanning;
  final String? lastScanError;

  MailboxReady copyWith({
    List<MailboxAccount>? accounts,
    List<ParcelCandidate>? pendingCandidates,
    bool? isScanning,
    String? lastScanError,
    bool clearLastScanError = false,
  }) => MailboxReady(
    accounts: accounts ?? this.accounts,
    pendingCandidates: pendingCandidates ?? this.pendingCandidates,
    isScanning: isScanning ?? this.isScanning,
    lastScanError: clearLastScanError ? null : (lastScanError ?? this.lastScanError),
  );

  @override
  List<Object?> get props => [accounts, pendingCandidates, isScanning, lastScanError];
}
