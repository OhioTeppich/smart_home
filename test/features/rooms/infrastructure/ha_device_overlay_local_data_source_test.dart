import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_home/features/rooms/infrastructure/data_sources/ha_device_overlay_local_data_source.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('readAll() is empty when nothing was ever written', () async {
    final source = HaDeviceOverlayLocalDataSource();

    expect(await source.readAll(), isEmpty);
  });

  test('setPlacement() persists room + coordinates for that entity only', () async {
    final source = HaDeviceOverlayLocalDataSource();

    await source.setPlacement('light.a', 'livingRoom', .3, .4);

    final overlays = await source.readAll();
    expect(overlays.keys, ['light.a']);
    final overlay = overlays['light.a']!;
    expect(overlay.roomId, 'livingRoom');
    expect(overlay.hasRoomOverride, isTrue);
    expect(overlay.x, .3);
    expect(overlay.y, .4);
  });

  test('setRoomOverride() reassigns the room, clears placement, keeps switchCount', () async {
    final source = HaDeviceOverlayLocalDataSource();
    await source.setPlacement('light.a', 'livingRoom', .3, .4);
    await source.incrementSwitchCount('light.a');

    await source.setRoomOverride('light.a', 'bedroom');

    final overlay = (await source.readAll())['light.a']!;
    expect(overlay.roomId, 'bedroom');
    expect(overlay.switchCount, 1);
    expect(overlay.x, isNull);
    expect(overlay.y, isNull);
  });

  test('clearView() marks the entity unassigned with an explicit override', () async {
    final source = HaDeviceOverlayLocalDataSource();
    await source.setPlacement('light.a', 'livingRoom', .3, .4);

    await source.clearView('light.a');

    final overlay = (await source.readAll())['light.a']!;
    expect(overlay.hasRoomOverride, isTrue);
    expect(overlay.roomId, isNull);
    expect(overlay.x, isNull);
    expect(overlay.y, isNull);
  });

  test('incrementSwitchCount() accumulates across calls', () async {
    final source = HaDeviceOverlayLocalDataSource();

    await source.incrementSwitchCount('light.a');
    await source.incrementSwitchCount('light.a');
    await source.incrementSwitchCount('light.a');

    expect((await source.readAll())['light.a']!.switchCount, 3);
  });

  test('overlays for different entities do not interfere', () async {
    final source = HaDeviceOverlayLocalDataSource();

    await source.setPlacement('light.a', 'livingRoom', .1, .1);
    await source.setRoomOverride('light.b', 'kitchen');

    final overlays = await source.readAll();
    expect(overlays['light.a']!.roomId, 'livingRoom');
    expect(overlays['light.a']!.x, .1);
    expect(overlays['light.b']!.roomId, 'kitchen');
    expect(overlays['light.b']!.x, isNull);
  });

  test('data survives across data source instances (persisted, not in-memory)', () async {
    await HaDeviceOverlayLocalDataSource().setRoomOverride('light.a', 'bedroom');

    final overlay = (await HaDeviceOverlayLocalDataSource().readAll())['light.a']!;
    expect(overlay.roomId, 'bedroom');
  });
}
