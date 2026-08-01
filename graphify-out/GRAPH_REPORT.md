# Graph Report - smart_home  (2026-08-01)

## Corpus Check
- 166 files · ~112,736 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1911 nodes · 2706 edges · 155 communities (114 shown, 41 thin omitted)
- Extraction: 99% EXTRACTED · 1% INFERRED · 0% AMBIGUOUS · INFERRED: 15 edges (avg confidence: 0.82)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `8bf88161`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- ha_websocket_client_test.dart
- home_controller.dart
- home_models.dart
- energy_local_data_source.dart
- app_shell.dart
- energy_overview_page.dart
- energy_repository_impl.dart
- weather_card.dart
- room_dialogs.dart
- smart_home package
- energy_metric_widgets.dart
- smart_home_device.dart
- app_theme.dart
- .application
- app_navigation.dart
- spotify_local_data_source.dart
- room_map.dart
- manifest.json
- home_assistant_smart_home_repository.dart
- smart_home_bloc_test.dart
- Global App Shell (app/shell)
- BLoC pattern (flutter_bloc)
- Living Room Photo (Top-Down Interior)
- Smart Home Architekturstandard
- MainActivity
- Flutter framework
- Automatic Git commit/push workflow
- App Icon (Default Flutter Logo)
- iOS Launch Screen Assets
- lib/ main code directory
- Naming and UI rules (snake_case/PascalCase/camelCase, German UI text)
- test/ directory
- manifest.json web app manifest
- room_page_test.dart
- smart_home_bloc.dart
- quick_access_card.dart
- ../../features/rooms/domain/entities/smart_home_device.dart
- room_page.dart
- SmartHomeDevice? get
- home_data_service.dart
- energy_chart_widgets.dart
- InheritedNotifier
- app.dart
- mailbox_event.dart
- imap_scan_data_source.dart
- mailbox_settings_page.dart
- tracking_number_extractor.dart
- SpotifyBloc
- ../entities/energy_dashboard_data.dart
- ha_entity_state_dto.dart
- home_page.dart
- ../../application/controllers/smart_home_controller.dart
- features/energy/infrastructure/repositories/in_memory_energy_repository.dart
- parcel.dart
- ha_device_overlay_local_data_source.dart
- energy_dashboard_controller.dart
- app_navigation_event.dart
- ../../../rooms/presentation/state/smart_home_scope.dart
- ha_rest_client.dart
- ../state/smart_home_scope.dart
- markets_card.dart
- SpotifyAuthenticating
- energy_dashboard_data.dart
- smart_home_repository.dart
- String?
- quick_access_limits.dart
- DeviceRanking
- features/rooms/application/controllers/smart_home_controller.dart
- features/rooms/infrastructure/repositories/in_memory_smart_home_repository.dart
- ../../features/rooms/presentation/state/smart_home_scope.dart
- SmartHomeDeviceType
- top_devices_card.dart
- ../widgets/top_devices_card.dart
- SmartHomeBloc
- mailbox_bloc_test.dart
- package:flutter/material.dart
- StatelessWidget
- spotify_bloc.dart
- spotify_bloc_test.dart
- ../../../../core/theme/app_theme.dart
- home_card.dart
- parcel_tracking_event.dart
- quick_access_bloc.dart
- ha_websocket_client.dart
- spotify_now_playing_card.dart
- HomeController
- spotify_repository_impl.dart
- spotify_auth_data_source.dart
- spotify_repository.dart
- spotify_state.dart
- Equatable
- spotify_pkce_helper.dart
- spotify_remote_data_source.dart
- SpotifyFailure
- List
- track17_parcel_repository.dart
- track17_remote_data_source.dart
- parcel_add_page.dart
- parcel_tracking_bloc.dart
- package:flutter_test/flutter_test.dart
- parcel_candidate.dart
- ../../domain/entities/smart_home_device.dart
- dart:async
- spotify_playback_command.dart
- mailbox_account.dart
- parcel_tracking_failure.dart
- mailbox_bloc.dart
- mailbox_repository.dart
- spotify_web_playback_sdk_stub.dart
- spotify_web_playback_sdk.dart
- SpotifyError
- SpotifyIdle
- SpotifyInitial
- SpotifyPlaying
- SpotifyState
- SpotifyUnauthenticated
- mailbox_credentials_local_data_source.dart
- parcel_tracking_card.dart
- parcel_tracking_bloc_test.dart
- parcel_record_dto.dart
- static const
- parcel_tracking_state.dart
- parcel_repository.dart
- ../../domain/entities/carrier.dart
- parcel_list_tile.dart
- State
- mailbox_state.dart
- HomeAssistantSmartHomeRepository
- imap_mailbox_repository.dart
- AppNavigationBloc
- DateTime
- room_device_list.dart
- package:smart_home/features/parcel_tracking/domain/entities/carrier.dart
- parcel_sorter_test.dart
- spotify_currently_playing_dto.dart
- ParcelRepository
- energy_period_selector.dart
- track17_api_key_local_data_source.dart
- main
- spotify_auth_config_test.dart
- _FakeHaConnectionRepository
- package:flutter_bloc/flutter_bloc.dart
- horizontal_page_scaffold.dart
- _SnapScrollPhysics
- ScrollNotification
- static const double
- package:shared_preferences/shared_preferences.dart
- _Track17SettingsPageState
- String get
- SmartHomeDeviceType

