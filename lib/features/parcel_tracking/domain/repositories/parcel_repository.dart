import '../entities/carrier.dart';
import '../entities/parcel.dart';

abstract class ParcelRepository {
  /// Emits the current parcel list on listen and after every mutation or
  /// polling refresh. Throws a [ParcelTrackingFailure] subtype internally,
  /// mapped and surfaced through the stream by the concrete implementation.
  Stream<List<Parcel>> watchParcels();

  Future<List<Parcel>> fetchParcels();

  /// Throws a [ParcelTrackingFailure] subtype on failure (e.g. no API key,
  /// provider unreachable).
  Future<void> addParcel({
    required Carrier carrier,
    required String trackingNumber,
    String? description,
  });

  Future<void> removeParcel(String id);

  /// Throws a [ParcelTrackingFailure] subtype on failure.
  Future<void> refreshParcel(String id);

  /// Throws a [ParcelTrackingFailure] subtype on failure.
  Future<void> refreshAll();

  /// Whether a tracking-provider API key is stored, so the UI can hint at
  /// setup being needed before the user tries to add a parcel.
  Future<bool> hasApiKeyConfigured();

  Future<void> configureApiKey(String apiKey);

  Future<void> clearApiKey();
}
