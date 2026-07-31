import 'package:equatable/equatable.dart';

import '../domain/entities/parcel.dart';

sealed class ParcelTrackingState extends Equatable {
  const ParcelTrackingState();

  @override
  List<Object?> get props => [];
}

class ParcelTrackingInitial extends ParcelTrackingState {
  const ParcelTrackingInitial();
}

class ParcelTrackingLoading extends ParcelTrackingState {
  const ParcelTrackingLoading();
}

class ParcelTrackingReady extends ParcelTrackingState {
  const ParcelTrackingReady({required this.parcels, this.isRefreshing = false});

  final List<Parcel> parcels;
  final bool isRefreshing;

  ParcelTrackingReady copyWith({List<Parcel>? parcels, bool? isRefreshing}) =>
      ParcelTrackingReady(
        parcels: parcels ?? this.parcels,
        isRefreshing: isRefreshing ?? this.isRefreshing,
      );

  @override
  List<Object?> get props => [parcels, isRefreshing];
}

class ParcelTrackingError extends ParcelTrackingState {
  const ParcelTrackingError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