## God Nodes (most connected - your core abstractions)
1. `ParcelTrackingBloc` - 23 edges
2. `SpotifyBloc` - 21 edges
3. `SmartHomeBloc` - 19 edges
4. `MailboxBloc` - 17 edges
5. `SmartHomeEvent` - 13 edges
6. `QuickAccessBloc` - 12 edges
7. `ParcelTrackingEvent` - 11 edges
8. `SpotifyEvent` - 11 edges
9. `MailboxEvent` - 9 edges
10. `SpotifyState` - 9 edges

## Surprising Connections (you probably didn't know these)
- `Smart Home (product)` --semantically_similar_to--> `smart_home package`  [INFERRED] [semantically similar]
  AGENTS.md → pubspec.yaml
- `Smart Home (product)` --semantically_similar_to--> `Smart Home (product)`  [INFERRED] [semantically similar]
  AGENTS.md → README.md
- `Smart Home (product)` --semantically_similar_to--> `Smart Home (product, web title)`  [INFERRED] [semantically similar]
  AGENTS.md → web/index.html
- `Smart Home (product, web title)` --semantically_similar_to--> `Smart Home (product)`  [INFERRED] [semantically similar]
  web/index.html → README.md
- `shared_preferences ^2.5.3 dependency` --conceptually_related_to--> `Infrastructure layer`  [INFERRED]
  pubspec.yaml → ARCHITECTURE.md

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **DDD Four-Layer Architecture (Domain/Application/Infrastructure/Presentation)** — architecture_domain_layer, architecture_application_layer, architecture_infrastructure_layer, architecture_presentation_layer [EXTRACTED 0.95]
- **Infrastructure DataSource-Model/DTO-Repository triad** — architecture_datasource, architecture_model_dto, architecture_repository_pattern [EXTRACTED 1.00]
- **BLoC Event-State Data Flow (Presentation-BLoC-Application-Domain)** — architecture_presentation_layer, architecture_bloc_pattern, architecture_application_layer, architecture_domain_layer [EXTRACTED 1.00]

## Communities (155 total, 41 thin omitted)

### Community 0 - "ha_websocket_client_test.dart"
Cohesion: 0.10
Nodes (19): HaAuthException, HaConnectionException, HttpServer, package:smart_home/core/home_assistant/ha_client_exceptions.dart, package:smart_home/core/home_assistant/ha_websocket_client.dart, baseUrl, close, disconnectClient (+11 more)

### Community 1 - "home_controller.dart"
Cohesion: 0.07
Nodes (28): ../infrastructure/home_data_service.dart, build, child, controller, DeviceRanking, dispose, loadingWeather, _market (+20 more)

### Community 2 - "home_models.dart"
Cohesion: 0.06
Nodes (34): change, changePercent, condition, currency, feelsLike, hourly, HourlyWeatherPoint, humidity (+26 more)

### Community 3 - "energy_local_data_source.dart"
Cohesion: 0.14
Nodes (13): _currentDayKey, date, _historyDaysKey, _priceKey, readCurrentDay, readHistoryDays, readings, readPricePerKwh (+5 more)

### Community 4 - "app_shell.dart"
Cohesion: 0.07
Nodes (29): app_navigation_bloc.dart, app_navigation.dart, ../../features/energy/domain/entities/energy_point.dart, ../../features/energy/presentation/pages/energy_analysis_page.dart, ../../features/energy/presentation/pages/energy_overview_page.dart, ../../features/energy/presentation/widgets/energy_period_selector.dart, ../../features/home/presentation/pages/home_page.dart, ../../features/rooms/presentation/pages/room_page.dart (+21 more)

### Community 5 - "energy_overview_page.dart"
Cohesion: 0.11
Nodes (20): energy_price_settings_page.dart, EnergyDashboardController, AnalysisPage, build, onBack, period, build, compact (+12 more)

### Community 6 - "energy_repository_impl.dart"
Cohesion: 0.10
Nodes (18): ../data_sources/energy_local_data_source.dart, ../domain/repositories/energy_repository.dart, EnergyRepository, loadHistory, loadPricePerKwh, recordReadings, savePricePerKwh, EnergyLocalDataSource (+10 more)

### Community 7 - "weather_card.dart"
Cohesion: 0.10
Nodes (21): allowImplicitScrolling, applyTo, build, _centerCurrentHour, _centeredWeather, createBallisticSimulation, createState, dispose (+13 more)

### Community 8 - "room_dialogs.dart"
Cohesion: 0.09
Nodes (23): AddDeviceDialog, _AddDeviceDialogState, build, CoverControlRow, createState, device, devices, dispose (+15 more)

