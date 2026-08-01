import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/carrier.dart';
import '../../domain/entities/parcel.dart';
import '../../domain/entities/parcel_status.dart';

class ParcelListTile extends StatelessWidget {
  const ParcelListTile({required this.parcel, this.onRemove, super.key});

  final Parcel parcel;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: AppColors.blue.withOpacity(.10),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.blue.withOpacity(.25)),
    ),
    child: Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.blueDark,
            borderRadius: BorderRadius.circular(9),
          ),
          child: const Icon(
            Icons.local_shipping_rounded,
            size: 16,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                parcel.description ?? parcel.carrier.label,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
              Text(
                '${parcel.carrier.label} · ${parcel.trackingNumber}',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: const TextStyle(color: AppColors.muted, fontSize: 11),
              ),
              if (_estimatedDeliveryLabel(parcel) case final label?)
                Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: const TextStyle(color: AppColors.muted, fontSize: 11),
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _statusColor(parcel.status).withOpacity(.16),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            parcel.status.label,
            style: TextStyle(
              color: _statusColor(parcel.status),
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (onRemove != null)
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 18),
            color: AppColors.muted,
            onPressed: onRemove,
          ),
      ],
    ),
  );

  /// `null` once delivered (an ETA no longer means anything) or when 17Track
  /// hasn't given one for this parcel yet.
  String? _estimatedDeliveryLabel(Parcel parcel) {
    final estimatedDelivery = parcel.estimatedDelivery;
    if (estimatedDelivery == null || parcel.status == ParcelStatus.delivered) {
      return null;
    }
    final day = estimatedDelivery.day.toString().padLeft(2, '0');
    final month = estimatedDelivery.month.toString().padLeft(2, '0');
    return 'Vorauss. $day.$month.';
  }

  Color _statusColor(ParcelStatus status) => switch (status) {
    ParcelStatus.unknown => AppColors.muted,
    ParcelStatus.inTransit => AppColors.blueDark,
    ParcelStatus.outForDelivery => Colors.orange,
    ParcelStatus.delivered => AppColors.green,
    ParcelStatus.exception => Colors.red,
  };
}
