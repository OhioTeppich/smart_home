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

  Future<WeatherLocation> currentLocation() async {
    if (!await Geolocator.isLocationServiceEnabled())
      throw Exception('Standortdienste sind deaktiviert.');
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied)
      permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever)
      throw Exception('Standortberechtigung wurde nicht erteilt.');
    final position = await Geolocator.getCurrentPosition();
    return WeatherLocation(
      name: 'Mein Standort',
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }

  Future<WeatherSnapshot> fetch(WeatherLocation location) async {
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': '${location.latitude}',
      'longitude': '${location.longitude}',
      'timezone': 'auto',
      'current':
          'temperature_2m,apparent_temperature,weather_code,wind_speed_10m',
      'hourly': 'temperature_2m,precipitation_probability,weather_code',
      'daily': 'temperature_2m_max,temperature_2m_min',
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
  WebSocketChannel? _btcSocket;
  StreamSubscription? _btcSubscription;

  Future<MarketQuote> initial(MarketSymbol symbol) async {
    if (symbol == MarketSymbol.btc) {
      try {
        final now = DateTime.now();
        final start = now.subtract(const Duration(hours: 24));
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
    return _demo(symbol);
  }

  Stream<MarketQuote> live(MarketSymbol symbol) {
    if (symbol != MarketSymbol.btc) return const Stream.empty();
    final controller = StreamController<MarketQuote>();
    controller.onCancel = () async {
      await _btcSubscription?.cancel();
      await _btcSocket?.sink.close();
    };
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
                  final cutoff = DateTime.now().subtract(
                    const Duration(hours: 24),
                  );
                  final points = [
                    ...?_history[symbol],
                    MarketChartPoint(DateTime.now(), price),
                  ].where((point) => point.time.isAfter(cutoff)).toList();
                  _history[symbol] = points;
                  final first = _history[symbol]!.first.value;
                  if (!controller.isClosed) {
                    controller.add(
                      MarketQuote(
                        symbol: symbol,
                        price: price,
                        change: price - first,
                        changePercent: (price / first - 1) * 100,
                        updatedAt: DateTime.now(),
                        points: _history[symbol]!,
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
    final points = List.generate(
      24,
      (i) => MarketChartPoint(
        DateTime.now().subtract(Duration(hours: 23 - i)),
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
