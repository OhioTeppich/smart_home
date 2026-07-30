import 'package:flutter_test/flutter_test.dart';
import 'package:smart_home/features/rooms/domain/entities/smart_home_device.dart';

SmartHomeDevice _device({
  SmartHomeDeviceType type = SmartHomeDeviceType.bulb,
  String? roomId,
  double? x,
  double? y,
  int switchCount = 0,
  bool isOn = false,
}) => SmartHomeDevice(
  id: 'light.wohnzimmer_lampe',
  name: 'Wohnzimmer Lampe',
  type: type,
  status: 'Online',
  powerWatts: 9,
  dailyKwh: .18,
  lastUpdated: 'vor 2 Min',
  roomId: roomId,
  switchCount: switchCount,
  isOn: isOn,
  x: x,
  y: y,
);

void main() {
  group('canToggle', () {
    test('is true for lamp, bulb, television, plug', () {
      for (final type in [
        SmartHomeDeviceType.lamp,
        SmartHomeDeviceType.bulb,
        SmartHomeDeviceType.television,
        SmartHomeDeviceType.plug,
      ]) {
        expect(_device(type: type).canToggle, isTrue, reason: type.name);
      }
    });

    test('is false for sensor, climate, cover, other', () {
      for (final type in [
        SmartHomeDeviceType.sensor,
        SmartHomeDeviceType.climate,
        SmartHomeDeviceType.cover,
        SmartHomeDeviceType.other,
      ]) {
        expect(_device(type: type).canToggle, isFalse, reason: type.name);
      }
    });
  });

  test('isPlaced is true only when both x and y are set', () {
    expect(_device().isPlaced, isFalse);
    expect(_device(x: .5, y: .5).isPlaced, isTrue);
  });

  test('withPowerState flips isOn, bumps switchCount, refreshes lastUpdated', () {
    final device = _device(isOn: false, switchCount: 2);

    final next = device.withPowerState(true);

    expect(next.isOn, isTrue);
    expect(next.switchCount, 3);
    expect(next.lastUpdated, 'gerade eben');
  });

  test('placeAt clamps coordinates into the map bounds', () {
    final device = _device();

    final placed = device.placeAt(-1, 2);

    expect(placed.x, 0.04);
    expect(placed.y, 0.94);
  });

  test('assignToRoom sets the room and clears any placement', () {
    final device = _device(roomId: 'bedroom', x: .3, y: .4);

    final reassigned = device.assignToRoom('kitchen');

    expect(reassigned.roomId, 'kitchen');
    expect(reassigned.isPlaced, isFalse);
  });

  test('assignToRoom(null) unassigns and clears placement', () {
    final device = _device(roomId: 'bedroom', x: .3, y: .4);

    final unassigned = device.assignToRoom(null);

    expect(unassigned.roomId, isNull);
    expect(unassigned.isPlaced, isFalse);
  });

  test('removeFromView clears room and placement', () {
    final device = _device(roomId: 'bedroom', x: .3, y: .4);

    final removed = device.removeFromView();

    expect(removed.roomId, isNull);
    expect(removed.isPlaced, isFalse);
  });
}
