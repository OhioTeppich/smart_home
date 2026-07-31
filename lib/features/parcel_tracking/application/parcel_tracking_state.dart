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
  const ParcelTrackingReady({
    required this.parcels,
    required this.isConfigured,
    this.isRefreshing = false,
  });

  final List<Parcel> parcels;

  /// Whether a tracking-provider API key is stored. `false` doesn't block
  /// viewing/removing already-tracked parcels — it only hints that adding a
  /// new one (or refreshing status) needs setup first.
  final bool isConfigured;
  final bool isRefreshing;

  ParcelTrackingReady copyWith({
    List<Parcel>? parcels,
    bool? isConfigured,
    bool? isRefreshing,
  }) => ParcelTrackingReady(
    parcels: parcels ?? this.parcels,
    isConfigured: isConfigured ?? this.isConfigured,
    isRefreshing: isRefreshing ?? this.isRefreshing,
  );

  @override
  List<Object?> get props => [parcels, isConfigured, isRefreshing];
}

class ParcelTrackingError extends ParcelTrackingState {
  const ParcelTrackingError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
