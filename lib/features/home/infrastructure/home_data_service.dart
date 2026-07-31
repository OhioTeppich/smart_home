import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

import '../domain/home_models.dart';

class WeatherService {
  Future<WeatherLocation> search(String query) async {
    final response = await http
        .get(
          Uri.https('geocoding-api.open-meteo.com', '/v1/search', {
            'name': query,
            'count': '1',
            'language': 'de',
            'format': 'json',
          }),
        )
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200)
      throw Exception('Ort konnte nicht gefunden werden.');
    final results = (jsonDecode(response.body)['results'] as List?) ?? const [];
    if (results.isEmpty) throw Exception('Ort konnte nicht gefunden werden.');
    final result = results.first as Map<String, dynamic>;
    return WeatherLocation(
      name: '${result['name']}, ${result['country']}',
      latitude: (result['latitude'] as num).toDouble(),
      longitude: (result['longitude'] as num).toDouble(),
    );
  }

  static const _fallbackLocation = WeatherLocation(
    name: 'Oelde',
    latitude: 51.8167,
    longitude: 8.15,
  );

  Future<WeatherLocation> currentLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return _fallbackLocation;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied)
        permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever)
        return _fallbackLocation;
      final position = await Geolocator.getCurrentPosition()
          .timeout(const Duration(seconds: 8));
      return WeatherLocation(
        name: 'Mein Standort',
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (_) {
      return _fallbackLocation;
    }
  }

  Future<WeatherSnapshot> fetch(WeatherLocation location) async {
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': '${location.latitude}',
      'longitude': '${location.longitude}',
      'timezone': 'auto',
      'current':
          'temperature_2m,apparent_temperature,weather_code,wind_speed_10m,relative_humidity_2m',
      'hourly': 'temperature_2m,precipitation_probability,weather_code',
      'daily': 'temperature_2m_max,temperature_2m_min,sunrise,sunset',
      'forecast_days': '1',
    });
    final response = await http.get(uri).timeout(const Duration(seconds: 12));
    if (response.statusCode != 200)
      throw Exception(
        'Wetterdienst nicht erreichbar (${response.statusCode}).',
      );
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final current = json['current'] as Map<String, dynamic>;
    final hourly = json['hourly'] as Map<String, dynamic>;
    final times = (hourly['time'] as List).cast<String>();
    final temps = (hourly['temperature_2m'] as List).cast<num>();
    final rain = (hourly['precipitation_probability'] as List).cast<num>();
    final codes = (hourly['weather_code'] as List).cast<num>();
    return WeatherSnapshot(
      location: location,
      temperature: (current['temperature_2m'] as num).toDouble(),
      feelsLike: (current['apparent_temperature'] as num).toDouble(),
      windSpeed: (current['wind_speed_10m'] as num).toDouble(),
      weatherCode: (current['weather_code'] as num).toInt(),
      minTemperature:
          (((json['daily'] as Map)['temperature_2m_min'] as List).first as num)
              .toDouble(),
      maxTemperature:
          (((json['daily'] as Map)['temperature_2m_max'] as List).first as num)
              .toDouble(),
      humidity: (current['relative_humidity_2m'] as num).toInt(),
      sunrise: DateTime.parse(
        (((json['daily'] as Map)['sunrise'] as List).first as String),
      ),
      sunset: DateTime.parse(
        (((json['daily'] as Map)['sunset'] as List).first as String),
      ),
      updatedAt: DateTime.now(),
      hourly: [
        for (var i = 0; i < min(24, times.length); i++)
          HourlyWeatherPoint(
            time: DateTime.parse(times[i]),
            temperature: temps[i].toDouble(),
            precipitationProbability: rain[i].toInt(),
            weatherCode: codes[i].toInt(),
          ),
      ],
    );
  }
}

class MarketService {
  final Map<MarketSymbol, List<MarketChartPoint>> _history = {};
  final Set<MarketSymbol> _realHistory = {};
  WebSocketChannel? _btcSocket;
  StreamSubscription? _btcSubscription;

