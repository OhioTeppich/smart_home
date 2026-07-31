import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'app/app_scale.dart';
import 'app/shell/app_shell.dart';
import 'features/energy/application/energy_dashboard_controller.dart';
import 'features/energy/infrastructure/data_sources/energy_local_data_source.dart';
import 'features/energy/infrastructure/repositories/energy_repository_impl.dart';
import 'features/ha_connection/application/ha_connection_bloc.dart';
import 'features/ha_connection/application/ha_connection_event.dart';
import 'features/ha_connection/application/ha_connection_state.dart';
import 'features/ha_connection/domain/value_objects/ha_connection_config.dart';
import 'features/ha_connection/infrastructure/data_sources/ha_connection_local_data_source.dart';
import 'features/ha_connection/infrastructure/repositories/ha_connection_repository_impl.dart';
import 'features/parcel_tracking/application/parcel_tracking_bloc.dart';
import 'features/parcel_tracking/application/parcel_tracking_event.dart';
import 'features/parcel_tracking/infrastructure/data_sources/parcel_local_data_source.dart';
import 'features/parcel_tracking/infrastructure/repositories/track17_parcel_repository.dart';
import 'features/quick_access/application/quick_access_bloc.dart';
import 'features/quick_access/application/quick_access_event.dart';
import 'features/quick_access/infrastructure/data_sources/quick_access_local_data_source.dart';
import 'features/quick_access/infrastructure/repositories/quick_access_repository_impl.dart';
import 'features/rooms/application/smart_home_bloc.dart';
import 'features/rooms/application/smart_home_event.dart';
import 'features/rooms/application/smart_home_state.dart';
import 'features/rooms/infrastructure/repositories/home_assistant_smart_home_repository.dart';
import 'features/home/application/home_controller.dart';
import 'features/spotify/application/spotify_bloc.dart';
import 'features/spotify/application/spotify_event.dart';
import 'features/spotify/infrastructure/data_sources/spotify_local_data_source.dart';
import 'features/spotify/infrastructure/repositories/spotify_repository_impl.dart';

class SmartHomeApp extends StatelessWidget {
  const SmartHomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final energyController = EnergyDashboardController(
      EnergyRepositoryImpl(EnergyLocalDataSource()),
    )..start();
    return EnergyScope(
      // Same reasoning as the comment below on `HaConnectionBloc`/
      // `QuickAccessBloc`: `EnergyScope.of(context)` is used from pages
      // pushed via `Navigator.push` (e.g. the energy price settings page,
      // reached through the settings hub) — those become sibling routes on
      // the root Navigator, not descendants of `home:`, so `EnergyScope`
      // must live above `MaterialApp` to be visible there too.
      controller: energyController,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => HaConnectionBloc(
              HaConnectionRepositoryImpl(HaConnectionLocalDataSource()),
            )..add(const HaConnectionStarted()),
          ),
          BlocProvider(
            create: (context) => QuickAccessBloc(
              QuickAccessRepositoryImpl(QuickAccessLocalDataSource()),
            )..add(const QuickAccessStarted()),
          ),
          BlocProvider(
            create: (context) => SpotifyBloc(
              SpotifyRepositoryImpl(SpotifyLocalDataSource()),
            )..add(const SpotifyStarted()),
          ),
          BlocProvider(
            create: (context) => ParcelTrackingBloc(
              Track17ParcelRepository(ParcelLocalDataSource()),
            )..add(const ParcelTrackingStarted()),
          ),
        ],
        // Both blocs must live above `MaterialApp`, not inside `home:`.
        // Dialogs opened with `showDialog` and pages pushed with
        // `Navigator.push` become sibling routes on the same root Navigator,
        // not descendants of whatever page opened them — so any provider
        // placed inside `home:` (like `AppShell`) is invisible to them. Only
        // providers above the Navigator (i.e. above `MaterialApp`) are seen
        // by every route.
        child: BlocBuilder<HaConnectionBloc, HaConnectionState>(
          buildWhen: (previous, current) => _configOf(previous) != _configOf(current),
          builder: (context, state) {
            final config = _configOf(state);
            return BlocProvider<SmartHomeBloc>(
              // A changed key makes Flutter tear down the old provider
              // element (closing the old bloc) and create a fresh one,
              // rebuilding `SmartHomeBloc` whenever the connection changes.
              key: ValueKey(config),
              create: (context) => SmartHomeBloc(
                HomeAssistantSmartHomeRepository(config: config),
              )..add(const SmartHomeStarted()),
              child: MaterialApp(
                title: 'Smart Home',
                debugShowCheckedModeBanner: false,
                scrollBehavior: const SmartHomeScrollBehavior(),
                theme: AppTheme.light,
                builder: (context, child) => AppScale(
                  scale: 1.12,
                  child: child ?? const SizedBox.shrink(),
                ),
                home: BlocListener<SmartHomeBloc, SmartHomeState>(
                  listener: (context, state) {
                    if (state is SmartHomeConnected) {
                      energyController.updateDevices(state.devices);
                    }
                  },
                  child: HomeScope(
                    controller: HomeController()..start(),
                    child: const AppShell(),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  HaConnectionConfig? _configOf(HaConnectionState state) =>
      state is HaConnectionReady ? state.savedConfig : null;
}
