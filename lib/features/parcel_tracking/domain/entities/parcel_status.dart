enum ParcelStatus { unknown, inTransit, outForDelivery, delivered, exception }

extension ParcelStatusLabel on ParcelStatus {
  String get label => switch (this) {
    ParcelStatus.unknown => 'Unbekannt',
    ParcelStatus.inTransit => 'Unterwegs',
    ParcelStatus.outForDelivery => 'Wird zugestellt',
    ParcelStatus.delivered => 'Zugestellt',
    ParcelStatus.exception => 'Zustellproblem',
  };
}