### Community 9 - "smart_home package"
Cohesion: 0.08
Nodes (31): Smart Home (product), flutter_lints lint rule set (package:flutter_lints/flutter.yaml), AddRoomDevice use case, Application layer, DataSource (technical communication with API/Home Assistant/storage), Domain-Driven Design principles, Domain layer, EnergyChartCard widget (+23 more)

### Community 10 - "energy_metric_widgets.dart"
Cohesion: 0.09
Nodes (21): Color, DeviceUsage, ../../domain/entities/device_usage.dart, IconData, color, DeviceUsage, icon, kwh (+13 more)

### Community 11 - "smart_home_device.dart"
Cohesion: 0.08
Nodes (25): assignToRoom, canToggle, copyWith, coverPosition, coverRawState, dailyKwh, dailyKwhIsCumulative, hasEnergyData (+17 more)

### Community 12 - "app_theme.dart"
Cohesion: 0.10
Nodes (20): dart:ui, AppColors, AppTheme, blue, blueDark, brown, canvas, dragDevices (+12 more)

### Community 13 - ".application"
Cohesion: 0.15
Nodes (10): Any, Bool, Flutter, FlutterAppDelegate, AppDelegate, RunnerTests, UIApplication, UIKit (+2 more)

### Community 14 - "app_navigation.dart"
Cohesion: 0.07
Nodes (26): AppSection, build, compact, createState, current, dispose, _germanMonths, icon (+18 more)

### Community 15 - "spotify_local_data_source.dart"
Cohesion: 0.14
Nodes (13): clearRefreshToken, clientId, _clientIdKey, read, redirectUri, _redirectUriKey, refreshToken, _refreshTokenKey (+5 more)

### Community 16 - "room_map.dart"
Cohesion: 0.13
Nodes (15): build, createState, device, devices, EmptyMapHint, HoverInfo, hovering, imageAsset (+7 more)

### Community 17 - "manifest.json"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 18 - "home_assistant_smart_home_repository.dart"
Cohesion: 0.05
Nodes (41): ../../../../core/home_assistant/ha_client_exceptions.dart, ../../../../core/home_assistant/ha_rest_client.dart, ../../../../core/home_assistant/ha_websocket_client.dart, ../data_sources/ha_area_alias_mapper.dart, ../data_sources/ha_device_overlay_local_data_source.dart, ../../../ha_connection/domain/value_objects/ha_connection_config.dart, HaAreaAliasMapper, HaDeviceOverlayLocalDataSource (+33 more)

### Community 19 - "smart_home_bloc_test.dart"
Cohesion: 0.07
Nodes (26): _FakeSmartHomeRepository, Object?, package:smart_home/features/rooms/application/smart_home_bloc.dart, package:smart_home/features/rooms/application/smart_home_event.dart, package:smart_home/features/rooms/application/smart_home_state.dart, package:smart_home/features/rooms/domain/entities/cover_action.dart, package:smart_home/features/rooms/domain/entities/smart_home_device.dart, package:smart_home/features/rooms/domain/failures/smart_home_failure.dart (+18 more)

### Community 20 - "Global App Shell (app/shell)"
Cohesion: 0.50
Nodes (4): Composition Root (app.dart), Global App Shell (app/shell), AppNavigationBar widget, Composition Root (app/)

### Community 21 - "BLoC pattern (flutter_bloc)"
Cohesion: 0.50
Nodes (4): AppNavigationBloc, BLoC pattern (flutter_bloc), Energy feature BLoC, Rooms feature BLoC

### Community 22 - "Living Room Photo (Top-Down Interior)"
Cohesion: 0.50
Nodes (4): Warm Ambient Lighting (Floor Lamp and Sunlight Streaks), Living Room Photo (Top-Down Interior), Living Room (Room Type), Sofa, Armchair and Ottoman Seating Arrangement

### Community 23 - "Smart Home Architekturstandard"
Cohesion: 0.67
Nodes (3): AGENTS.md Agent Guidelines, Smart Home Architekturstandard, Reso-Coder Flutter/Firebase DDD Course Article

### Community 37 - "room_page_test.dart"
Cohesion: 0.08
Nodes (25): HaConnectionConfig?, package:smart_home/features/ha_connection/application/ha_connection_bloc.dart, package:smart_home/features/ha_connection/application/ha_connection_event.dart, package:smart_home/features/ha_connection/domain/repositories/ha_connection_repository.dart, package:smart_home/features/ha_connection/domain/value_objects/ha_connection_config.dart, package:smart_home/features/rooms/presentation/pages/room_page.dart, assignDeviceToRoom, clearConfig (+17 more)

### Community 38 - "smart_home_bloc.dart"
Cohesion: 0.07
Nodes (47): ../../domain/entities/cover_action.dart, ../../domain/failures/smart_home_failure.dart, ../../domain/repositories/smart_home_repository.dart, close, _devicesSubscription, _messageFor, _onCoverActionRequested, _onDeviceAssignedToRoom (+39 more)

### Community 39 - "quick_access_card.dart"
Cohesion: 0.15
Nodes (15): build, devices, hasLoaded, kQuickAccessTileGap, props, QuickAccessCard, _QuickAccessGrid, resolved (+7 more)

