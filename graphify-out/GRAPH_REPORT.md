# Graph Report - .  (2026-07-30)

## Corpus Check
- 84 files · ~82,553 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 543 nodes · 697 edges · 37 communities (28 shown, 9 thin omitted)
- Extraction: 98% EXTRACTED · 2% INFERRED · 0% AMBIGUOUS · INFERRED: 15 edges (avg confidence: 0.82)
- Token cost: 116,839 input · 0 output

## Community Hubs (Navigation)
- Energy Dashboard State/Controller
- Home Dashboard Controller & Market Data
- Energy Domain Entities
- Room Device Placement Controller
- Feature Module Wiring (Energy/Home/Rooms)
- Energy Analysis Chart Widgets
- Home Page & Glass Card UI
- Market/Device Ranking Widgets
- App Shell & Room Dialogs
- DDD Architecture Concepts
- Energy Metric Widgets
- Smart Home Device Entity
- App Theme & Colors
- iOS Flutter App Delegate
- Energy Summary & Nav Widgets
- Room Page UI
- Room Map Widget
- Web App Manifest Fields
- Room Device List UI
- Energy Period Selector
- Composition Root & App Shell
- BLoC Pattern Usage
- Living Room Photo Asset
- Project Docs & DDD Reference
- Android Main Activity
- Flutter Verification Commands
- Git Auto-Commit Workflow
- Default Flutter App Icon
- iOS Launch Screen Assets
- lib/ Source Directory
- Naming/UI Text Rules
- test/ Directory
- Web Manifest File

## God Nodes (most connected - your core abstractions)
1. `smart_home package` - 9 edges
2. `SmartHomeController` - 7 edges
3. `SmartHomeDevice` - 7 edges
4. `Infrastructure layer` - 7 edges
5. `Period` - 6 edges
6. `Application layer` - 6 edges
7. `SmartHomeDeviceType` - 5 edges
8. `Domain-Driven Design principles` - 4 edges
9. `Presentation layer` - 4 edges
10. `Layered test directory structure` - 4 edges

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

## Communities (37 total, 9 thin omitted)

### Community 0 - "Energy Dashboard State/Controller"
Cohesion: 0.05
Nodes (39): ../../application/controllers/smart_home_controller.dart, ChangeNotifier, ../../domain/entities/device_usage.dart, ../../domain/entities/energy_dashboard_data.dart, ../../domain/repositories/energy_repository.dart, EnergyDashboardData get, ../entities/energy_dashboard_data.dart, InheritedNotifier (+31 more)

### Community 1 - "Home Dashboard Controller & Market Data"
Cohesion: 0.05
Nodes (42): dart:async, dart:convert, ../infrastructure/home_data_service.dart, context, dispose, loadingWeather, _market, marketQuotes (+34 more)

### Community 2 - "Energy Domain Entities"
Cohesion: 0.05
Nodes (37): DateTime, device_usage.dart, energy_point.dart, deviceUsages, EnergyDashboardData, hourly, month, week (+29 more)

### Community 3 - "Room Device Placement Controller"
Cohesion: 0.06
Nodes (33): bool get, Color get, ../../domain/entities/smart_home_device.dart, ../../domain/repositories/smart_home_repository.dart, ../entities/smart_home_device.dart, IconData get, cancelPlacement, devices (+25 more)

### Community 4 - "Feature Module Wiring (Energy/Home/Rooms)"
Cohesion: 0.06
Nodes (34): app/shell/app_shell.dart, ../../features/energy/application/energy_dashboard_controller.dart, ../../features/energy/domain/entities/energy_point.dart, features/energy/infrastructure/repositories/in_memory_energy_repository.dart, ../../features/energy/presentation/pages/energy_analysis_page.dart, ../../features/energy/presentation/pages/energy_overview_page.dart, ../../features/energy/presentation/widgets/energy_period_selector.dart, features/home/application/home_controller.dart (+26 more)

### Community 5 - "Energy Analysis Chart Widgets"
Cohesion: 0.07
Nodes (32): ../../application/energy_dashboard_controller.dart, ../../../../core/widgets/glass_card.dart, CustomPainter, dart:math, ../../domain/entities/energy_point.dart, EnergyPoint, kwh, label (+24 more)

### Community 6 - "Home Page & Glass Card UI"
Cohesion: 0.06
Nodes (27): app.dart, build, child, GlassCard, build, HomePage, build, child (+19 more)

### Community 7 - "Market/Device Ranking Widgets"
Cohesion: 0.07
Nodes (29): ../../application/home_controller.dart, ../../domain/home_models.dart, home_card.dart, DeviceRanking, MarketQuote, build, _formatValue, grouped (+21 more)

### Community 8 - "App Shell & Room Dialogs"
Cohesion: 0.08
Nodes (31): AppShell, _AppShellState, WeatherCard, _WeatherCardState, AddDeviceDialog, _AddDeviceDialogState, build, controller (+23 more)

