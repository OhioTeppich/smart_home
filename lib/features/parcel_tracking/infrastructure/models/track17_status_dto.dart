import '../../domain/entities/parcel_status.dart';

class Track17StatusDto {
  const Track17StatusDto({
    required this.trackingNumber,
    required this.status,
    this.subStatus,
    this.estimatedDelivery,
  });

  final String trackingNumber;
  final String status;
  final String? subStatus;

  /// From `track_info.time_metrics.estimated_delivery_date.to` (falls back
  /// to `.from` if only that's present) — `null` when 17Track has no
  /// estimate yet for this carrier/shipment.
  final DateTime? estimatedDelivery;

  factory Track17StatusDto.fromJson(Map<String, dynamic> json) {
    final trackInfo = json['track_info'] as Map<String, dynamic>? ?? const {};
    final latestStatus =
        trackInfo['latest_status'] as Map<String, dynamic>? ?? const {};
    final timeMetrics = trackInfo['time_metrics'] as Map<String, dynamic>? ?? const {};
    final estimatedDeliveryDate =
        timeMetrics['estimated_delivery_date'] as Map<String, dynamic>? ?? const {};
    final estimatedDeliveryRaw =
        estimatedDeliveryDate['to'] as String? ?? estimatedDeliveryDate['from'] as String?;
    return Track17StatusDto(
      trackingNumber: json['number'] as String,
      status: latestStatus['status'] as String? ?? 'NotFound',
      subStatus: latestStatus['sub_status'] as String?,
      estimatedDelivery: estimatedDeliveryRaw == null
          ? null
          : DateTime.tryParse(estimatedDeliveryRaw),
    );
  }

  /// Maps 17Track's status enum to our own — see 17Track API v2.4 docs for
  /// the full set of values this can take.
  ParcelStatus toParcelStatus() => switch (status) {
    'InTransit' => ParcelStatus.inTransit,
    'OutForDelivery' || 'AvailableForPickup' => ParcelStatus.outForDelivery,
    'Delivered' => ParcelStatus.delivered,
    'Expired' || 'DeliveryFailure' || 'Exception' => ParcelStatus.exception,
    _ => ParcelStatus.unknown,
  };
}
