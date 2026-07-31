import 'package:equatable/equatable.dart';

import 'carrier.dart';

/// A tracking-number candidate found while scanning a mailbox, not yet
/// confirmed by the user. Only ever carries data safe to show on screen —
/// never the email body.
class ParcelCandidate extends Equatable {
  const ParcelCandidate({
    required this.id,
    required this.carrier,
    required this.trackingNumber,
    required this.sourceEmailSubject,
    required this.sourceReceivedAt,
    required this.sourceAccountLabel,
  });

  final String id;
  final Carrier carrier;
  final String trackingNumber;
  final String sourceEmailSubject;
  final DateTime sourceReceivedAt;

  /// Human-readable mailbox label (e.g. 'Gmail', 'T-Online') — never the
  /// full email address.
  final String sourceAccountLabel;

  @override
  List<Object?> get props => [
    id,
    carrier,
    trackingNumber,
    sourceEmailSubject,
    sourceReceivedAt,
    sourceAccountLabel,
  ];
}
