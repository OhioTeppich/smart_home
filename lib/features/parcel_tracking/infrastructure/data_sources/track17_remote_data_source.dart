import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/failures/parcel_tracking_failure.dart';
import '../models/track17_status_dto.dart';

class Track17RemoteDataSource {
  Track17RemoteDataSource({
    required Future<String?> Function() apiKeyProvider,
    http.Client? httpClient,
  }) : _apiKeyProvider = apiKeyProvider,
       _http = httpClient ?? http.Client();

  static const _host = 'api.17track.net';

  final Future<String?> Function() _apiKeyProvider;
  final http.Client _http;

  Future<void> register(int carrierCode, String trackingNumber) async {
    final apiKey = await _requireApiKey();
    final response = await _http
        .post(
          Uri.https(_host, '/track/v2.4/register'),
          headers: _headers(apiKey),
          body: jsonEncode([
            {'number': trackingNumber, 'carrier': carrierCode},
          ]),
        )
        .timeout(const Duration(seconds: 10));
    _checkResponse(response);
  }

  Future<List<Track17StatusDto>> fetchStatuses(
    List<({int carrierCode, String trackingNumber})> refs,
  ) async {
    if (refs.isEmpty) return const [];
    final apiKey = await _requireApiKey();
    final response = await _http
        .post(
          Uri.https(_host, '/track/v2.4/gettrackinfo'),
          headers: _headers(apiKey),
          body: jsonEncode([
            for (final ref in refs)
              {'number': ref.trackingNumber, 'carrier': ref.carrierCode},
          ]),
        )
        .timeout(const Duration(seconds: 15));
    final json = _checkResponse(response);
    final data = json['data'] as Map<String, dynamic>? ?? const {};
    final accepted = data['accepted'] as List<dynamic>? ?? const [];
    return accepted
        .cast<Map<String, dynamic>>()
        .map(Track17StatusDto.fromJson)
        .toList();
  }

  Map<String, String> _headers(String apiKey) => {
    '17token': apiKey,
    'Content-Type': 'application/json',
  };

  Future<String> _requireApiKey() async {
    final apiKey = await _apiKeyProvider();
    if (apiKey == null || apiKey.isEmpty) {
      throw const ParcelProviderApiKeyMissingFailure();
    }
    return apiKey;
  }

  Map<String, dynamic> _checkResponse(http.Response response) {
    if (response.statusCode == 401 || response.statusCode == 403) {
      throw const ParcelProviderUnauthorizedFailure();
    }
    if (response.statusCode == 429) {
      throw const ParcelRateLimitedFailure();
    }
    if (response.statusCode != 200) {
      throw ParcelUnexpectedFailure('HTTP ${response.statusCode}');
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final code = json['code'] as int? ?? 0;
    if (code != 0) {
      throw ParcelUnexpectedFailure('17Track-Fehlercode $code');
    }
    return json;
  }
}
