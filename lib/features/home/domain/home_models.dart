class WeatherLocation {
  const WeatherLocation({
    required this.name,
    required this.latitude,
    required this.longitude,
  });
  final String name;
  final double latitude;
  final double longitude;
}

class HourlyWeatherPoint {
  const HourlyWeatherPoint({
    required this.time,
    required this.temperature,
    required this.precipitationProbability,
    required this.weatherCode,
  });
  final DateTime time;
  final double temperature;
  final int precipitationProbability;
  final int weatherCode;
}

class WeatherSnapshot {
  const WeatherSnapshot({
    required this.location,
    required this.temperature,
    required this.feelsLike,
    required this.windSpeed,
    required this.weatherCode,
    required this.minTemperature,
    required this.maxTemperature,
    required this.updatedAt,
    required this.hourly,
  });
  final WeatherLocation location;
  final double temperature;
  final double feelsLike;
  final double windSpeed;
  final int weatherCode;
  final double minTemperature;
  final double maxTemperature;
  final DateTime updatedAt;
  final List<HourlyWeatherPoint> hourly;

  String get condition => switch (weatherCode) {
    0 => 'Klar',
    1 || 2 => 'Teilweise bewölkt',
    3 => 'Bedeckt',
    45 || 48 => 'Nebel',
    >= 51 && <= 67 => 'Nieselregen',
    >= 71 && <= 77 => 'Schnee',
    >= 80 && <= 82 => 'Regenschauer',
    _ => 'Gewitter',
  };
}

enum MarketSymbol { nq, es, btc }

extension MarketSymbolInfo on MarketSymbol {
  String get label => switch (this) {
    MarketSymbol.nq => 'NQ',
    MarketSymbol.es => 'ES',
    MarketSymbol.btc => 'BTC',
  };
  String get name => switch (this) {
    MarketSymbol.nq => 'Nasdaq 100 Index',
    MarketSymbol.es => 'S&P 500 Index',
    MarketSymbol.btc => 'Bitcoin',
  };
  String get currency => this == MarketSymbol.btc ? 'USD' : 'Punkte';
}

class MarketChartPoint {
  const MarketChartPoint(this.time, this.value);
  final DateTime time;
  final double value;
}

class MarketQuote {
  const MarketQuote({
    required this.symbol,
    required this.price,
    required this.change,
    required this.changePercent,
    required this.updatedAt,
    required this.points,
    required this.isLive,
  });
  final MarketSymbol symbol;
  final double price;
  final double change;
  final double changePercent;
  final DateTime updatedAt;
  final List<MarketChartPoint> points;
  final bool isLive;
}
