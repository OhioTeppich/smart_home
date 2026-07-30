import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'ha_client_exceptions.dart';

/// Thin REST wrapper around the Home Assistant HTTP API. Pure transport: no
/// knowledge of rooms, devices, or any other domain concept.
class HaRestClient {
  HaRestClient({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  /// `GET /api/config` — cheapest authenticated endpoint, used to verify
  /// that a base URL + token pair actually reaches a Home Assistant server.
  Future<void> ping({required String baseUrl, required String token}) =>
      _get('/api/config', baseUrl: baseUrl, token: token);

  Future<List<Map<String, dynamic>>> fetchStates({
    required String baseUrl,
    required String token,
  }) async {
    final body = await _get('/api/states', baseUrl: baseUrl, token: token);
    final decoded = jsonDecode(body);
    if (decoded is! List) {
      throw const HaProtocolException(
        'Unerwartetes Antwortformat von /api/states.',
      );
    }
    return decoded.cast<Map<String, dynamic>>();
  }

  Future<void> callService({
    required String baseUrl,
    required String token,
    required String domain,
    required String service,
    required String entityId,
  }) async {
    final response = await _send(
      () => _httpClient.post(
        _uri(baseUrl, '/api/services/$domain/$service'),
        headers: _headers(token),
        body: jsonEncode({'entity_id': entityId}),
      ),
    );
    _checkStatus(response);
  }

  Future<String> _get(
    String path, {
    required String baseUrl,
    required String token,
  }) async {
    final response = await _send(
      () => _httpClient.get(_uri(baseUrl, path), headers: _headers(token)),
    );
    _checkStatus(response);
    return response.body;
  }

  Future<http.Response> _send(
    Future<http.Response> Function() request,
  ) async {
    try {
      return await request().timeout(const Duration(seconds: 10));
    } on TimeoutException {
      throw const HaTimeoutException();
    } on HaClientException {
      rethrow;
    } catch (_) {
      throw const HaConnectionException();
    }
  }

  void _checkStatus(http.Response response) {
    if (response.statusCode == 401 || response.statusCode == 403) {
      throw const HaAuthException();
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HaProtocolException(
        'Home Assistant antwortete mit Status ${response.statusCode}.',
      );
    }
  }

  Uri _uri(String baseUrl, String path) => Uri.parse('$baseUrl$path');

  Map<String, String> _headers(String token) => {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };
}
