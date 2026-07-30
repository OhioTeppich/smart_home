import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_home/features/ha_connection/application/ha_connection_bloc.dart';
import 'package:smart_home/features/ha_connection/application/ha_connection_event.dart';
import 'package:smart_home/features/ha_connection/domain/repositories/ha_connection_repository.dart';
import 'package:smart_home/features/ha_connection/domain/value_objects/ha_connection_config.dart';
import 'package:smart_home/features/rooms/application/smart_home_bloc.dart';
import 'package:smart_home/features/rooms/application/smart_home_event.dart';
import 'package:smart_home/features/rooms/domain/entities/smart_home_device.dart';
import 'package:smart_home/features/rooms/domain/failures/smart_home_failure.dart';
import 'package:smart_home/features/rooms/domain/repositories/smart_home_repository.dart';
import 'package:smart_home/features/rooms/presentation/pages/room_page.dart';

class _FakeHaConnectionRepository implements HaConnectionRepository {
  HaConnectionConfig? config;

  @override
  Future<HaConnectionConfig?> loadConfig() async => config;

  @override
  Future<void> saveConfig(HaConnectionConfig value) async => config = value;

  @override
  Future<void> clearConfig() async => config = null;

  @override
  Future<void> testConnection(HaConnectionConfig value) async {}
}

class _FakeSmartHomeRepository implements SmartHomeRepository {
  final _controller = StreamController<List<SmartHomeDevice>>.broadcast();

  void pushDevices(List<SmartHomeDevice> devices) => _controller.add(devices);
  void pushError(Object error) => _controller.addError(error);

  @override
  Stream<List<SmartHomeDevice>> watchDevices() => _controller.stream;

  @override
  Future<List<SmartHomeDevice>> fetchDevices() async => const [];

  @override
  Future<void> toggleDevice(String id, bool isOn) async {}

  @override
  Future<void> assignDeviceToRoom(String id, String? roomId) async {}

  @override
  Future<void> placeDevice(
    String id,
    String roomId,
    double x,
    double y,
  ) async {}

  @override
  Future<void> removeFromView(String id) async {}
}

const _placedLamp = SmartHomeDevice(
  id: 'light.wohnzimmer_lampe',
  name: 'Wohnzimmer Lampe',
  type: SmartHomeDeviceType.bulb,
  status: 'Online',
  powerWatts: 9,
  dailyKwh: .1,
  lastUpdated: 'gerade eben',
  roomId: 'livingRoom',
  x: .5,
  y: .5,
);

Widget _harness({
  required HaConnectionRepository haConnectionRepository,
  required SmartHomeRepository smartHomeRepository,
}) => MaterialApp(
  // `RoomPage` needs a `Scaffold` ancestor for bounded layout constraints,
  // exactly like it always has in the real app via `AppShell`'s `Scaffold`.
  home: Scaffold(
    body: MultiBlocProvider(
      providers: [
        BlocProvider<HaConnectionBloc>(
          create: (_) => HaConnectionBloc(haConnectionRepository)
            ..add(const HaConnectionStarted()),
        ),
        BlocProvider<SmartHomeBloc>(
          create: (_) => SmartHomeBloc(smartHomeRepository)
            ..add(const SmartHomeStarted()),
        ),
      ],
      child: const RoomPage(),
    ),
  ),
);

void main() {
  void setSurfaceSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  testWidgets(
    'shows an explicit not-connected message without a saved config',
    (tester) async {
      setSurfaceSize(tester);
      await tester.pumpWidget(
        _harness(
          haConnectionRepository: _FakeHaConnectionRepository(),
          smartHomeRepository: _FakeSmartHomeRepository(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Keine Home Assistant-Verbindung'), findsOneWidget);
      expect(find.text('Zu den Einstellungen'), findsOneWidget);
    },
  );

  testWidgets('shows placed room devices once connected', (tester) async {
    setSurfaceSize(tester);
    final smartHomeRepository = _FakeSmartHomeRepository();
    final haConnectionRepository = _FakeHaConnectionRepository()
      ..config = const HaConnectionConfig(
        baseUrl: 'https://ha.local',
        token: 't',
      );

    await tester.pumpWidget(
      _harness(
        haConnectionRepository: haConnectionRepository,
        smartHomeRepository: smartHomeRepository,
      ),
    );
    await tester.pump();
    smartHomeRepository.pushDevices([_placedLamp]);
    await tester.pumpAndSettle();

    expect(find.text('Wohnzimmer Lampe'), findsOneWidget);
  });

  testWidgets('shows the failure message when the device stream errors', (
    tester,
  ) async {
    setSurfaceSize(tester);
    final smartHomeRepository = _FakeSmartHomeRepository();
    final haConnectionRepository = _FakeHaConnectionRepository()
      ..config = const HaConnectionConfig(
        baseUrl: 'https://ha.local',
        token: 't',
      );

    await tester.pumpWidget(
      _harness(
        haConnectionRepository: haConnectionRepository,
        smartHomeRepository: smartHomeRepository,
      ),
    );
    await tester.pump();
    smartHomeRepository.pushError(const SmartHomeConnectionFailure());
    await tester.pumpAndSettle();

    expect(find.text('Verbindung unterbrochen'), findsOneWidget);
    expect(
      find.text(const SmartHomeConnectionFailure().message),
      findsOneWidget,
    );
  });
}
