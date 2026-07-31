import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../application/mailbox_bloc.dart';
import '../../application/mailbox_event.dart';
import '../../application/mailbox_state.dart';
import '../../domain/entities/carrier.dart';
import '../../domain/entities/parcel_candidate.dart';

/// Shows only carrier, tracking number, subject line, and source account
/// label for each candidate — never the email body, to limit exposure via
/// screenshots/screen recording of this wall-mounted display.
class ParcelCandidateConfirmationPage extends StatelessWidget {
  const ParcelCandidateConfirmationPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.canvas,
    appBar: AppBar(
      backgroundColor: AppColors.canvas,
      title: const Text('Neue Sendungen'),
    ),
    body: BlocBuilder<MailboxBloc, MailboxState>(
      builder: (context, state) {
        final candidates = state is MailboxReady
            ? state.pendingCandidates
            : const <ParcelCandidate>[];
        if (candidates.isEmpty) {
          return const Center(
            child: Text(
              'Keine neuen Sendungen gefunden.',
              style: TextStyle(color: AppColors.muted),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: candidates.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final candidate = candidates[index];
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.blue.withOpacity(.10),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.blue.withOpacity(.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${candidate.carrier.label} · ${candidate.trackingNumber}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    candidate.sourceEmailSubject,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.muted, fontSize: 12),
                  ),
                  Text(
                    'Aus: ${candidate.sourceAccountLabel}',
                    style: const TextStyle(color: AppColors.muted, fontSize: 11),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => context.read<MailboxBloc>().add(
                          MailboxCandidateDismissed(candidate.id),
                        ),
                        child: const Text('Verwerfen'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () => context.read<MailboxBloc>().add(
                          MailboxCandidateConfirmed(candidate),
                        ),
                        style: FilledButton.styleFrom(backgroundColor: AppColors.ink),
                        child: const Text('Übernehmen'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    ),
  );
}
