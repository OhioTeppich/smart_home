import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import 'ha_client_exceptions.dart';

/// Thin WebSocket wrapper around the Home Assistant WebSocket API
/// (`/api/websocket`). Pure transport: no knowledge of rooms, devices, or
/// any other domain concept.
///
/// Handles the auth handshake (`auth_required` → send `auth` →
/// `auth_ok`/`auth_invalid`) and the message-id correlation Home Assistant
/// requires (`subscribe_events` → ack `result` → ongoing `event` pushes)
/// internally, then exposes just the resulting event stream. Structured
/// after `MarketService.live()` in
/// `lib/features/home/infrastructure/home_data_service.dart`: a
/// `StreamController` whose `onCancel` tears the socket down, and
/// per-message `try/catch` so one malformed frame never kills the stream.
class HaWebSocketClient {
  static const _initialReconnectDelay = Duration(seconds: 1);
  static const _maxReconnectDelay = Duration(seconds: 30);

  /// Streams the `event` payload of every Home Assistant event of
  /// [eventType] (e.g. `state_changed`) until cancelled.
  ///
  /// The very first connection attempt behaves as before: a failure (bad
  /// credentials, unreachable host, timeout) surfaces once via
  /// [StreamController.addError] and closes the stream — the caller
  /// (`SmartHomeBloc`) already treats that as "not connected" and shows an
  /// error state. Once a connection has been established at least once,
  /// though, a later drop (network blip, HA restart) is retried with
  /// exponential backoff instead of leaving the stream dead — without this,
  /// live updates would silently stop until something else (a connection
  /// config change) tore down and rebuilt the whole repository. Bad
  /// credentials ([HaAuthException]) never retry, even after a prior
  /// success, since the token isn't going to fix itself.
  Stream<Map<String, dynamic>> events({
    required String baseUrl,
    required String token,
    required String eventType,
  }) {
    final controller = StreamController<Map<String, dynamic>>();
    var cancelled = false;
    WebSocketChannel? channel;
    StreamSubscription? subscription;
    var reconnectDelay = _initialReconnectDelay;

    controller.onCancel = () async {
      cancelled = true;
      await subscription?.cancel();
      await channel?.sink.close().timeout(
        const Duration(seconds: 2),
        onTimeout: () {},
      );
    };

    /// Runs one connection attempt end to end: connect, auth, subscribe,
    /// then waits until the socket disconnects. Returns whether the
    /// subscribe message was ever sent, i.e. whether this (or an earlier)
    /// attempt counts as "was live at least once".
    Future<bool> connectOnce() async {
      final authCompleter = Completer<void>();
      final disconnectedCompleter = Completer<void>();
      var messageId = 1;
      int? subscribeId;
      var subscribed = false;

      channel = WebSocketChannel.connect(_toWebSocketUri(baseUrl));
      await channel!.ready;

      subscription = channel!.stream.listen(
        (raw) {
          try {
            if (raw is! String) return;
            final decoded = jsonDecode(raw);
            if (decoded is! Map<String, dynamic>) return;
            switch (decoded['type']) {
              case 'auth_required':
                channel!.sink.add(
                  jsonEncode({'type': 'auth', 'access_token': token}),
                );
                break;
              case 'auth_ok':
                if (!authCompleter.isCompleted) authCompleter.complete();
                break;
              case 'auth_invalid':
                if (!authCompleter.isCompleted) {
                  authCompleter.completeError(const HaAuthException());
                }
                break;
              case 'result':
                if (decoded['id'] == subscribeId &&
                    decoded['success'] != true &&
                    !controller.isClosed) {
                  controller.addError(
                    const HaProtocolException(
                      'Abonnieren der Home-Assistant-Events fehlgeschlagen.',
                    ),
                  );
                }
                break;
              case 'event':
                final event = decoded['event'];
                if (event is Map<String, dynamic> && !controller.isClosed) {
                  controller.add(event);
                }
                break;
              default:
                // Andere Nachrichtentypen (z.B. 'pong') sind für diesen
                // Client irrelevant.
                break;
            }
          } catch (_) {
            // Einzelne fehlerhafte Nachrichten dürfen den Live-Stream
            // nicht beenden.
          }
        },
        onError: (_, __) {
          if (!authCompleter.isCompleted) {
            authCompleter.completeError(const HaConnectionException());
          }
          if (!disconnectedCompleter.isCompleted) {
            disconnectedCompleter.complete();
          }
        },
        onDone: () {
          if (!authCompleter.isCompleted) {
            authCompleter.completeError(const HaConnectionException());
          }
          if (!disconnectedCompleter.isCompleted) {
            disconnectedCompleter.complete();
          }
        },
        cancelOnError: false,
      );

      await authCompleter.future.timeout(const Duration(seconds: 10));

      subscribeId = messageId++;
      channel!.sink.add(
        jsonEncode({
          'id': subscribeId,
          'type': 'subscribe_events',
          'event_type': eventType,
        }),
      );
      subscribed = true;
      reconnectDelay = _initialReconnectDelay;

      await disconnectedCompleter.future;
      return subscribed;
    }

    () async {
      var everConnected = false;
      while (!cancelled) {
        HaClientException? failure;
        try {
          everConnected = await connectOnce();
        } on TimeoutException {
          failure = const HaTimeoutException();
        } catch (error) {
          failure = error is HaClientException
              ? error
              : const HaConnectionException();
        }
        await subscription?.cancel();
        // A socket whose connection never actually succeeded (e.g. the
        // host was unreachable) can hang here indefinitely instead of
        // closing — bound it so a failed attempt can't stall the retry
        // loop forever.
        await channel?.sink.close().timeout(
          const Duration(seconds: 2),
          onTimeout: () {},
        );

        if (failure != null && !controller.isClosed) {
          controller.addError(failure);
          if (!everConnected || failure is HaAuthException) {
            await controller.close();
            return;
          }
        }
        if (cancelled || controller.isClosed) return;

        await Future.delayed(reconnectDelay);
        if (cancelled) return;
        final doubled = reconnectDelay * 2;
        reconnectDelay = doubled > _maxReconnectDelay
            ? _maxReconnectDelay
            : doubled;
      }
    }();

    return controller.stream;
  }

