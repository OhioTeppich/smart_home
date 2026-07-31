import 'package:flutter_test/flutter_test.dart';
import 'package:smart_home/features/parcel_tracking/domain/entities/carrier.dart';
import 'package:smart_home/features/parcel_tracking/domain/entities/parcel.dart';
import 'package:smart_home/features/parcel_tracking/domain/entities/parcel_status.dart';
import 'package:smart_home/features/parcel_tracking/domain/services/parcel_sorter.dart';

Parcel _parcel(String id, ParcelStatus status, DateTime lastUpdate) => Parcel(
  id: id,
  carrier: Carrier.dhl,
  trackingNumber: id,
  status: status,
  lastUpdate: lastUpdate,
  addedAt: lastUpdate,
);

void main() {
  group('sortParcelsForDisplay', () {
    test('delivered parcels sort after active ones regardless of recency', () {
      final delivered = _parcel('a', ParcelStatus.delivered, DateTime(2026, 1, 10));
      final active = _parcel('b', ParcelStatus.inTransit, DateTime(2026, 1, 1));

      final sorted = sortParcelsForDisplay([delivered, active]);

      expect(sorted.map((p) => p.id), ['b', 'a']);
    });

    test('within the same group, most recently updated comes first', () {
      final older = _parcel('a', ParcelStatus.inTransit, DateTime(2026, 1, 1));
      final newer = _parcel('b', ParcelStatus.inTransit, DateTime(2026, 1, 5));

      final sorted = sortParcelsForDisplay([older, newer]);

      expect(sorted.map((p) => p.id), ['b', 'a']);
    });

    test('does not mutate the input list', () {
      final list = [
        _parcel('a', ParcelStatus.delivered, DateTime(2026, 1, 1)),
        _parcel('b', ParcelStatus.inTransit, DateTime(2026, 1, 2)),
      ];
      final originalOrder = list.map((p) => p.id).toList();

      sortParcelsForDisplay(list);

      expect(list.map((p) => p.id).toList(), originalOrder);
    });
  });
}
