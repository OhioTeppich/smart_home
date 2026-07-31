import 'package:equatable/equatable.dart';

import '../domain/entities/carrier.dart';
import '../domain/entities/parcel.dart';

sealed class ParcelTrackingEvent extends Equatable {
  const ParcelTrackingEvent();

  @override
  List<Object?> get props => [];
}

class ParcelTrackingStarted extends ParcelTrackingEvent {
  const ParcelTrackingStarted();
}

class ParcelTrackingParcelAdded extends ParcelTrackingEvent {
  const ParcelTrackingParcelAdded({
    required this.carrier,
    required this.trackingNumber,
    this.description,
  });

  final Carrier carrier;
  final String trackingNumber;
  final String? description;

  @override
  List<Object?> get props => [carrier, trackingNumber, description];
}

class ParcelTrackingParcelRemoved extends ParcelTrackingEvent {
  const ParcelTrackingParcelRemoved(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

class ParcelTrackingRefreshRequested extends ParcelTrackingEvent {
  const ParcelTrackingRefreshRequested(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

class ParcelTrackingRefreshAllRequested extends ParcelTrackingEvent {
  const ParcelTrackingRefreshAllRequested();
}

/// Internal: folded from [ParcelRepository.watchParcels].
class ParcelTrackingParcelsUpdated extends ParcelTrackingEvent {
  const ParcelTrackingParcelsUpdated(this.parcels);

  final List<Parcel> parcels;

  @override
  List<Object?> get props => [parcels];
}

/// Internal: folded from [ParcelRepository.watchParcels].
class ParcelTrackingStreamFailed extends ParcelTrackingEvent {
  const ParcelTrackingStreamFailed(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
