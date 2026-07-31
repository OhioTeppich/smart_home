import '../../domain/entities/carrier.dart';
import '../../domain/entities/parcel.dart';
import '../../domain/entities/parcel_status.dart';

class ParcelRecordDto {
  const ParcelRecordDto({
    required this.id,
    required this.carrier,
    required this.trackingNumber,
    required this.status,
    required this.lastUpdate,
    required this.addedAt,
    this.description,
    this.estimatedDelivery,
  });

  final String id;
  final String carrier;
  final String trackingNumber;
  final String status;
  final String lastUpdate;
  final String addedAt;
  final String? description;
  final String? estimatedDelivery;

  factory ParcelRecordDto.fromDomain(Parcel parcel) => ParcelRecordDto(
    id: parcel.id,
    carrier: parcel.carrier.name,
    trackingNumber: parcel.trackingNumber,
    status: parcel.status.name,
    lastUpdate: parcel.lastUpdate.toIso8601String(),
    addedAt: parcel.addedAt.toIso8601String(),
    description: parcel.description,
    estimatedDelivery: parcel.estimatedDelivery?.toIso8601String(),
  );

  Parcel toDomain() => Parcel(
    id: id,
    carrier: Carrier.values.byName(carrier),
    trackingNumber: trackingNumber,
    status: ParcelStatus.values.byName(status),
    lastUpdate: DateTime.parse(lastUpdate),
    addedAt: DateTime.parse(addedAt),
    description: description,
    estimatedDelivery: estimatedDelivery == null
        ? null
        : DateTime.parse(estimatedDelivery!),
  );

  factory ParcelRecordDto.fromJson(Map<String, dynamic> json) => ParcelRecordDto(
    id: json['id'] as String,
    carrier: json['carrier'] as String,
    trackingNumber: json['trackingNumber'] as String,
    status: json['status'] as String,
    lastUpdate: json['lastUpdate'] as String,
    addedAt: json['addedAt'] as String,
    description: json['description'] as String?,
    estimatedDelivery: json['estimatedDelivery'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'carrier': carrier,
    'trackingNumber': trackingNumber,
    'status': status,
    'lastUpdate': lastUpdate,
    'addedAt': addedAt,
    'description': description,
    'estimatedDelivery': estimatedDelivery,
  };
}
