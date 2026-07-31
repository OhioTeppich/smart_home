import 'package:equatable/equatable.dart';

import '../entities/carrier.dart';

class ExtractedTrackingCandidate extends Equatable {
  const ExtractedTrackingCandidate({
    required this.carrier,
    required this.trackingNumber,
    required this.matchedKeyword,
  });

  final Carrier carrier;
  final String trackingNumber;
  final String matchedKeyword;

  @override
  List<Object?> get props => [carrier, trackingNumber, matchedKeyword];
}

class _CarrierPattern {
  const _CarrierPattern(this.carrier, this.keywords, this.numberPattern);

  final Carrier carrier;
  final List<String> keywords;
  final RegExp numberPattern;
}

/// Pure, IO-free heuristic: a carrier is only considered a match when both a
/// keyword (sender/subject/body hint) AND a plausible tracking-number shape
/// are present. Keyword-only matches are deliberately dropped rather than
/// guessed at, to avoid surfacing bogus candidates to the user.
class TrackingNumberExtractor {
  const TrackingNumberExtractor();

  static final List<_CarrierPattern> _patterns = [
    _CarrierPattern(Carrier.ups, const ['ups'], RegExp(r'\b1Z[A-Z0-9]{16}\b')),
    _CarrierPattern(
      Carrier.dhl,
      const ['dhl'],
      RegExp(r'\b\d{12,14}\b'),
    ),
    _CarrierPattern(
      Carrier.dpd,
      const ['dpd'],
      RegExp(r'\b\d{14}\b'),
    ),
    _CarrierPattern(
      Carrier.gls,
      const ['gls'],
      RegExp(r'\b\d{11,14}\b'),
    ),
    _CarrierPattern(
      Carrier.hermes,
      const ['hermes', 'evri'],
      RegExp(r'\b[A-Z0-9]{14,20}\b'),
    ),
  ];

  List<ExtractedTrackingCandidate> extract({
    required String subject,
    required String bodyText,
    required String senderAddress,
  }) {
    final haystackLower = '$subject\n$bodyText\n$senderAddress'.toLowerCase();
    final searchText = '$subject\n$bodyText';
    final results = <ExtractedTrackingCandidate>[];

    for (final pattern in _patterns) {
      final matchedKeyword = pattern.keywords.firstWhere(
        haystackLower.contains,
        orElse: () => '',
      );
      if (matchedKeyword.isEmpty) continue;

      final match = pattern.numberPattern.firstMatch(searchText);
      if (match == null) continue;

      results.add(
        ExtractedTrackingCandidate(
          carrier: pattern.carrier,
          trackingNumber: match.group(0)!,
          matchedKeyword: matchedKeyword,
        ),
      );
    }

    return results;
  }
}
