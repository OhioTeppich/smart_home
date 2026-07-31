# Graph Report - smart_home  (2026-07-31)

## Corpus Check
- 86 files · ~92,342 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 812 nodes · 1090 edges · 60 communities (46 shown, 14 thin omitted)
- Extraction: 99% EXTRACTED · 1% INFERRED · 0% AMBIGUOUS · INFERRED: 15 edges (avg confidence: 0.82)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `cfa079c1`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- energy_dashboard_controller.dart
- home_controller.dart
- home_models.dart
- smart_home_repository.dart
- app_shell.dart
- energy_chart_widgets.dart
- home_card.dart
- top_devices_card.dart
- room_dialogs.dart
- smart_home package
- energy_metric_widgets.dart
- smart_home_device.dart
- app_theme.dart
- .application
- app_navigation.dart
- app_navigation_state.dart
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
- room_page.dart
- ../../features/rooms/domain/entities/smart_home_device.dart
- package:flutter/foundation.dart
- SmartHomeDevice? get
- home_data_service.dart
- StatelessWidget
- room_device_list.dart
- app.dart
- State
- ../../../../core/theme/app_theme.dart
- package:flutter/material.dart
- room_layout.dart
- widget_test.dart
- home_overview.dart
- horizontal_page_scaffold.dart
- SmartHomeRepository
- _FakeHaConnectionRepository
- AppNavigationBloc
- ../../../rooms/presentation/state/smart_home_scope.dart
- SmartHomeBloc
- _DeviceInfoDialogState

## God Nodes (most connected - your core abstractions)
1. `SmartHomeBloc` - 19 edges
2. `SmartHomeEvent` - 13 edges
3. `AppNavigationBloc` - 10 edges
4. `smart_home package` - 9 edges
5. `_DeviceInfoDialogState` - 8 edges
6. `main` - 8 edges
7. `Infrastructure layer` - 7 edges
8. `Application layer` - 6 edges
9. `_AddDeviceDialogState` - 5 edges
10. `SmartHomeStarted` - 5 edges

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

## Communities (60 total, 14 thin omitted)

### Community 0 - "energy_dashboard_controller.dart"
Cohesion: 0.08
Nodes (26): ../../domain/entities/device_usage.dart, ../../domain/entities/energy_dashboard_data.dart, ../../domain/entities/energy_point.dart, ../../domain/repositories/energy_repository.dart, EnergyDashboardData get, ../entities/energy_dashboard_data.dart, data, of (+18 more)

### Community 1 - "home_controller.dart"
Cohesion: 0.06
Nodes (34): ChangeNotifier, ../infrastructure/home_data_service.dart, InheritedNotifier, EnergyDashboardController, EnergyScope, context, DeviceRanking, dispose (+26 more)

### Community 2 - "home_models.dart"
Cohesion: 0.06
Nodes (34): DateTime, change, changePercent, condition, currency, feelsLike, hourly, HourlyWeatherPoint (+26 more)

### Community 3 - "smart_home_repository.dart"
Cohesion: 0.20
Nodes (9): ../entities/cover_action.dart, ../entities/smart_home_device.dart, assignDeviceToRoom, controlCover, fetchDevices, placeDevice, removeFromView, toggleDevice (+1 more)

### Community 4 - "app_shell.dart"
Cohesion: 0.06
Nodes (34): app_navigation_bloc.dart, app_navigation.dart, ../../features/energy/domain/entities/energy_point.dart, ../../features/energy/presentation/pages/energy_analysis_page.dart, ../../features/energy/presentation/pages/energy_overview_page.dart, ../../features/energy/presentation/widgets/energy_period_selector.dart, ../../features/ha_connection/presentation/pages/ha_connection_settings_page.dart, ../../features/home/presentation/pages/home_page.dart (+26 more)

### Community 5 - "energy_chart_widgets.dart"
Cohesion: 0.06
Nodes (35): ../../application/energy_dashboard_controller.dart, ../../../../core/widgets/glass_card.dart, ../../../../core/widgets/horizontal_page_scaffold.dart, CustomPainter, dart:math, AnalysisPage, build, onBack (+27 more)

### Community 6 - "home_card.dart"
Cohesion: 0.25
Nodes (7): build, child, HomeCard, HomeCardTitle, icon, title, trailing

