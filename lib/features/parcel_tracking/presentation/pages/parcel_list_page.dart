import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../application/parcel_tracking_bloc.dart';
import '../../application/parcel_tracking_event.dart';
import '../../application/parcel_tracking_state.dart';
import '../widgets/parcel_list_tile.dart';
import 'parcel_add_page.dart';

class ParcelListPage extends StatefulWidget {
  const ParcelListPage({super.key});

  @override
  State<ParcelListPage> createState() => _ParcelListPageState();
}

class _ParcelListPageState extends State<ParcelListPage> {
  @override
  void initState() {
    super.initState();
    // Opening the list is also a natural point to catch up on status —
    // otherwise a parcel added between two 10-minute polls would show
    // "Unbekannt" here until the next background poll fires.
    context.read<ParcelTrackingBloc>().add(const ParcelTrackingRefreshAllRequested());
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.canvas,
    appBar: AppBar(
      backgroundColor: AppColors.canvas,
      title: const Text('Pakete'),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded),
          onPressed: () => context.read<ParcelTrackingBloc>().add(
            const ParcelTrackingRefreshAllRequested(),
          ),
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () => Navigator.of(context).push<void>(
        MaterialPageRoute(builder: (_) => const ParcelAddPage()),
      ),
      child: const Icon(Icons.add_rounded),
    ),
    body: BlocBuilder<ParcelTrackingBloc, ParcelTrackingState>(
      builder: (context, state) {
        if (state is ParcelTrackingError) {
          return Center(
            child: Text(
              state.message,
              style: const TextStyle(color: AppColors.muted),
            ),
          );
        }
        if (state is! ParcelTrackingReady) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.parcels.isEmpty) {
          return const Center(
            child: Text(
              'Keine Pakete verfolgt.',
              style: TextStyle(color: AppColors.muted),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: state.parcels.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final parcel = state.parcels[index];
            return ParcelListTile(
              parcel: parcel,
              onRemove: () => context.read<ParcelTrackingBloc>().add(
                ParcelTrackingParcelRemoved(parcel.id),
              ),
            );
          },
        );
      },
    ),
  );
}
