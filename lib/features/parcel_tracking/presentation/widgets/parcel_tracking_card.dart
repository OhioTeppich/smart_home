import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../home/presentation/widgets/home_card.dart';
import '../../application/mailbox_bloc.dart';
import '../../application/mailbox_state.dart';
import '../../application/parcel_tracking_bloc.dart';
import '../../application/parcel_tracking_state.dart';
import '../pages/parcel_add_page.dart';
import '../pages/parcel_candidate_confirmation_page.dart';
import '../pages/parcel_list_page.dart';
import '../pages/track17_settings_page.dart';
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

        final pendingCandidateCount = context.select<MailboxBloc, int>((bloc) {
          final mailboxState = bloc.state;
          return mailboxState is MailboxReady
              ? mailboxState.pendingCandidates.length
              : 0;
        });
        final candidateBanner = pendingCandidateCount == 0
            ? null
            : Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: () => Navigator.of(context).push<void>(
                    MaterialPageRoute(
                      builder: (_) => const ParcelCandidateConfirmationPage(),
                    ),
                  ),
                  child: Text(
                    '$pendingCandidateCount neue Sendung${pendingCandidateCount == 1 ? '' : 'en'} gefunden',
                    style: const TextStyle(
                      color: AppColors.blueDark,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );

        final parcels = state.parcels;
        final configHint = state.isConfigured
            ? null
            : Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: () => Navigator.of(context).push<void>(
                    MaterialPageRoute(builder: (_) => const Track17SettingsPage()),
                  ),
                  child: const Text(
                    '17Track nicht eingerichtet — Status bleibt unbekannt.',
                    style: TextStyle(color: AppColors.muted, fontSize: 11),
                  ),
                ),
              );

        if (parcels.isEmpty) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (candidateBanner != null) candidateBanner,
              if (configHint != null) configHint,
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
            if (candidateBanner != null) candidateBanner,
            if (configHint != null) configHint,
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
