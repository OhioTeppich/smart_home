import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../rooms/domain/entities/smart_home_device.dart';
import '../domain/home_models.dart';
import '../infrastructure/home_data_service.dart';

enum DeviceRanking { consumption, power, switches }

class HomeController extends ChangeNotifier {
  HomeController({WeatherService? weather, MarketService? market})
    : _weather = weather ?? WeatherService(),
      _market = market ?? MarketService();
  final WeatherService _weather;
  final MarketService _market;
  WeatherSnapshot? weatherSnapshot;
  final Map<MarketSymbol, MarketQuote> marketQuotes = {};
  DeviceRanking ranking = DeviceRanking.consumption;
  String? weatherError;
  WeatherLocation? selectedLocation;
  bool loadingWeather = false;
  Timer? _weatherTimer;
  Timer? _marketTimer;
  StreamSubscription? _marketSubscription;

  Future<void> start() async {
    await refreshWeather();
    await refreshMarkets();
    _marketSubscription = _market.live(MarketSymbol.btc).listen((quote) {
      marketQuotes[quote.symbol] = quote;
      notifyListeners();
    });
    _weatherTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => refreshWeather(),
    );
    _marketTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => refreshMarkets(),
    );
  }

  Future<void> refreshMarkets() async {
    final quotes = await Future.wait(MarketSymbol.values.map(_market.initial));
    for (final quote in quotes) {
      marketQuotes[quote.symbol] = quote;
    }
    notifyListeners();
  }

  Future<void> refreshWeather() async {
    loadingWeather = true;
    notifyListeners();
    try {
      selectedLocation ??= await _weather.currentLocation();
      weatherSnapshot = await _weather.fetch(selectedLocation!);
      weatherError = null;
    } catch (error) {
      weatherError = error.toString().replaceFirst('Exception: ', '');
    }
    loadingWeather = false;
    notifyListeners();
  }

  Future<void> searchWeatherLocation(String query) async {
    selectedLocation = await _weather.search(query);
    await refreshWeather();
  }

  void setRanking(DeviceRanking value) {
    ranking = value;
    notifyListeners();
  }

  List<SmartHomeDevice> rankedDevices(List<SmartHomeDevice> devices) {
    final result = [...devices];
    result.sort(
      (a, b) => switch (ranking) {
        DeviceRanking.consumption => b.dailyKwh.compareTo(a.dailyKwh),
        DeviceRanking.power => b.powerWatts.compareTo(a.powerWatts),
        DeviceRanking.switches => b.switchCount.compareTo(a.switchCount),
      },
    );
    return result.take(5).toList();
  }

  @override
  void dispose() {
    _weatherTimer?.cancel();
    _marketTimer?.cancel();
    _marketSubscription?.cancel();
    _market.dispose();
    super.dispose();
  }
}

/// Backed by `ChangeNotifierProvider` (not a raw `InheritedNotifier`) so
/// consumers can use `context.select` to react to just the fields they
/// read — e.g. `WeatherCard` doesn't rebuild on a BTC ticker update, and a
/// price tick for one market symbol doesn't rebuild the other rows. Widgets
/// that only need to call a method (no rebuild) should use [of], which
/// reads without subscribing.
class HomeScope extends StatelessWidget {
  const HomeScope({required this.controller, required this.child, super.key});

  final HomeController controller;
  final Widget child;

  static HomeController of(BuildContext context) =>
      context.read<HomeController>();

  @override
  Widget build(BuildContext context) =>
      ChangeNotifierProvider<HomeController>.value(
        value: controller,
        child: child,
      );
}
