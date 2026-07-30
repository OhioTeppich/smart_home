import 'package:flutter_test/flutter_test.dart';
import 'package:smart_home/features/rooms/domain/entities/smart_home_device.dart';
import 'package:smart_home/features/rooms/infrastructure/models/ha_entity_state_dto.dart';

void main() {
  group('type mapping per Home Assistant domain', () {
    final cases = {
      'light.wohnzimmer_lampe': SmartHomeDeviceType.bulb,
      'switch.kueche_steckdose': SmartHomeDeviceType.plug,
      'media_player.wohnzimmer_tv': SmartHomeDeviceType.television,
      'sensor.aussen_temperatur': SmartHomeDeviceType.sensor,
      'binary_sensor.tuer_kontakt': SmartHomeDeviceType.sensor,
      'climate.wohnzimmer_thermostat': SmartHomeDeviceType.climate,
      'cover.schlafzimmer_rollladen': SmartHomeDeviceType.cover,
      'automation.abendroutine': SmartHomeDeviceType.other,
    };

    cases.forEach((entityId, expectedType) {
      test('$entityId -> $expectedType', () {
        final dto = HaEntityStateDto.fromJson({
          'entity_id': entityId,
          'state': 'on',
          'attributes': <String, dynamic>{},
        });

        expect(dto.toDomain(roomId: null).type, expectedType);
      });
    });
  });

  test('uses friendly_name when present, otherwise humanizes the entity id', () {
    final withName = HaEntityStateDto.fromJson({
      'entity_id': 'light.wohnzimmer_lampe',
      'state': 'on',
      'attributes': {'friendly_name': 'Wohnzimmer Lampe'},
    });
    final withoutName = HaEntityStateDto.fromJson({
      'entity_id': 'light.wohnzimmer_lampe',
      'state': 'on',
      'attributes': <String, dynamic>{},
    });

    expect(withName.toDomain(roomId: null).name, 'Wohnzimmer Lampe');
    expect(withoutName.toDomain(roomId: null).name, 'Wohnzimmer Lampe');
  });

  group('isOn derivation', () {
    test('light/switch: on only for state "on"', () {
      final on = HaEntityStateDto.fromJson({
        'entity_id': 'light.x',
        'state': 'on',
        'attributes': <String, dynamic>{},
      });
      final off = HaEntityStateDto.fromJson({
        'entity_id': 'light.x',
        'state': 'off',
        'attributes': <String, dynamic>{},
      });

      expect(on.toDomain(roomId: null).isOn, isTrue);
      expect(off.toDomain(roomId: null).isOn, isFalse);
    });

    test('media_player: playing/paused count as on, idle/off do not', () {
      for (final state in ['playing', 'paused']) {
        final dto = HaEntityStateDto.fromJson({
          'entity_id': 'media_player.x',
          'state': state,
          'attributes': <String, dynamic>{},
        });
        expect(dto.toDomain(roomId: null).isOn, isTrue, reason: state);
      }
      for (final state in ['idle', 'off']) {
        final dto = HaEntityStateDto.fromJson({
          'entity_id': 'media_player.x',
          'state': state,
          'attributes': <String, dynamic>{},
        });
        expect(dto.toDomain(roomId: null).isOn, isFalse, reason: state);
      }
    });

    test('unavailable/unknown are always off and marked not available', () {
      for (final state in ['unavailable', 'unknown']) {
        final dto = HaEntityStateDto.fromJson({
          'entity_id': 'light.x',
          'state': state,
          'attributes': <String, dynamic>{},
        });
        final device = dto.toDomain(roomId: null);
        expect(device.isOn, isFalse, reason: state);
        expect(device.status, 'Nicht verfügbar', reason: state);
      }
    });
  });

  test('passes the resolved roomId through untouched', () {
    final dto = HaEntityStateDto.fromJson({
      'entity_id': 'light.x',
      'state': 'on',
      'attributes': <String, dynamic>{},
    });

    expect(dto.toDomain(roomId: 'livingRoom').roomId, 'livingRoom');
    expect(dto.toDomain(roomId: null).roomId, isNull);
  });
}