### Community 7 - "top_devices_card.dart"
Cohesion: 0.05
Nodes (39): ../../application/home_controller.dart, Color get, DeviceRanking, ../../domain/entities/smart_home_device.dart, ../../domain/home_models.dart, home_card.dart, IconData get, build (+31 more)

### Community 8 - "room_dialogs.dart"
Cohesion: 0.11
Nodes (17): CoverControlRow, createState, device, dispose, hovering, InfoRow, isOn, label (+9 more)

### Community 9 - "smart_home package"
Cohesion: 0.08
Nodes (31): Smart Home (product), flutter_lints lint rule set (package:flutter_lints/flutter.yaml), AddRoomDevice use case, Application layer, DataSource (technical communication with API/Home Assistant/storage), Domain-Driven Design principles, Domain layer, EnergyChartCard widget (+23 more)

### Community 10 - "energy_metric_widgets.dart"
Cohesion: 0.09
Nodes (22): Color, double?, IconData, color, DeviceUsage, icon, kwh, name (+14 more)

### Community 11 - "smart_home_device.dart"
Cohesion: 0.05
Nodes (40): bool get, assignToRoom, canToggle, copyWith, coverPosition, coverRawState, dailyKwh, id (+32 more)

### Community 12 - "app_theme.dart"
Cohesion: 0.10
Nodes (20): dart:ui, AppColors, AppTheme, blue, blueDark, brown, canvas, dragDevices (+12 more)

### Community 13 - ".application"
Cohesion: 0.15
Nodes (10): Any, Bool, Flutter, FlutterAppDelegate, AppDelegate, RunnerTests, UIApplication, UIKit (+2 more)

### Community 14 - "app_navigation.dart"
Cohesion: 0.10
Nodes (20): build, compact, createState, current, icon, _isRoomSection, label, _link (+12 more)

### Community 15 - "app_navigation_state.dart"
Cohesion: 0.12
Nodes (15): device_usage.dart, energy_point.dart, int get, pageIndex, props, section, AppSection, kTopLevelSections (+7 more)

### Community 16 - "room_map.dart"
Cohesion: 0.14
Nodes (13): build, controller, createState, device, EmptyMapHint, HoverInfo, hovering, imageAsset (+5 more)

### Community 17 - "manifest.json"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 18 - "home_assistant_smart_home_repository.dart"
Cohesion: 0.06
Nodes (33): ../../../../core/home_assistant/ha_client_exceptions.dart, ../../../../core/home_assistant/ha_rest_client.dart, ../../../../core/home_assistant/ha_websocket_client.dart, ../data_sources/ha_area_alias_mapper.dart, ../data_sources/ha_device_overlay_local_data_source.dart, ../../../ha_connection/domain/value_objects/ha_connection_config.dart, HaAreaAliasMapper, HaDeviceOverlayLocalDataSource (+25 more)

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
Nodes (46): ../../domain/entities/cover_action.dart, ../../domain/failures/smart_home_failure.dart, ../../domain/repositories/smart_home_repository.dart, close, _devicesSubscription, _messageFor, _onCoverActionRequested, _onDeviceAssignedToRoom (+38 more)

### Community 39 - "room_page.dart"
Cohesion: 0.11
Nodes (19): ../../application/smart_home_bloc.dart, ../../application/smart_home_event.dart, ../../../ha_connection/application/ha_connection_bloc.dart, ../../../ha_connection/application/ha_connection_state.dart, ../../../ha_connection/presentation/pages/ha_connection_settings_page.dart, HaConnectionBloc, build, device (+11 more)

### Community 43 - "home_data_service.dart"
Cohesion: 0.07
Nodes (28): dart:async, dart:convert, ha_client_exceptions.dart, events, fetchEntityRegistry, HaWebSocketClient, _toWebSocketUri, MarketQuote (+20 more)

### Community 44 - "StatelessWidget"
Cohesion: 0.17
Nodes (14): AppNavigationBar, _NavItem, _RoomsDropdownItem, _RoomsDropdownPanel, _AddDeviceButton, AppShell, build, ComparisonCard (+6 more)

### Community 45 - "room_device_list.dart"
Cohesion: 0.17
Nodes (11): ../../application/controllers/smart_home_controller.dart, SmartHomeDevice, build, controller, device, DeviceListItem, onToggle, RoomDeviceList (+3 more)

