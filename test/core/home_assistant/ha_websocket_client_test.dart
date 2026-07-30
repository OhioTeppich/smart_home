import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:smart_home/core/home_assistant/ha_client_exceptions.dart';
import 'package:smart_home/core/home_assistant/ha_websocket_client.dart';

/// Minimal fake Home Assistant WebSocket endpoint, backed by a real local
/// `dart:io` server, so the client's auth handshake + message-id
/// correlation can be exercised end-to-end instead of mocked away.
class _FakeHaServer {
  _FakeHaServer._(this._server);

  final HttpServer _server;
  WebSocket? _lastSocket;
  final _subscribed = Completer<void>();

  /// Completes once the fake server has acked a `subscribe_events` command,
  /// i.e. once the real handshake the client performs has fully settled.
  Future<void> get subscribed => _subscribed.future;

  static Future<_FakeHaServer> start() async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final fake = _FakeHaServer._(server);
    fake._serve();
    return fake;
  }

  String get baseUrl => 'http://${_server.address.address}:${_server.port}';

  void _serve() {
    _server.listen((request) async {
      final socket = await WebSocketTransformer.upgrade(request);
      _lastSocket = socket;
      socket.add(jsonEncode({'type': 'auth_required'}));
      socket.listen((raw) {
        final decoded = jsonDecode(raw as String) as Map<String, dynamic>;
        if (decoded['type'] == 'auth') {
          if (decoded['access_token'] == 'valid-token') {
            socket.add(jsonEncode({'type': 'auth_ok'}));
          } else {
            socket.add(jsonEncode({'type': 'auth_invalid'}));
          }
        } else if (decoded['type'] == 'subscribe_events') {
          socket.add(
            jsonEncode({'id': decoded['id'], 'type': 'result', 'success': true}),
          );
          if (!_subscribed.isCompleted) _subscribed.complete();
        }
      });
    });
  }

  void pushMalformedFrame() => _lastSocket!.add('not json');

  void pushEvent(Map<String, dynamic> event) => _lastSocket!.add(
    jsonEncode({'id': 1, 'type': 'event', 'event': event}),
  );

  Future<void> close() => _server.close(force: true);
}

void main() {
  late _FakeHaServer server;

  setUp(() async => server = await _FakeHaServer.start());
  tearDown(() => server.close());

  test('completes auth handshake and delivers subscribed events', () async {
    final client = HaWebSocketClient();
    final events = client.events(
      baseUrl: server.baseUrl,
      token: 'valid-token',
      eventType: 'state_changed',
    );

    final firstEvent = events.first;
    await server.subscribed;
    server.pushEvent({
      'event_type': 'state_changed',
      'data': {'entity_id': 'light.wohnzimmer_lampe'},
    });

    final received = await firstEvent;
    expect(received['data']['entity_id'], 'light.wohnzimmer_lampe');
  });

  test('ignores a malformed frame and keeps streaming', () async {
    final client = HaWebSocketClient();
    final events = client.events(
      baseUrl: server.baseUrl,
      token: 'valid-token',
      eventType: 'state_changed',
    );

    final collected = <Map<String, dynamic>>[];
    final subscription = events.listen(collected.add);
    await server.subscribed;

    server.pushMalformedFrame();
    server.pushEvent({
      'event_type': 'state_changed',
      'data': {'entity_id': 'light.kueche_lampe'},
    });
    await Future.delayed(const Duration(milliseconds: 100));

    expect(collected, hasLength(1));
    expect(collected.single['data']['entity_id'], 'light.kueche_lampe');
    await subscription.cancel();
  });

  test('emits HaAuthException when the token is rejected', () async {
    final client = HaWebSocketClient();
    final events = client.events(
      baseUrl: server.baseUrl,
      token: 'wrong-token',
      eventType: 'state_changed',
    );

    await expectLater(events, emitsError(isA<HaAuthException>()));
  });

  test('emits HaConnectionException when the server is unreachable', () async {
    final client = HaWebSocketClient();
    final events = client.events(
      baseUrl: 'http://127.0.0.1:1',
      token: 'valid-token',
      eventType: 'state_changed',
    );

    await expectLater(events, emitsError(isA<HaConnectionException>()));
  });
}