### Community 41 - "room_page.dart"
Cohesion: 0.09
Nodes (26): ../../application/smart_home_state.dart, ../../../ha_connection/application/ha_connection_bloc.dart, ../../../ha_connection/application/ha_connection_state.dart, ../../../ha_connection/presentation/pages/ha_connection_settings_page.dart, HaConnectionBloc, SmartHomeApp, build, device (+18 more)

### Community 43 - "home_data_service.dart"
Cohesion: 0.10
Nodes (19): _btcSocket, _btcSubscription, currentLocation, _demo, dispose, _fallbackLocation, fetch, _fetchYahooIndex (+11 more)

### Community 44 - "energy_chart_widgets.dart"
Cohesion: 0.15
Nodes (14): CustomPainter, EnergyDashboardController, EnergyScope, build, ChartCard, EnergyChartPainter, highlightIndex, onDetails (+6 more)

### Community 46 - "app.dart"
Cohesion: 0.05
Nodes (38): app/app_scale.dart, app/shell/app_shell.dart, features/energy/application/energy_dashboard_controller.dart, features/energy/infrastructure/data_sources/energy_local_data_source.dart, features/energy/infrastructure/repositories/energy_repository_impl.dart, features/ha_connection/application/ha_connection_bloc.dart, features/ha_connection/application/ha_connection_event.dart, features/ha_connection/application/ha_connection_state.dart (+30 more)

### Community 47 - "mailbox_event.dart"
Cohesion: 0.21
Nodes (18): MailboxBloc, account, accountId, candidate, candidateId, MailboxAccountRemoved, MailboxAccountSaveRequested, MailboxCandidateConfirmed (+10 more)

### Community 48 - "imap_scan_data_source.dart"
Cohesion: 0.12
Nodes (15): dart:io, bodyText, fetchRecentEmails, _imapDate, ImapScanDataSource, _maxBodyLength, _maxMessages, _monthAbbreviations (+7 more)

### Community 49 - "mailbox_settings_page.dart"
Cohesion: 0.12
Nodes (16): ../../application/mailbox_bloc.dart, ../../application/mailbox_event.dart, ../../application/mailbox_state.dart, ../../domain/entities/parcel_candidate.dart, build, createState, dispose, _fillGmail (+8 more)

### Community 50 - "tracking_number_extractor.dart"
Cohesion: 0.15
Nodes (12): carrier, _CarrierPattern, extract, keywords, matchedKeyword, numberPattern, _patterns, props (+4 more)

### Community 51 - "SpotifyBloc"
Cohesion: 0.26
Nodes (18): SpotifyBloc, clientId, command, delta, props, redirectUri, SpotifyConfigSaveRequested, SpotifyEvent (+10 more)

### Community 53 - "ha_entity_state_dto.dart"
Cohesion: 0.09
Nodes (22): bool get, double? get, attributes, _deriveIsOn, _deviceClass, domain, entityId, fromJson (+14 more)

### Community 54 - "home_page.dart"
Cohesion: 0.15
Nodes (13): ../../../../core/widgets/horizontal_page_scaffold.dart, build, HomePage, build, HomeOverview, markets_card.dart, ../../../parcel_tracking/presentation/widgets/parcel_tracking_card.dart, ../../../quick_access/presentation/widgets/quick_access_card.dart (+5 more)

### Community 57 - "parcel.dart"
Cohesion: 0.17
Nodes (11): addedAt, carrier, copyWith, status, description, estimatedDelivery, id, lastUpdate (+3 more)

### Community 58 - "ha_device_overlay_local_data_source.dart"
Cohesion: 0.11
Nodes (18): double?, _cache, clearView, _decode, HaDeviceOverlay, HaDeviceOverlayLocalDataSource, hasRoomOverride, incrementSwitchCount (+10 more)

### Community 59 - "energy_dashboard_controller.dart"
Cohesion: 0.06
Nodes (34): ../domain/entities/energy_dashboard_data.dart, EnergyDashboardData?, EnergyDashboardData get, EnergyRepository, build, _cachedData, child, _computeData (+26 more)

### Community 60 - "app_navigation_event.dart"
Cohesion: 0.24
Nodes (11): app_navigation_event.dart, app_navigation_state.dart, app_section.dart, Bloc, AppNavigationBloc, AppNavigationEvent, AppNavigationSectionSelected, AppNavigationSwiped (+3 more)

### Community 62 - "ha_rest_client.dart"
Cohesion: 0.14
Nodes (13): callService, _checkStatus, decoded, _decodeStates, fetchStates, _get, HaRestClient, _headers (+5 more)

### Community 64 - "markets_card.dart"
Cohesion: 0.15
Nodes (12): ../../application/home_controller.dart, ../../domain/home_models.dart, home_card.dart, build, _formatValue, grouped, _marketColor, _MarketRow (+4 more)

### Community 66 - "energy_dashboard_data.dart"
Cohesion: 0.25
Nodes (7): device_usage.dart, energy_point.dart, deviceUsages, EnergyDashboardData, hourly, month, week

