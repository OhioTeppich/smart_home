import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../home/presentation/widgets/home_card.dart';
import '../../application/parcel_tracking_bloc.dart';
import '../../application/parcel_tracking_state.dart';
import '../pages/parcel_add_page.dart';
import '../pages/parcel_list_page.dart';
import 'parcel_list_tile.dart';

/// Unlike `WeatherCard`/`MarketsCard`, this card has no `HomeCardTitle`
/// header — just the tracked-parcel content, matching `QuickAccessCard`'s
/// equally header-less sibling in the same row.
class ParcelTrackingCard extends StatelessWidget {
  const ParcelTrackingCard({super.key});

  static const _maxVisible = 3;

  @override
  Widget build(BuildContext context) => HomeCard(
    child: BlocBuilder<ParcelTrackingBloc, ParcelTrackingState>(
      builder: (context, state) {
        if (state is ParcelTrackingError) {
          return Center(
            child: Text(
              state.message,
              style: const TextStyle(color: AppColors.muted, fontSize: 12),
            ),
          );
        }
        if (state is! ParcelTrackingReady) {
          return const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        final parcels = state.parcels;
        if (parcels.isEmpty) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Keine Pakete verfolgt.',
                style: TextStyle(color: AppColors.muted, fontSize: 12),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => Navigator.of(context).push<void>(
                    MaterialPageRoute(builder: (_) => const ParcelAddPage()),
                  ),
                  child: const Text('Paket hinzufügen'),
                ),
              ),
            ],
          );
        }

        final visible = parcels.take(_maxVisible).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final parcel in visible) ...[
              ParcelListTile(parcel: parcel),
              if (parcel != visible.last) const SizedBox(height: 8),
            ],
            if (parcels.length > _maxVisible)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).push<void>(
                    MaterialPageRoute(builder: (_) => const ParcelListPage()),
                  ),
                  child: const Text('Alle anzeigen'),
                ),
              ),
          ],
        );
      },
    ),
  );
}
