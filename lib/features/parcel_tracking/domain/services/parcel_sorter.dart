import '../entities/parcel.dart';
import '../entities/parcel_status.dart';

/// Active (not yet delivered) parcels first, most recently updated first
/// within each group — keeps what still needs attention at the top of the
/// Home-screen card's capped preview instead of old delivered parcels.
List<Parcel> sortParcelsForDisplay(List<Parcel> parcels) {
  final sorted = [...parcels];
  sorted.sort((a, b) {
    final aDelivered = a.status == ParcelStatus.delivered ? 1 : 0;
    final bDelivered = b.status == ParcelStatus.delivered ? 1 : 0;
    if (aDelivered != bDelivered) return aDelivered - bDelivered;
    return b.lastUpdate.compareTo(a.lastUpdate);
  });
  return sorted;
}
