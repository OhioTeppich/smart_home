import 'package:smart_home/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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

    expect(find.text('Verbrauch nach Tageszeit'), findsOneWidget);
  });

  testWidgets('can open the living room and start adding a device', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const SmartHomeApp());

    await tester.tap(find.byIcon(Icons.other_houses_rounded).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Wohnzimmer').first);
    await tester.pumpAndSettle();

    expect(find.text('Wohnzimmer'), findsAtLeastNWidgets(1));
    expect(
      find.text('Füge ein Gerät hinzu, um es hier zu platzieren'),
      findsOneWidget,
    );

    await tester.tap(find.byIcon(Icons.add_rounded).first);
    await tester.pumpAndSettle();

    expect(find.text('SmartHome-Gerät hinzufügen'), findsOneWidget);
    expect(find.text('Weiter zur Platzierung'), findsOneWidget);
  });
}
