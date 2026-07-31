enum Carrier { dhl, hermes, dpd, gls, ups, other }

extension CarrierLabel on Carrier {
  String get label => switch (this) {
    Carrier.dhl => 'DHL',
    Carrier.hermes => 'Hermes',
    Carrier.dpd => 'DPD',
    Carrier.gls => 'GLS',
    Carrier.ups => 'UPS',
    Carrier.other => 'Sonstiger',
  };
}
