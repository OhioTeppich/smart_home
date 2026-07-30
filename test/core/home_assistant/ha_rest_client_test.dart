import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:smart_home/core/home_assistant/ha_client_exceptions.dart';
import 'package:smart_home/core/home_assistant/ha_rest_client.dart';

void main() {
  const baseUrl = 'https://ha.example.com';
  const token = 'secret-token';

  test('ping() succeeds on 200 and sends bearer auth header', () async {
    http.Request? seenRequest;
    final client = HaRestClient(
      httpClient: MockClient((request) async {
        seenRequest = request;
        return http.Response('{}', 200);
      }),
    );

    await client.ping(baseUrl: baseUrl, token: token);

    expect(seenRequest!.url.toString(), '$baseUrl/api/config');
    expect(seenRequest!.headers['Authorization'], 'Bearer $token');
  });

  test('ping() throws HaAuthException on 401', () async {
    final client = HaRestClient(
      httpClient: MockClient((request) async => http.Response('', 401)),
    );

    expect(
      () => client.ping(baseUrl: baseUrl, token: token),
      throwsA(isA<HaAuthException>()),
    );
  });

  test('ping() throws HaAuthException on 403', () async {
    final client = HaRestClient(
      httpClient: MockClient((request) async => http.Response('', 403)),
    );

    expect(
      () => client.ping(baseUrl: baseUrl, token: token),
      throwsA(isA<HaAuthException>()),
    );
  });

  test('ping() throws HaProtocolException on unexpected server error', () async {
    final client = HaRestClient(
      httpClient: MockClient((request) async => http.Response('', 500)),
    );

    expect(
      () => client.ping(baseUrl: baseUrl, token: token),
      throwsA(isA<HaProtocolException>()),
    );
  });

  test('ping() throws HaConnectionException when the request fails', () async {
    final client = HaRestClient(
      httpClient: MockClient((request) async => throw Exception('no route')),
    );

    expect(
      () => client.ping(baseUrl: baseUrl, token: token),
      throwsA(isA<HaConnectionException>()),
    );
  });

  test('fetchStates() decodes the state list', () async {
    final client = HaRestClient(
      httpClient: MockClient((request) async {
        expect(request.url.toString(), '$baseUrl/api/states');
        return http.Response(
          jsonEncode([
            {
              'entity_id': 'light.wohnzimmer_lampe',
              'state': 'on',
              'attributes': {'friendly_name': 'Wohnzimmer Lampe'},
            },
          ]),
          200,
        );
      }),
    );

    final states = await client.fetchStates(baseUrl: baseUrl, token: token);

    expect(states, hasLength(1));
    expect(states.single['entity_id'], 'light.wohnzimmer_lampe');
  });

  test('fetchStates() throws HaProtocolException on non-list body', () async {
    final client = HaRestClient(
      httpClient: MockClient((request) async => http.Response('{}', 200)),
    );

    expect(
      () => client.fetchStates(baseUrl: baseUrl, token: token),
      throwsA(isA<HaProtocolException>()),
    );
  });

  test('callService() posts entity_id to the service endpoint', () async {
    http.Request? seenRequest;
    final client = HaRestClient(
      httpClient: MockClient((request) async {
        seenRequest = request;
        return http.Response('[]', 200);
      }),
    );

    await client.callService(
      baseUrl: baseUrl,
      token: token,
      domain: 'light',
      service: 'turn_on',
      entityId: 'light.wohnzimmer_lampe',
    );

    expect(
      seenRequest!.url.toString(),
      '$baseUrl/api/services/light/turn_on',
    );
    expect(
      jsonDecode(seenRequest!.body),
      {'entity_id': 'light.wohnzimmer_lampe'},
    );
  });
}
