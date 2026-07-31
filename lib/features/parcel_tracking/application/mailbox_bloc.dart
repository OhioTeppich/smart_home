import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/failures/parcel_tracking_failure.dart';
import '../domain/repositories/mailbox_repository.dart';
import '../domain/repositories/parcel_repository.dart';
import 'mailbox_event.dart';
import 'mailbox_state.dart';

class MailboxBloc extends Bloc<MailboxEvent, MailboxState> {
  MailboxBloc(this._mailboxRepository, this._parcelRepository)
    : super(const MailboxInitial()) {
    on<MailboxStarted>(_onStarted);
    on<MailboxAccountSaveRequested>(_onAccountSaveRequested);
    on<MailboxAccountRemoved>(_onAccountRemoved);
    on<MailboxScanRequested>(_onScanRequested);
    on<MailboxCandidateConfirmed>(_onCandidateConfirmed);
    on<MailboxCandidateDismissed>(_onCandidateDismissed);
  }

  /// Foreground-only: the timer lives in this bloc instance, so it stops the
  /// moment the app is backgrounded/killed — no `workmanager`, by design.
  static const _scanInterval = Duration(minutes: 20);

  final MailboxRepository _mailboxRepository;
  final ParcelRepository _parcelRepository;
  Timer? _scanTimer;

  Future<void> _onStarted(
    MailboxStarted event,
    Emitter<MailboxState> emit,
  ) async {
    emit(const MailboxLoading());
    final accounts = await _mailboxRepository.loadAccounts();
    emit(MailboxReady(accounts: accounts, pendingCandidates: const []));
    _restartScanTimer(accounts.isNotEmpty);
  }

  Future<void> _onAccountSaveRequested(
    MailboxAccountSaveRequested event,
    Emitter<MailboxState> emit,
  ) async {
    final current = state;
    try {
      await _mailboxRepository.saveAccount(event.account);
    } catch (_) {
      if (current is MailboxReady) {
        emit(current.copyWith(lastScanError: 'Postfach konnte nicht gespeichert werden.'));
      }
      return;
    }
    final accounts = await _mailboxRepository.loadAccounts();
    emit(
      MailboxReady(
        accounts: accounts,
        pendingCandidates: current is MailboxReady
            ? current.pendingCandidates
            : const [],
      ),
    );
    _restartScanTimer(accounts.isNotEmpty);
  }

  Future<void> _onAccountRemoved(
    MailboxAccountRemoved event,
    Emitter<MailboxState> emit,
  ) async {
    await _mailboxRepository.removeAccount(event.accountId);
    final accounts = await _mailboxRepository.loadAccounts();
    final current = state;
    emit(
      MailboxReady(
        accounts: accounts,
        pendingCandidates: current is MailboxReady
            ? current.pendingCandidates
            : const [],
      ),
    );
    _restartScanTimer(accounts.isNotEmpty);
  }

  Future<void> _onScanRequested(
    MailboxScanRequested event,
    Emitter<MailboxState> emit,
  ) async {
    final current = state;
    if (current is! MailboxReady || current.isScanning) return;
    emit(current.copyWith(isScanning: true, clearLastScanError: true));
    try {
      final newCandidates = await _mailboxRepository.scanForCandidates();
      final merged = {for (final c in current.pendingCandidates) c.id: c};
      for (final candidate in newCandidates) {
        merged[candidate.id] = candidate;
      }
      emit(
        current.copyWith(isScanning: false, pendingCandidates: merged.values.toList()),
      );
    } on ParcelTrackingFailure catch (failure) {
      emit(current.copyWith(isScanning: false, lastScanError: failure.message));
    }
  }

  Future<void> _onCandidateConfirmed(
    MailboxCandidateConfirmed event,
    Emitter<MailboxState> emit,
  ) async {
    final current = state;
    if (current is! MailboxReady) return;
    try {
      await _parcelRepository.addParcel(
        carrier: event.candidate.carrier,
        trackingNumber: event.candidate.trackingNumber,
      );
      emit(
        current.copyWith(
          pendingCandidates: current.pendingCandidates
              .where((c) => c.id != event.candidate.id)
              .toList(),
        ),
      );
    } on ParcelTrackingFailure catch (failure) {
      emit(current.copyWith(lastScanError: failure.message));
    }
  }

  void _onCandidateDismissed(
    MailboxCandidateDismissed event,
    Emitter<MailboxState> emit,
  ) {
    final current = state;
    if (current is! MailboxReady) return;
    emit(
      current.copyWith(
        pendingCandidates: current.pendingCandidates
            .where((c) => c.id != event.candidateId)
            .toList(),
      ),
    );
  }

  void _restartScanTimer(bool hasAccounts) {
    _scanTimer?.cancel();
    _scanTimer = hasAccounts
        ? Timer.periodic(_scanInterval, (_) => add(const MailboxScanRequested()))
        : null;
  }

  @override
  Future<void> close() {
    _scanTimer?.cancel();
    return super.close();
  }
}