### Community 67 - "smart_home_repository.dart"
Cohesion: 0.15
Nodes (12): ../entities/cover_action.dart, ../entities/smart_home_device.dart, assignDeviceToRoom, controlCover, fetchDevices, placeDevice, removeFromView, SmartHomeRepository (+4 more)

### Community 68 - "String?"
Cohesion: 0.07
Nodes (26): ../../application/energy_dashboard_controller.dart, build, createState, didChangeDependencies, dispose, EnergyPriceSettingsPage, _EnergyPriceSettingsPageState, _error (+18 more)

### Community 77 - "SmartHomeBloc"
Cohesion: 0.20
Nodes (14): QuickAccessCoverTile, QuickAccessToggleTile, PlacementBanner, build, RoomDeviceList, DeviceInfoDialog, _DeviceInfoDialogState, _removeDevice (+6 more)

### Community 78 - "mailbox_bloc_test.dart"
Cohesion: 0.06
Nodes (33): MailboxBloc, MailboxInitial, MailboxReady, package:smart_home/features/parcel_tracking/application/mailbox_bloc.dart, package:smart_home/features/parcel_tracking/application/mailbox_event.dart, package:smart_home/features/parcel_tracking/application/mailbox_state.dart, package:smart_home/features/parcel_tracking/domain/entities/parcel_candidate.dart, package:smart_home/features/parcel_tracking/domain/repositories/mailbox_repository.dart (+25 more)

### Community 79 - "package:flutter/material.dart"
Cohesion: 0.14
Nodes (12): app.dart, ../../features/energy/presentation/pages/energy_price_settings_page.dart, ../../features/ha_connection/presentation/pages/ha_connection_settings_page.dart, ../../features/parcel_tracking/presentation/pages/mailbox_settings_page.dart, ../../features/parcel_tracking/presentation/pages/parcel_list_page.dart, ../../features/parcel_tracking/presentation/pages/track17_settings_page.dart, ../../features/quick_access/presentation/pages/quick_access_settings_page.dart, ../../features/spotify/presentation/pages/spotify_settings_page.dart (+4 more)

### Community 80 - "StatelessWidget"
Cohesion: 0.17
Nodes (14): ../../../../core/widgets/glass_card.dart, AppNavigationBar, _NavItem, _RoomsDropdownItem, _RoomsDropdownPanel, _AddDeviceButton, build, ComparisonCard (+6 more)

### Community 81 - "spotify_bloc.dart"
Cohesion: 0.12
Nodes (16): ../../domain/repositories/spotify_repository.dart, close, _onConfigSaveRequested, _onLoginRequested, _onLogoutRequested, _onPlaybackCommandRequested, _onPlayHereRequested, _onPollTicked (+8 more)

### Community 82 - "spotify_bloc_test.dart"
Cohesion: 0.06
Nodes (32): package:smart_home/features/spotify/application/spotify_bloc.dart, package:smart_home/features/spotify/application/spotify_event.dart, package:smart_home/features/spotify/application/spotify_state.dart, package:smart_home/features/spotify/domain/entities/spotify_now_playing.dart, package:smart_home/features/spotify/domain/entities/spotify_playback_command.dart, package:smart_home/features/spotify/domain/failures/spotify_failure.dart, package:smart_home/features/spotify/domain/repositories/spotify_repository.dart, SpotifyAuthCancelledFailure (+24 more)

### Community 83 - "../../../../core/theme/app_theme.dart"
Cohesion: 0.11
Nodes (22): ../../application/quick_access_bloc.dart, ../../application/quick_access_event.dart, ../../application/quick_access_state.dart, ../../../../core/theme/app_theme.dart, createState, dispose, _query, _searchController (+14 more)

### Community 84 - "home_card.dart"
Cohesion: 0.11
Nodes (16): AppScale, build, child, scale, build, child, GlassCard, build (+8 more)

### Community 85 - "parcel_tracking_event.dart"
Cohesion: 0.16
Nodes (17): apiKey, carrier, description, id, message, parcels, ParcelTrackingEvent, ParcelTrackingParcelAdded (+9 more)

### Community 86 - "quick_access_bloc.dart"
Cohesion: 0.08
Nodes (33): ../data_sources/quick_access_local_data_source.dart, ../../domain/quick_access_limits.dart, ../../domain/repositories/quick_access_repository.dart, _onDeviceAdded, _onDeviceRemoved, _onStarted, QuickAccessBloc, _repository (+25 more)

### Community 87 - "ha_websocket_client.dart"
Cohesion: 0.22
Nodes (8): ha_client_exceptions.dart, events, fetchEntityRegistry, HaWebSocketClient, _initialReconnectDelay, _maxReconnectDelay, _toWebSocketUri, package:web_socket_channel/web_socket_channel.dart

### Community 88 - "spotify_now_playing_card.dart"
Cohesion: 0.07
Nodes (32): ../../application/spotify_bloc.dart, ../../application/spotify_event.dart, ../../application/spotify_state.dart, build, _clientIdController, createState, dispose, initState (+24 more)

### Community 89 - "HomeController"
Cohesion: 0.67
Nodes (3): ChangeNotifier, HomeController, HomeScope

