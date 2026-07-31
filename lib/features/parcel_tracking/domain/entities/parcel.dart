import 'package:equatable/equatable.dart';

import 'carrier.dart';
import 'parcel_status.dart';

class Parcel extends Equatable {
  const Parcel({
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
  final Carrier carrier;
  final String trackingNumber;
  final ParcelStatus status;
  final DateTime lastUpdate;
  final DateTime addedAt;
  final String? description;
  final DateTime? estimatedDelivery;

  Parcel copyWith({
    ParcelStatus? status,
    DateTime? lastUpdate,
    String? description,
    DateTime? estimatedDelivery,
  }) => Parcel(
    id: id,
    carrier: carrier,
    trackingNumber: trackingNumber,
    status: status ?? this.status,
    lastUpdate: lastUpdate ?? this.lastUpdate,
    addedAt: addedAt,
    description: description ?? this.description,
    estimatedDelivery: estimatedDelivery ?? this.estimatedDelivery,
  );

  @override
  List<Object?> get props => [
    id,
    carrier,
    trackingNumber,
    status,
    lastUpdate,
    addedAt,
    description,
    estimatedDelivery,
  ];
}
