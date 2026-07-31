import 'package:flutter_test/flutter_test.dart';
import 'package:smart_home/features/parcel_tracking/domain/entities/carrier.dart';
import 'package:smart_home/features/parcel_tracking/infrastructure/models/carrier_track17_code.dart';

void main() {
  group('CarrierTrack17Code', () {
    test('every known carrier maps to a numeric code', () {
      for (final carrier in Carrier.values.where((c) => c != Carrier.other)) {
        expect(carrier.track17Code, isNotNull, reason: '$carrier should have a code');
      }
    });

    test('Sonstiger has no 17Track code', () {
      expect(Carrier.other.track17Code, isNull);
    });
  });
}