  /// Fetches Home Assistant's entity registry (`config/entity_registry/list`)
  /// — one-off request/response over a short-lived connection, closed again
  /// once the result arrives. Used to read `entity_category` (diagnostic
  /// sensors, config entities, ...) which `/api/states` does not expose.
  Future<List<Map<String, dynamic>>> fetchEntityRegistry({
    required String baseUrl,
    required String token,
  }) async {
    const requestId = 1;
    WebSocketChannel? channel;
    StreamSubscription? subscription;
    try {
      final authCompleter = Completer<void>();
      final resultCompleter = Completer<List<Map<String, dynamic>>>();

      channel = WebSocketChannel.connect(_toWebSocketUri(baseUrl));
      await channel.ready;

      subscription = channel.stream.listen(
        (raw) {
          try {
            if (raw is! String) return;
            final decoded = jsonDecode(raw);
            if (decoded is! Map<String, dynamic>) return;
            switch (decoded['type']) {
              case 'auth_required':
                channel!.sink.add(
                  jsonEncode({'type': 'auth', 'access_token': token}),
                );
                break;
              case 'auth_ok':
                if (!authCompleter.isCompleted) authCompleter.complete();
                break;
              case 'auth_invalid':
                if (!authCompleter.isCompleted) {
                  authCompleter.completeError(const HaAuthException());
                }
                break;
              case 'result':
                if (decoded['id'] == requestId &&
                    !resultCompleter.isCompleted) {
                  if (decoded['success'] == true) {
                    resultCompleter.complete(
                      (decoded['result'] as List).cast<Map<String, dynamic>>(),
                    );
                  } else {
                    resultCompleter.completeError(
                      const HaProtocolException(
                        'Abrufen der Home-Assistant-Entity-Registry fehlgeschlagen.',
                      ),
                    );
                  }
                }
                break;
              default:
                break;
            }
          } catch (_) {
            // Einzelne fehlerhafte Nachrichten dürfen den Abruf nicht
            // abbrechen — nur die erwartete `result`-Nachricht zählt.
          }
        },
        onError: (_, __) {
          if (!authCompleter.isCompleted) {
            authCompleter.completeError(const HaConnectionException());
          }
          if (!resultCompleter.isCompleted) {
            resultCompleter.completeError(const HaConnectionException());
          }
        },
        onDone: () {
          if (!authCompleter.isCompleted) {
            authCompleter.completeError(const HaConnectionException());
          }
          if (!resultCompleter.isCompleted) {
            resultCompleter.completeError(const HaConnectionException());
          }
        },
        cancelOnError: false,
      );

      await authCompleter.future.timeout(const Duration(seconds: 10));
      channel.sink.add(
        jsonEncode({'id': requestId, 'type': 'config/entity_registry/list'}),
      );
      return await resultCompleter.future.timeout(const Duration(seconds: 10));
    } on TimeoutException {
      throw const HaTimeoutException();
    } catch (error) {
      if (error is HaClientException) rethrow;
      throw const HaConnectionException();
    } finally {
      await subscription?.cancel();
      // Same reasoning as in `events()`: closing a socket that never
      // actually connected can hang instead of completing.
      await channel?.sink.close().timeout(
        const Duration(seconds: 2),
        onTimeout: () {},
      );
    }
  }

  Uri _toWebSocketUri(String baseUrl) {
    final uri = Uri.parse(baseUrl);
    final scheme = uri.scheme == 'https' ? 'wss' : 'ws';
    return uri.replace(scheme: scheme, path: '${uri.path}/api/websocket');
  }
}