### Community 90 - "spotify_repository_impl.dart"
Cohesion: 0.08
Nodes (24): ../data_sources/spotify_auth_data_source.dart, ../data_sources/spotify_local_data_source.dart, ../data_sources/spotify_remote_data_source.dart, ../data_sources/spotify_web_playback_sdk.dart, _accessToken, _accessTokenExpiry, _applyTokens, _authDataSource (+16 more)

### Community 91 - "spotify_auth_data_source.dart"
Cohesion: 0.15
Nodes (12): authenticate, _authorizeHost, _exchangeCodeForTokens, _http, refreshAccessToken, _requestToken, _scope, SpotifyAuthDataSource (+4 more)

### Community 92 - "spotify_repository.dart"
Cohesion: 0.12
Nodes (15): ../entities/spotify_now_playing.dart, ../entities/spotify_playback_command.dart, fetchCurrentlyPlaying, isAuthenticated, loadAuthConfig, login, logout, playOnThisDevice (+7 more)

### Community 93 - "spotify_state.dart"
Cohesion: 0.16
Nodes (16): ../../domain/value_objects/spotify_auth_config.dart, authConfig, commandError, error, nowPlaying, props, SpotifyAuthenticating, SpotifyError (+8 more)

### Community 94 - "Equatable"
Cohesion: 0.10
Nodes (20): Equatable, _WeatherView, Parcel, ExtractedTrackingCandidate, _PinnedDevicesSnapshot, SmartHomeDevice, _AvailableDevices, albumArtUrl (+12 more)

### Community 95 - "spotify_pkce_helper.dart"
Cohesion: 0.22
Nodes (8): dart:math, _charset, generateCodeChallenge, generateCodeVerifier, generateState, _randomString, SpotifyPkceHelper, package:crypto/crypto.dart

### Community 96 - "spotify_remote_data_source.dart"
Cohesion: 0.17
Nodes (11): ../../domain/entities/spotify_playback_command.dart, ../../domain/failures/spotify_failure.dart, _checkCommandResponse, fetchCurrentlyPlaying, _http, sendPlaybackCommand, setVolume, SpotifyRemoteDataSource (+3 more)

### Community 97 - "SpotifyFailure"
Cohesion: 0.36
Nodes (9): message, SpotifyAuthCancelledFailure, SpotifyFailure, SpotifyInvalidConfigFailure, SpotifyNetworkFailure, SpotifyNoActiveDeviceFailure, SpotifyPremiumRequiredFailure, SpotifyUnauthenticatedFailure (+1 more)

### Community 98 - "List"
Cohesion: 0.14
Nodes (13): AppNavigationState, pageIndex, props, section, AppSection, kTopLevelSections, clientId, props (+5 more)

### Community 99 - "track17_parcel_repository.dart"
Cohesion: 0.06
Nodes (30): ../data_sources/parcel_local_data_source.dart, ../data_sources/track17_api_key_local_data_source.dart, ../data_sources/track17_remote_data_source.dart, ../../domain/services/parcel_sorter.dart, _activeController, addParcel, _apiKeyDataSource, _applyStatusResults (+22 more)

### Community 100 - "track17_remote_data_source.dart"
Cohesion: 0.17
Nodes (11): Client, ../../domain/failures/parcel_tracking_failure.dart, _checkResponse, fetchStatuses, _headers, _host, _http, register (+3 more)

### Community 101 - "parcel_add_page.dart"
Cohesion: 0.13
Nodes (14): ../../application/parcel_tracking_bloc.dart, ../../application/parcel_tracking_event.dart, ../../application/parcel_tracking_state.dart, build, _carrier, createState, _descriptionController, dispose (+6 more)

### Community 102 - "parcel_tracking_bloc.dart"
Cohesion: 0.08
Nodes (30): close, _isConfigured, _messageFor, _onApiKeyCleared, _onApiKeySaveRequested, _onParcelAdded, _onParcelRemoved, _onParcelsUpdated (+22 more)

### Community 103 - "package:flutter_test/flutter_test.dart"
Cohesion: 0.15
Nodes (9): package:flutter_test/flutter_test.dart, package:smart_home/features/parcel_tracking/domain/value_objects/mailbox_account.dart, package:smart_home/features/spotify/infrastructure/data_sources/spotify_pkce_helper.dart, package:smart_home/features/spotify/infrastructure/models/spotify_currently_playing_dto.dart, package:smart_home/features/spotify/infrastructure/models/spotify_token_response_dto.dart, main, main, main (+1 more)

### Community 104 - "parcel_candidate.dart"
Cohesion: 0.20
Nodes (9): carrier.dart, carrier, id, ParcelCandidate, props, sourceAccountLabel, sourceEmailSubject, sourceReceivedAt (+1 more)

### Community 105 - "../../domain/entities/smart_home_device.dart"
Cohesion: 0.33
Nodes (5): Color get, ../../domain/entities/smart_home_device.dart, IconData get, color, icon

