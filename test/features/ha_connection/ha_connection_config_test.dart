import 'package:flutter_test/flutter_test.dart';
import 'package:smart_home/features/ha_connection/domain/value_objects/ha_connection_config.dart';

void main() {
  group('HaConnectionConfig.tryCreate', () {
    test('accepts a valid https URL and trims a trailing slash', () {
      final config = HaConnectionConfig.tryCreate(
        baseUrl: 'https://homeassistant.local:8123/',
        token: ' secret ',
      );

      expect(config, isNotNull);
      expect(config!.baseUrl, 'https://homeassistant.local:8123');
      expect(config.token, 'secret');
    });

    test('accepts http', () {
      final config = HaConnectionConfig.tryCreate(
        baseUrl: 'http://192.168.1.20:8123',
        token: 'secret',
      );

      expect(config, isNotNull);
    });

    test('rejects a non-http(s) scheme', () {
      final config = HaConnectionConfig.tryCreate(
        baseUrl: 'ftp://homeassistant.local',
        token: 'secret',
      );

      expect(config, isNull);
    });

    test('rejects a URL without a host', () {
      final config = HaConnectionConfig.tryCreate(
        baseUrl: 'https://',
        token: 'secret',
      );

      expect(config, isNull);
    });

    test('rejects an empty token', () {
      final config = HaConnectionConfig.tryCreate(
        baseUrl: 'https://homeassistant.local',
        token: '   ',
      );

      expect(config, isNull);
    });
  });
}
