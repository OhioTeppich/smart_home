import 'package:flutter_test/flutter_test.dart';
import 'package:smart_home/features/rooms/infrastructure/data_sources/ha_area_alias_mapper.dart';

void main() {
  const mapper = HaAreaAliasMapper();

  test('matches German room keywords in the entity id', () {
    expect(
      mapper.match(entityId: 'light.wohnzimmer_lampe'),
      'livingRoom',
    );
    expect(
      mapper.match(entityId: 'light.schlafzimmer_lampe'),
      'bedroom',
    );
    expect(mapper.match(entityId: 'switch.kueche_steckdose'), 'kitchen');
    expect(mapper.match(entityId: 'switch.küche_steckdose'), 'kitchen');
    expect(mapper.match(entityId: 'sensor.bad_feuchtigkeit'), 'bathroom');
    expect(mapper.match(entityId: 'light.flur_lampe'), 'hallway');
    expect(mapper.match(entityId: 'light.diele_lampe'), 'hallway');
  });

  test('falls back to the friendly name when the entity id has no hint', () {
    expect(
      mapper.match(
        entityId: 'light.esp_1234',
        friendlyName: 'Wohnzimmer Deckenlampe',
      ),
      'livingRoom',
    );
  });

  test('returns null when nothing matches', () {
    expect(
      mapper.match(entityId: 'light.garten_strahler', friendlyName: 'Garten'),
      isNull,
    );
  });

  test('matching is case-insensitive', () {
    expect(mapper.match(entityId: 'light.WOHNZIMMER_lampe'), 'livingRoom');
  });
}
