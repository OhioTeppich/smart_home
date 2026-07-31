import '../../domain/entities/carrier.dart';

/// Numeric carrier codes from 17Track's public carrier list
/// (https://res.17track.net/asset/carrier/info/apicarrier.all.json).
/// Re-verify against that list if a carrier stops resolving correctly.
extension CarrierTrack17Code on Carrier {
  int? get track17Code => switch (this) {
    Carrier.dhl => 7041, // "DHL Paket" (German domestic)
    Carrier.hermes => 100018, // "Hermes" (DE)
    Carrier.dpd => 100007, // "DPD (DE)"
    Carrier.gls => 100005, // "GLS"
    Carrier.ups => 100002, // "UPS"
    // No reliable 17Track carrier code for a user-picked "Sonstiger" — such
    // parcels are tracked locally only and never sent to 17Track.
    Carrier.other => null,
  };
}