### Community 46 - "app.dart"
Cohesion: 0.18
Nodes (10): app/app_scale.dart, app/shell/app_shell.dart, ../../features/energy/application/energy_dashboard_controller.dart, features/energy/infrastructure/repositories/in_memory_energy_repository.dart, features/home/application/home_controller.dart, features/rooms/application/controllers/smart_home_controller.dart, features/rooms/infrastructure/repositories/in_memory_smart_home_repository.dart, ../../features/rooms/presentation/state/smart_home_scope.dart (+2 more)

### Community 47 - "State"
Cohesion: 0.28
Nodes (9): _RoomsNavItem, _RoomsNavItemState, DeviceInfoDialog, PowerToggleRow, _PowerToggleRowState, DeviceMarker, _DeviceMarkerState, State (+1 more)

### Community 48 - "../../../../core/theme/app_theme.dart"
Cohesion: 0.25
Nodes (7): ../../../../core/theme/app_theme.dart, build, EnergyPeriodSelector, _label, onChanged, value, ValueChanged

### Community 49 - "package:flutter/material.dart"
Cohesion: 0.14
Nodes (12): app.dart, AppScale, build, child, scale, build, child, GlassCard (+4 more)

### Community 50 - "room_layout.dart"
Cohesion: 0.17
Nodes (11): ../../application/smart_home_state.dart, build, imageAsset, roomId, RoomLayout, roomName, state, room_device_list.dart (+3 more)

### Community 53 - "widget_test.dart"
Cohesion: 0.29
Nodes (6): package:flutter/services.dart, package:flutter_test/flutter_test.dart, package:shared_preferences/shared_preferences.dart, package:smart_home/app.dart, main, secureStorageChannel

### Community 54 - "home_overview.dart"
Cohesion: 0.33
Nodes (5): build, HomeOverview, markets_card.dart, top_devices_card.dart, weather_card.dart

### Community 55 - "horizontal_page_scaffold.dart"
Cohesion: 0.40
Nodes (4): build, HorizontalPageScaffold, sections, snap

### Community 56 - "SmartHomeRepository"
Cohesion: 0.50
Nodes (4): SmartHomeRepository, HomeAssistantSmartHomeRepository, _FakeSmartHomeRepository, _FakeSmartHomeRepository

### Community 58 - "AppNavigationBloc"
Cohesion: 0.16
Nodes (16): app_navigation_event.dart, app_navigation_state.dart, app_section.dart, Bloc, Equatable, AppNavigationBloc, AppNavigationEvent, AppNavigationSectionSelected (+8 more)

### Community 62 - "SmartHomeBloc"
Cohesion: 0.25
Nodes (9): build, TopDevicesCard, PlacementBanner, AddDeviceDialog, _AddDeviceDialogState, build, SmartHomeBloc, SmartHomePlacementCancelled (+1 more)

### Community 63 - "_DeviceInfoDialogState"
Cohesion: 0.33
Nodes (6): _DeviceInfoDialogState, _removeDevice, SmartHomeCoverActionRequested, SmartHomeDeviceAssignedToRoom, SmartHomeDeviceRemovedFromView, SmartHomeDeviceToggled

## Knowledge Gaps
- **430 isolated node(s):** `state`, `roomId`, `roomName`, `imageAsset`, `build` (+425 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **14 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `SmartHomeBloc` connect `smart_home_bloc.dart` to `AppNavigationBloc`, `smart_home_bloc_test.dart`, `room_layout.dart`, `room_page_test.dart`?**
  _High betweenness centrality (0.025) - this node is a cross-community bridge._
- **Why does `SmartHomeRepository` connect `SmartHomeRepository` to `smart_home_repository.dart`, `smart_home_bloc.dart`?**
  _High betweenness centrality (0.023) - this node is a cross-community bridge._
- **Why does `Period` connect `energy_dashboard_controller.dart` to `../../../../core/theme/app_theme.dart`?**
  _High betweenness centrality (0.012) - this node is a cross-community bridge._
- **What connects `state`, `roomId`, `roomName` to the rest of the system?**
  _430 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `energy_dashboard_controller.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.07816091954022988 - nodes in this community are weakly interconnected._
- **Should `home_controller.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.06050420168067227 - nodes in this community are weakly interconnected._
- **Should `home_models.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.058823529411764705 - nodes in this community are weakly interconnected._