### Community 9 - "DDD Architecture Concepts"
Cohesion: 0.08
Nodes (31): Smart Home (product), flutter_lints lint rule set (package:flutter_lints/flutter.yaml), AddRoomDevice use case, Application layer, DataSource (technical communication with API/Home Assistant/storage), Domain-Driven Design principles, Domain layer, EnergyChartCard widget (+23 more)

### Community 10 - "Energy Metric Widgets"
Cohesion: 0.09
Nodes (21): Color, IconData, color, DeviceUsage, icon, kwh, name, share (+13 more)

### Community 11 - "Smart Home Device Entity"
Cohesion: 0.10
Nodes (21): double?, _HomeDeviceStyle, canToggle, dailyKwh, id, isOn, label, lastUpdated (+13 more)

### Community 12 - "App Theme & Colors"
Cohesion: 0.10
Nodes (20): dart:ui, AppColors, AppTheme, blue, blueDark, brown, canvas, dragDevices (+12 more)

### Community 13 - "iOS Flutter App Delegate"
Cohesion: 0.15
Nodes (10): Any, Bool, Flutter, FlutterAppDelegate, AppDelegate, RunnerTests, UIApplication, UIKit (+2 more)

### Community 14 - "Energy Summary & Nav Widgets"
Cohesion: 0.19
Nodes (13): _AddDeviceButton, AppNavigationBar, _NavItem, build, ComparisonCard, ForecastCard, GoalCard, PeakCard (+5 more)

### Community 15 - "Room Page UI"
Cohesion: 0.18
Nodes (10): SmartHomeDevice, build, device, imageAsset, PlacementBanner, roomId, roomName, RoomPage (+2 more)

### Community 16 - "Room Map Widget"
Cohesion: 0.18
Nodes (10): build, controller, createState, device, EmptyMapHint, hovering, imageAsset, roomId (+2 more)

### Community 17 - "Web App Manifest Fields"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 18 - "Room Device List UI"
Cohesion: 0.20
Nodes (9): build, controller, device, DeviceListItem, onToggle, RoomDeviceList, roomId, roomName (+1 more)

### Community 19 - "Energy Period Selector"
Cohesion: 0.25
Nodes (7): ../../../../core/theme/app_theme.dart, build, EnergyPeriodSelector, _label, onChanged, value, ValueChanged

### Community 20 - "Composition Root & App Shell"
Cohesion: 0.50
Nodes (4): Composition Root (app.dart), Global App Shell (app/shell), AppNavigationBar widget, Composition Root (app/)

### Community 21 - "BLoC Pattern Usage"
Cohesion: 0.50
Nodes (4): AppNavigationBloc, BLoC pattern (flutter_bloc), Energy feature BLoC, Rooms feature BLoC

### Community 22 - "Living Room Photo Asset"
Cohesion: 0.50
Nodes (4): Warm Ambient Lighting (Floor Lamp and Sunlight Streaks), Living Room Photo (Top-Down Interior), Living Room (Room Type), Sofa, Armchair and Ottoman Seating Arrangement

### Community 23 - "Project Docs & DDD Reference"
Cohesion: 0.67
Nodes (3): AGENTS.md Agent Guidelines, Smart Home Architekturstandard, Reso-Coder Flutter/Firebase DDD Course Article

## Knowledge Gaps
- **291 isolated node(s):** `XCTest`, `build`, `AppSection`, `section`, `compact` (+286 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **9 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `SmartHomeDevice` connect `Room Page UI` to `Room Device Placement Controller`, `Feature Module Wiring (Energy/Home/Rooms)`, `App Shell & Room Dialogs`, `Smart Home Device Entity`, `Room Map Widget`, `Room Device List UI`?**
  _High betweenness centrality (0.057) - this node is a cross-community bridge._
- **Why does `MarketQuote` connect `Market/Device Ranking Widgets` to `Home Dashboard Controller & Market Data`, `Energy Domain Entities`?**
  _High betweenness centrality (0.028) - this node is a cross-community bridge._
- **Why does `Period` connect `Energy Analysis Chart Widgets` to `Energy Dashboard State/Controller`, `Energy Period Selector`?**
  _High betweenness centrality (0.025) - this node is a cross-community bridge._
- **What connects `XCTest`, `build`, `AppSection` to the rest of the system?**
  _291 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Energy Dashboard State/Controller` be split into smaller, more focused modules?**
  _Cohesion score 0.05496828752642706 - nodes in this community are weakly interconnected._
- **Should `Home Dashboard Controller & Market Data` be split into smaller, more focused modules?**
  _Cohesion score 0.048625792811839326 - nodes in this community are weakly interconnected._
- **Should `Energy Domain Entities` be split into smaller, more focused modules?**
  _Cohesion score 0.05263157894736842 - nodes in this community are weakly interconnected._