### Community 106 - "dart:async"
Cohesion: 0.17
Nodes (11): @JS, dart:async, dart:js_interop, Future, JSFunction get, _connect, _connecting, _deviceId (+3 more)

### Community 108 - "mailbox_account.dart"
Cohesion: 0.17
Nodes (11): appPassword, copyWithPassword, host, id, label, MailboxAccount, port, props (+3 more)

### Community 109 - "parcel_tracking_failure.dart"
Cohesion: 0.36
Nodes (9): MailboxAuthFailure, MailboxConnectionFailure, message, ParcelProviderApiKeyMissingFailure, ParcelProviderUnauthorizedFailure, ParcelProviderUnreachableFailure, ParcelRateLimitedFailure, ParcelTrackingFailure (+1 more)

### Community 110 - "mailbox_bloc.dart"
Cohesion: 0.12
Nodes (15): close, _mailboxRepository, _onAccountRemoved, _onAccountSaveRequested, _onCandidateConfirmed, _onCandidateDismissed, _onScanRequested, _onStarted (+7 more)

### Community 111 - "mailbox_repository.dart"
Cohesion: 0.25
Nodes (7): ../entities/parcel_candidate.dart, loadAccounts, MailboxRepository, removeAccount, saveAccount, scanForCandidates, ../value_objects/mailbox_account.dart

### Community 121 - "mailbox_credentials_local_data_source.dart"
Cohesion: 0.15
Nodes (12): _accountsPrefsKey, _lastScanKey, _lastScanPrefsKeyPrefix, MailboxCredentialsLocalDataSource, _passwordKey, readAll, readLastScan, _readMetas (+4 more)

### Community 122 - "parcel_tracking_card.dart"
Cohesion: 0.20
Nodes (9): ../../../home/presentation/widgets/home_card.dart, build, _maxVisible, ParcelTrackingCard, ../pages/parcel_add_page.dart, ../pages/parcel_candidate_confirmation_page.dart, ../pages/parcel_list_page.dart, ../pages/track17_settings_page.dart (+1 more)

### Community 123 - "parcel_tracking_bloc_test.dart"
Cohesion: 0.07
Nodes (28): package:smart_home/features/parcel_tracking/application/parcel_tracking_bloc.dart, package:smart_home/features/parcel_tracking/application/parcel_tracking_event.dart, package:smart_home/features/parcel_tracking/application/parcel_tracking_state.dart, package:smart_home/features/parcel_tracking/domain/failures/parcel_tracking_failure.dart, package:smart_home/features/parcel_tracking/domain/repositories/parcel_repository.dart, ParcelTrackingInitial, addParcel, addParcelError (+20 more)

### Community 124 - "parcel_record_dto.dart"
Cohesion: 0.13
Nodes (14): ../../domain/entities/parcel.dart, addedAt, carrier, description, estimatedDelivery, fromDomain, fromJson, id (+6 more)

### Community 125 - "static const"
Cohesion: 0.18
Nodes (10): dart:convert, ParcelLocalDataSource, _prefsKey, readAll, writeAll, _prefsKey, readIds, writeIds (+2 more)

### Community 126 - "parcel_tracking_state.dart"
Cohesion: 0.23
Nodes (11): copyWith, isConfigured, isRefreshing, message, parcels, ParcelTrackingError, ParcelTrackingInitial, ParcelTrackingLoading (+3 more)

### Community 127 - "parcel_repository.dart"
Cohesion: 0.11
Nodes (16): ../entities/carrier.dart, ../entities/parcel.dart, ../entities/parcel_status.dart, addParcel, clearApiKey, configureApiKey, fetchParcels, hasApiKeyConfigured (+8 more)

### Community 128 - "../../domain/entities/carrier.dart"
Cohesion: 0.33
Nodes (5): Carrier, ../../domain/entities/carrier.dart, int? get, CarrierTrack17Code, track17Code

### Community 129 - "parcel_list_tile.dart"
Cohesion: 0.22
Nodes (8): build, _estimatedDeliveryLabel, onRemove, parcel, ParcelListTile, _statusColor, Parcel, VoidCallback

### Community 130 - "State"
Cohesion: 0.14
Nodes (19): _CurrentDateLabel, _CurrentDateLabelState, _RoomsNavItem, _RoomsNavItemState, _EnergySection, _EnergySectionState, _LiveClock, _LiveClockState (+11 more)

### Community 131 - "mailbox_state.dart"
Cohesion: 0.21
Nodes (11): ../../domain/value_objects/mailbox_account.dart, accounts, copyWith, isScanning, lastScanError, MailboxInitial, MailboxLoading, MailboxReady (+3 more)

### Community 133 - "imap_mailbox_repository.dart"
Cohesion: 0.11
Nodes (18): ../data_sources/imap_scan_data_source.dart, ../data_sources/mailbox_credentials_local_data_source.dart, ../../domain/repositories/mailbox_repository.dart, ../../domain/repositories/parcel_repository.dart, ../../domain/services/tracking_number_extractor.dart, _credentialsDataSource, _extractor, _imapDataSource (+10 more)

