import 'package:flutter_test/flutter_test.dart';
import 'package:smart_home/features/parcel_tracking/application/mailbox_bloc.dart';
import 'package:smart_home/features/parcel_tracking/application/mailbox_event.dart';
import 'package:smart_home/features/parcel_tracking/application/mailbox_state.dart';
import 'package:smart_home/features/parcel_tracking/domain/entities/carrier.dart';
import 'package:smart_home/features/parcel_tracking/domain/entities/parcel.dart';
import 'package:smart_home/features/parcel_tracking/domain/entities/parcel_candidate.dart';
import 'package:smart_home/features/parcel_tracking/domain/failures/parcel_tracking_failure.dart';
import 'package:smart_home/features/parcel_tracking/domain/repositories/mailbox_repository.dart';
import 'package:smart_home/features/parcel_tracking/domain/repositories/parcel_repository.dart';
import 'package:smart_home/features/parcel_tracking/domain/value_objects/mailbox_account.dart';

class _FakeMailboxRepository implements MailboxRepository {
  List<MailboxAccount> accounts = [];
  List<ParcelCandidate> nextCandidates = [];
  Object? scanError;
  Object? saveError;
  final calls = <String>[];

  @override
  Future<List<MailboxAccount>> loadAccounts() async => accounts;

  @override
  Future<void> saveAccount(MailboxAccount account) async {
    calls.add('saveAccount');
    if (saveError != null) throw saveError!;
    accounts = [...accounts, account];
  }

  @override
  Future<void> removeAccount(String accountId) async {
    accounts = accounts.where((a) => a.id != accountId).toList();
  }

  @override
  Future<List<ParcelCandidate>> scanForCandidates() async {
    calls.add('scanForCandidates');
    if (scanError != null) throw scanError!;
    return nextCandidates;
  }
}

class _FakeParcelRepositoryForMailbox implements ParcelRepository {
  final addedParcels = <String>[];
  Object? addParcelError;

  @override
  Future<void> addParcel({
    required Carrier carrier,
    required String trackingNumber,
    String? description,
  }) async {
    if (addParcelError != null) throw addParcelError!;
    addedParcels.add(trackingNumber);
  }

  @override
  Future<List<Parcel>> fetchParcels() async => [];

  @override
  Stream<List<Parcel>> watchParcels() => const Stream.empty();

  @override
  Future<void> removeParcel(String id) async {}

  @override
  Future<void> refreshParcel(String id) async {}

  @override
  Future<void> refreshAll() async {}

  @override
  Future<bool> hasApiKeyConfigured() async => true;

  @override
  Future<void> configureApiKey(String apiKey) async {}

  @override
  Future<void> clearApiKey() async {}
}

MailboxAccount _account(String id) => MailboxAccount(
  id: id,
  label: 'Gmail',
  host: 'imap.gmail.com',
  port: 993,
  username: 'user@gmail.com',
  appPassword: 'app-password',
);

ParcelCandidate _candidate(String id) => ParcelCandidate(
  id: id,
  carrier: Carrier.dhl,
  trackingNumber: '123456',
  sourceEmailSubject: 'Ihre Sendung',
  sourceReceivedAt: DateTime(2026, 1, 1),
  sourceAccountLabel: 'Gmail',
);

void main() {
  late _FakeMailboxRepository mailboxRepository;
  late _FakeParcelRepositoryForMailbox parcelRepository;
  late MailboxBloc bloc;

  setUp(() {
    mailboxRepository = _FakeMailboxRepository();
    parcelRepository = _FakeParcelRepositoryForMailbox();
  });

  tearDown(() async {
    await bloc.close();
  });

  test('initial state is MailboxInitial', () {
    bloc = MailboxBloc(mailboxRepository, parcelRepository);
    expect(bloc.state, isA<MailboxInitial>());
  });

  test('Started loads saved accounts into Ready', () async {
    mailboxRepository.accounts = [_account('acc-1')];
    bloc = MailboxBloc(mailboxRepository, parcelRepository);

    bloc.add(const MailboxStarted());
    await Future.delayed(Duration.zero);

    final state = bloc.state;
    expect(state, isA<MailboxReady>());
    expect((state as MailboxReady).accounts.map((a) => a.id), ['acc-1']);
  });

  test('ScanRequested merges new candidates into pendingCandidates', () async {
    mailboxRepository.accounts = [_account('acc-1')];
    mailboxRepository.nextCandidates = [_candidate('candidate-1')];
    bloc = MailboxBloc(mailboxRepository, parcelRepository);
    bloc.add(const MailboxStarted());
    await Future.delayed(Duration.zero);

    bloc.add(const MailboxScanRequested());
    await Future.delayed(Duration.zero);

    final state = bloc.state as MailboxReady;
    expect(state.pendingCandidates.map((c) => c.id), ['candidate-1']);
    expect(state.isScanning, isFalse);
  });

  test('ScanRequested failure surfaces lastScanError without crashing', () async {
    mailboxRepository.accounts = [_account('acc-1')];
    mailboxRepository.scanError = MailboxConnectionFailure('Gmail');
    bloc = MailboxBloc(mailboxRepository, parcelRepository);
    bloc.add(const MailboxStarted());
    await Future.delayed(Duration.zero);

    bloc.add(const MailboxScanRequested());
    await Future.delayed(Duration.zero);

    final state = bloc.state as MailboxReady;
    expect(state.lastScanError, isNotNull);
  });

  test('CandidateConfirmed adds the parcel and removes the candidate', () async {
    mailboxRepository.accounts = [_account('acc-1')];
    mailboxRepository.nextCandidates = [_candidate('candidate-1')];
    bloc = MailboxBloc(mailboxRepository, parcelRepository);
    bloc.add(const MailboxStarted());
    await Future.delayed(Duration.zero);
    bloc.add(const MailboxScanRequested());
    await Future.delayed(Duration.zero);

    bloc.add(MailboxCandidateConfirmed(_candidate('candidate-1')));
    await Future.delayed(Duration.zero);

    expect(parcelRepository.addedParcels, ['123456']);
    expect((bloc.state as MailboxReady).pendingCandidates, isEmpty);
  });

  test('CandidateDismissed just removes the candidate, no parcel added', () async {
    mailboxRepository.accounts = [_account('acc-1')];
    mailboxRepository.nextCandidates = [_candidate('candidate-1')];
    bloc = MailboxBloc(mailboxRepository, parcelRepository);
    bloc.add(const MailboxStarted());
    await Future.delayed(Duration.zero);
    bloc.add(const MailboxScanRequested());
    await Future.delayed(Duration.zero);

    bloc.add(const MailboxCandidateDismissed('candidate-1'));
    await Future.delayed(Duration.zero);

    expect(parcelRepository.addedParcels, isEmpty);
    expect((bloc.state as MailboxReady).pendingCandidates, isEmpty);
  });

  test('a failed account save surfaces lastScanError instead of crashing', () async {
    mailboxRepository.saveError = StateError('secure storage unavailable');
    bloc = MailboxBloc(mailboxRepository, parcelRepository);
    bloc.add(const MailboxStarted());
    await Future.delayed(Duration.zero);

    bloc.add(MailboxAccountSaveRequested(_account('acc-1')));
    await Future.delayed(Duration.zero);

    final state = bloc.state as MailboxReady;
    expect(state.accounts, isEmpty);
    expect(state.lastScanError, isNotNull);
  });
}
