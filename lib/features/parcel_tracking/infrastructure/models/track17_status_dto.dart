import '../../domain/entities/parcel_status.dart';

class Track17StatusDto {
  const Track17StatusDto({
    required this.trackingNumber,
    required this.status,
    this.subStatus,
  });

  final String trackingNumber;
  final String status;
  final String? subStatus;

  factory Track17StatusDto.fromJson(Map<String, dynamic> json) {
    final trackInfo = json['track_info'] as Map<String, dynamic>? ?? const {};
    final latestStatus =
        trackInfo['latest_status'] as Map<String, dynamic>? ?? const {};
    return Track17StatusDto(
      trackingNumber: json['number'] as String,
      status: latestStatus['status'] as String? ?? 'NotFound',
      subStatus: latestStatus['sub_status'] as String?,
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