  Future<MarketQuote> initial(MarketSymbol symbol) async {
    if (symbol == MarketSymbol.btc) {
      try {
        final now = DateTime.now();
        final start = DateTime(now.year, now.month, now.day);
        final response = await http
            .get(
              Uri.https(
                'api.coinbase.com',
                '/api/v3/brokerage/market/products/BTC-USD/candles',
                {
                  'granularity': 'ONE_HOUR',
                  'start': '${start.millisecondsSinceEpoch ~/ 1000}',
                  'end': '${now.millisecondsSinceEpoch ~/ 1000}',
                },
              ),
            )
            .timeout(const Duration(seconds: 10));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body)['candles'] as List;
          final points = data.reversed
              .map(
                (item) => MarketChartPoint(
                  DateTime.fromMillisecondsSinceEpoch(
                    int.parse(item['start'] as String) * 1000,
                  ),
                  double.parse(item['close'] as String),
                ),
              )
              .where((point) => point.time.isAfter(start))
              .toList();
          _history[symbol] = points;
          _realHistory.add(symbol);
          final price = points.last.value;
          return MarketQuote(
            symbol: symbol,
            price: price,
            change: price - points.first.value,
            changePercent: (price / points.first.value - 1) * 100,
            updatedAt: DateTime.now(),
            points: points,
            isLive: true,
          );
        }
      } catch (_) {}
    }
    final yahooSymbol = switch (symbol) {
      MarketSymbol.nq => '^NDX',
      MarketSymbol.es => '^GSPC',
      MarketSymbol.btc => null,
    };
    if (yahooSymbol != null) {
      final quote = await _fetchYahooIndex(symbol, yahooSymbol);
      if (quote != null) return quote;
    }
    return _demo(symbol);
  }

  Future<MarketQuote?> _fetchYahooIndex(
    MarketSymbol symbol,
    String yahooSymbol,
  ) async {
    try {
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day);
      final response = await http
          .get(
            Uri.https(
              'query1.finance.yahoo.com',
              '/v8/finance/chart/$yahooSymbol',
              {'interval': '1h', 'range': '1d'},
            ),
            headers: {'User-Agent': 'Mozilla/5.0'},
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return null;
      final result =
          (jsonDecode(response.body)['chart']['result'] as List?)?.first
              as Map<String, dynamic>?;
      final timestamps = (result?['timestamp'] as List?)?.cast<int>();
      final closes =
          ((result?['indicators']['quote'] as List?)?.first
                  as Map<String, dynamic>?)?['close']
              as List?;
      if (timestamps == null || closes == null) return null;
      final points = <MarketChartPoint>[
        for (var i = 0; i < timestamps.length; i++)
          if (closes[i] != null)
            MarketChartPoint(
              DateTime.fromMillisecondsSinceEpoch(timestamps[i] * 1000),
              (closes[i] as num).toDouble(),
            ),
      ].where((point) => point.time.isAfter(start)).toList();
      if (points.isEmpty) return null;
      _history[symbol] = points;
      final price = points.last.value;
      return MarketQuote(
        symbol: symbol,
        price: price,
        change: price - points.first.value,
        changePercent: (price / points.first.value - 1) * 100,
        updatedAt: DateTime.now(),
        points: points,
        isLive: true,
      );
    } catch (_) {
      return null;
    }
  }

  Stream<MarketQuote> live(MarketSymbol symbol) {
    if (symbol != MarketSymbol.btc) return const Stream.empty();
    final controller = StreamController<MarketQuote>();
    controller.onCancel = () async {
      await _btcSubscription?.cancel();
      await _btcSocket?.sink.close();
    };
    DateTime? lastCutoff;
    () async {
      try {
        _btcSocket = WebSocketChannel.connect(
          Uri.parse('wss://advanced-trade-ws.coinbase.com'),
        );
        await _btcSocket!.ready;
        _btcSocket!.sink.add(
          jsonEncode({
            'type': 'subscribe',
            'product_ids': ['BTC-USD'],
            'channel': 'ticker',
          }),
        );
        _btcSubscription = _btcSocket!.stream.listen(
          (raw) {
            try {
              if (raw is! String) return;
              final decoded = jsonDecode(raw);
              if (decoded is! Map<String, dynamic>) return;
              final events = (decoded['events'] as List?) ?? const [];
              for (final event in events) {
                if (event is! Map) continue;
                for (final ticker in (event['tickers'] as List?) ?? const []) {
                  if (ticker is! Map) continue;
                  final price = double.tryParse(
                    ticker['price']?.toString() ?? '',
                  );
                  if (price == null) continue;
                  final nowTime = DateTime.now();
                  final cutoff = DateTime(
                    nowTime.year,
                    nowTime.month,
                    nowTime.day,
                  );
                  if (!_realHistory.contains(symbol)) {
                    // Demo-Platzhalterpreis verwerfen, sonst vermischt sich
                    // Fake-Historie mit echten Live-Preisen (falsche Prozente).
                    _history[symbol] = [];
                    _realHistory.add(symbol);
                    lastCutoff = cutoff;
                  }
                  // The ticker can fire many times a second; appending in
                  // place instead of rebuilding+filtering the whole day's
                  // history on every message keeps this O(1) amortized.
                  // Only re-filter on an actual day rollover, which is the
                  // one time stale (yesterday's) points need dropping.
                  final points = _history[symbol]!;
                  if (lastCutoff != cutoff) {
                    points.removeWhere((point) => !point.time.isAfter(cutoff));
                    lastCutoff = cutoff;
                  }
                  points.add(MarketChartPoint(nowTime, price));
                  final first = points.first.value;
                  if (!controller.isClosed) {
                    controller.add(
                      MarketQuote(
                        symbol: symbol,
                        price: price,
                        change: price - first,
                        changePercent: (price / first - 1) * 100,
                        updatedAt: nowTime,
                        points: points,
                        isLive: true,
                      ),
                    );
                  }
                }
              }
            } catch (_) {
              // Einzelne fehlerhafte Nachrichten dürfen den Live-Stream nicht beenden.
            }
          },
          onError: (_, __) {
            if (!controller.isClosed) controller.close();
          },
          onDone: () {
            if (!controller.isClosed) controller.close();
          },
          cancelOnError: false,
        );
      } catch (_) {
        if (!controller.isClosed) await controller.close();
      }
    }();
    return controller.stream;
  }

  Future<void> dispose() async {
    await _btcSubscription?.cancel();
    await _btcSocket?.sink.close();
  }

  MarketQuote _demo(MarketSymbol symbol) {
    final base = switch (symbol) {
      MarketSymbol.nq => 19000.0,
      MarketSymbol.es => 5400.0,
      MarketSymbol.btc => 108000.0,
    };
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final hoursToday = max(1, now.difference(startOfDay).inHours);
    final points = List.generate(
      hoursToday + 1,
      (i) => MarketChartPoint(
        startOfDay.add(Duration(hours: i)),
        base + sin(i / 3) * base * .004 + i * base * .0003,
      ),
    );
    _history[symbol] = points;
    final price = points.last.value;
    return MarketQuote(
      symbol: symbol,
      price: price,
      change: price - points.first.value,
      changePercent: (price / points.first.value - 1) * 100,
      updatedAt: DateTime.now(),
      points: points,
      isLive: false,
    );
  }
}
