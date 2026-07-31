import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_home/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const secureStorageChannel = MethodChannel(
    'plugins.it_nomads.com/flutter_secure_storage',
  );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, (call) async => null);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, null);
  });

  testWidgets('shows Home and can open the energy overview', (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const SmartHomeApp());

    expect(find.text('Wetter heute'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.bolt_rounded).first);
    await tester.pumpAndSettle();
    expect(find.text('Verbrauch heute'), findsOneWidget);
    expect(find.text('6,14'), findsOneWidget);
  });

  testWidgets('can navigate to analysis', (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const SmartHomeApp());

    await tester.tap(find.byIcon(Icons.bolt_rounded).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Details  →'));
    await tester.pumpAndSettle();

    expect(find.text('Übersicht'), findsOneWidget);

    // Analysis now spreads its sections across horizontally swipeable
    // panels; "Verbrauch nach Tageszeit" lives on the second panel.
    await tester.drag(find.byType(PageView).last, const Offset(-800, 0));
    await tester.pumpAndSettle();

    expect(find.text('Verbrauch nach Tageszeit'), findsOneWidget);
  });

  testWidgets(
    'shows an explicit not-connected state in a room and offers a device picker',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(const SmartHomeApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.other_houses_rounded).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Wohnzimmer').first);
      await tester.pumpAndSettle();

      // No Home Assistant connection configured: an explicit "not
      // connected" state, never a mock/fake device list.
      expect(find.text('Keine Home Assistant-Verbindung'), findsOneWidget);
      expect(find.text('Zu den Einstellungen'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.add_rounded).first);
      await tester.pumpAndSettle();

      expect(find.text('Gerät hinzufügen'), findsOneWidget);
      expect(
        find.textContaining('Keine unplatzierten Geräte'),
        findsOneWidget,
      );
    },
  );
}