### Community 134 - "AppNavigationBloc"
Cohesion: 0.40
Nodes (5): AppNavigationBloc, _AppShellView, _AppShellViewState, build, initState

### Community 136 - "DateTime"
Cohesion: 0.20
Nodes (9): DateTime?, ../../domain/entities/parcel_status.dart, estimatedDelivery, fromJson, status, subStatus, toParcelStatus, Track17StatusDto (+1 more)

### Community 138 - "room_device_list.dart"
Cohesion: 0.22
Nodes (8): ../../application/smart_home_bloc.dart, ../../application/smart_home_event.dart, device, DeviceListItem, devices, onToggle, roomName, smart_home_device_ui.dart

### Community 139 - "package:smart_home/features/parcel_tracking/domain/entities/carrier.dart"
Cohesion: 0.25
Nodes (6): package:smart_home/features/parcel_tracking/domain/entities/carrier.dart, package:smart_home/features/parcel_tracking/domain/services/tracking_number_extractor.dart, package:smart_home/features/parcel_tracking/infrastructure/models/carrier_track17_code.dart, extractor, main, main

### Community 141 - "parcel_sorter_test.dart"
Cohesion: 0.22
Nodes (7): package:smart_home/features/parcel_tracking/domain/entities/parcel.dart, package:smart_home/features/parcel_tracking/domain/entities/parcel_status.dart, package:smart_home/features/parcel_tracking/domain/services/parcel_sorter.dart, package:smart_home/features/parcel_tracking/infrastructure/models/track17_status_dto.dart, main, _parcel, main

### Community 142 - "spotify_currently_playing_dto.dart"
Cohesion: 0.14
Nodes (13): ../../domain/entities/spotify_now_playing.dart, int?, albumArtUrl, albumName, artistNames, durationMs, fromJson, isPlaying (+5 more)

### Community 143 - "ParcelRepository"
Cohesion: 0.33
Nodes (6): Track17ParcelRepository, ParcelRepository, Parcels, StreamError, _FakeParcelRepositoryForMailbox, _FakeParcelRepository

### Community 144 - "energy_period_selector.dart"
Cohesion: 0.14
Nodes (12): ../../domain/entities/energy_point.dart, EnergyPoint, kwh, label, Period, power, build, EnergyPeriodSelector (+4 more)

### Community 145 - "track17_api_key_local_data_source.dart"
Cohesion: 0.22
Nodes (8): FlutterSecureStorage, _apiKeyKey, clear, read, _secureStorage, Track17ApiKeyLocalDataSource, write, package:flutter_secure_storage/flutter_secure_storage.dart

### Community 146 - "main"
Cohesion: 0.33
Nodes (6): MailboxAccountSaveRequested, MailboxCandidateConfirmed, MailboxCandidateDismissed, MailboxScanRequested, MailboxStarted, main

### Community 149 - "package:flutter_bloc/flutter_bloc.dart"
Cohesion: 0.23
Nodes (11): build, createState, initState, ParcelListPage, _ParcelListPageState, package:flutter_bloc/flutter_bloc.dart, parcel_add_page.dart, ParcelTrackingBloc (+3 more)

### Community 150 - "horizontal_page_scaffold.dart"
Cohesion: 0.40
Nodes (4): build, HorizontalPageScaffold, sections, snap

### Community 156 - "package:shared_preferences/shared_preferences.dart"
Cohesion: 0.33
Nodes (5): package:flutter/services.dart, package:shared_preferences/shared_preferences.dart, package:smart_home/app.dart, main, secureStorageChannel

### Community 157 - "_Track17SettingsPageState"
Cohesion: 0.40
Nodes (5): ParcelTrackingApiKeyCleared, ParcelTrackingApiKeySaveRequested, _save, Track17SettingsPage, _Track17SettingsPageState

### Community 158 - "String get"
Cohesion: 0.28
Nodes (7): Carrier, CarrierLabel, label, label, ParcelStatus, ParcelStatusLabel, String get

### Community 161 - "SmartHomeDeviceType"
Cohesion: 0.67
Nodes (3): SmartHomeDeviceType, SmartHomeDeviceTypeLabel, SmartHomeDeviceUi

## Knowledge Gaps
- **1050 isolated node(s):** `_RegistryInfo`, `diagnosticEntityIds`, `siblingsByEntityId`, `_supportedDomains`, `_config` (+1045 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **41 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `_DeviceInfoDialogState` connect `SmartHomeBloc` to `room_dialogs.dart`, `State`?**
  _High betweenness centrality (0.011) - this node is a cross-community bridge._
- **What connects `_RegistryInfo`, `diagnosticEntityIds`, `siblingsByEntityId` to the rest of the system?**
  _1050 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `ha_websocket_client_test.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.1 - nodes in this community are weakly interconnected._
- **Should `home_controller.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.06896551724137931 - nodes in this community are weakly interconnected._
- **Should `home_models.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.058823529411764705 - nodes in this community are weakly interconnected._
- **Should `energy_local_data_source.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.14285714285714285 - nodes in this community are weakly interconnected._
- **Should `app_shell.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.06666666666666667 - nodes in this community are weakly interconnected._