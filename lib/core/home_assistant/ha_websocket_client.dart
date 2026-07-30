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
  /// Streams the `event` payload of every Home Assistant event of
  /// [eventType] (e.g. `state_changed`) until cancelled.
  Stream<Map<String, dynamic>> events({
    required String baseUrl,
    required String token,
    required String eventType,
  }) {
    final controller = StreamController<Map<String, dynamic>>();
    WebSocketChannel? channel;
    StreamSubscription? subscription;

    controller.onCancel = () async {
      await subscription?.cancel();
      await channel?.sink.close();
    };

    () async {
      final authCompleter = Completer<void>();
      var messageId = 1;
      int? subscribeId;
      try {
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
            if (!controller.isClosed) controller.close();
          },
          onDone: () {
            if (!authCompleter.isCompleted) {
              authCompleter.completeError(const HaConnectionException());
            }
            if (!controller.isClosed) controller.close();
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
      } on TimeoutException {
        if (!controller.isClosed) {
          controller.addError(const HaTimeoutException());
          await controller.close();
        }
      } catch (error) {
        if (!controller.isClosed) {
          controller.addError(
            error is HaClientException ? error : const HaConnectionException(),
          );
          await controller.close();
        }
      }
    }();

    return controller.stream;
  }

  Uri _toWebSocketUri(String baseUrl) {
    final uri = Uri.parse(baseUrl);
    final scheme = uri.scheme == 'https' ? 'wss' : 'ws';
    return uri.replace(scheme: scheme, path: '${uri.path}/api/websocket');
  }
}
