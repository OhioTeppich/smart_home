import 'package:flutter_test/flutter_test.dart';
import 'package:smart_home/features/parcel_tracking/domain/entities/carrier.dart';
import 'package:smart_home/features/parcel_tracking/domain/services/tracking_number_extractor.dart';

void main() {
  const extractor = TrackingNumberExtractor();

  group('TrackingNumberExtractor.extract', () {
    test('finds a DHL tracking number by keyword + digit pattern', () {
      final results = extractor.extract(
        subject: 'Ihre DHL Sendung ist unterwegs',
        bodyText: 'Sendungsnummer: 123456789012',
        senderAddress: 'no-reply@dhl.de',
      );

      expect(results, hasLength(1));
      expect(results.single.carrier, Carrier.dhl);
      expect(results.single.trackingNumber, '123456789012');
    });

    test('finds a UPS tracking number', () {
      final results = extractor.extract(
        subject: 'UPS: Ihr Paket kommt heute',
        bodyText: 'Trackingnummer 1Z999AA10123456784',
        senderAddress: 'no-reply@ups.com',
      );

      expect(results, hasLength(1));
      expect(results.single.carrier, Carrier.ups);
      expect(results.single.trackingNumber, '1Z999AA10123456784');
    });

    test('returns no candidate when keyword is present but no number matches', () {
      final results = extractor.extract(
        subject: 'DHL Newsletter',
        bodyText: 'Kein Trackingcode enthalten.',
        senderAddress: 'newsletter@dhl.de',
      );

      expect(results, isEmpty);
    });

    test('returns no candidate when a number-like pattern appears without a carrier keyword', () {
      final results = extractor.extract(
        subject: 'Ihre Rechnung Nr. 123456789012',
        bodyText: 'Betrag: 42,00 EUR',
        senderAddress: 'rechnung@shop.example',
      );

      expect(results, isEmpty);
    });

    test('can find multiple carriers mentioned in the same email', () {
      final results = extractor.extract(
        subject: 'Bestellbestätigung',
        bodyText:
            'DHL Trackingnummer: 123456789012\n'
            'Falls DHL nicht liefert, übernimmt Hermes: HERMES1234567890AB',
        senderAddress: 'shop@example.com',
      );

      expect(results.map((r) => r.carrier), containsAll([Carrier.dhl, Carrier.hermes]));
    });
  });
}
