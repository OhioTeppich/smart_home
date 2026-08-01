import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../application/home_controller.dart';
import '../../domain/home_models.dart';
import 'home_card.dart';

/// What `WeatherCard` needs out of `HomeController`, compared by value via
/// `context.select` — without this, any unrelated controller notification
/// (e.g. the BTC ticker firing many times a minute) would rebuild the
/// whole weather card too.
class _WeatherView extends Equatable {
  const _WeatherView({
    required this.snapshot,
    required this.loading,
    required this.error,
  });

  final WeatherSnapshot? snapshot;
  final bool loading;
  final String? error;

  @override
  List<Object?> get props => [snapshot, loading, error];
}

class WeatherCard extends StatefulWidget {
  const WeatherCard({super.key});

  @override
  State<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard> {
  final ScrollController _hourlyController = ScrollController();
  String? _centeredWeather;

  @override
  void dispose() {
    _hourlyController.dispose();
    super.dispose();
  }

  static const double _hourItemExtent = 58.0;

  bool _onScrollEnd(ScrollNotification notification, int itemCount) {
    if (notification is! ScrollEndNotification ||
        !_hourlyController.hasClients ||
        itemCount == 0) {
      return false;
    }
    final maxExtent = _hourlyController.position.maxScrollExtent;
    final offset = _hourlyController.offset;
    final index = (offset / _hourItemExtent).round().clamp(0, itemCount - 1);
    final target = (index * _hourItemExtent).clamp(0.0, maxExtent);
    if ((target - offset).abs() > 0.5) {
      _hourlyController.animateTo(
        target,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
    return false;
  }

  void _centerCurrentHour(WeatherSnapshot weather) {
    if (_centeredWeather == weather.updatedAt.toIso8601String() ||
        weather.hourly.isEmpty) {
      return;
    }
    final now = DateTime.now();
    final currentPoint = weather.hourly.reduce(
      (a, b) =>
          a.time.difference(now).inMinutes.abs() <
              b.time.difference(now).inMinutes.abs()
          ? a
          : b,
    );
    final index = weather.hourly.indexOf(currentPoint);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hourlyController.hasClients) return;
      _hourlyController.jumpTo(
        (index * 58.0).clamp(0.0, _hourlyController.position.maxScrollExtent),
      );
      if (mounted) {
        setState(() => _centeredWeather = weather.updatedAt.toIso8601String());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final view = context.select<HomeController, _WeatherView>(
      (controller) => _WeatherView(
        snapshot: controller.weatherSnapshot,
        loading: controller.loadingWeather,
        error: controller.weatherError,
      ),
    );
    final weather = view.snapshot;
    return HomeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HomeCardTitle(
            icon: Icons.cloud_outlined,
            title: 'Wetter heute',
            trailing: 'Live',
          ),
          const SizedBox(height: 16),
          if (weather == null)
            Text(
              view.loading
                  ? 'Wetter wird geladen …'
                  : (view.error ?? 'Kein Wetter verfügbar'),
              style: const TextStyle(color: AppColors.muted),
            )
          else ...[
            Row(
              children: [
                Icon(
                  _weatherIcon(weather.weatherCode),
                  size: 42,
                  color: AppColors.blueDark,
                ),
                const SizedBox(width: 12),
                Text(
                  '${weather.temperature.round()}°',
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        weather.condition,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        weather.location.name,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Gefühlt ${weather.feelsLike.round()}°  ·  ${weather.minTemperature.round()}° / ${weather.maxTemperature.round()}°  ·  Wind ${weather.windSpeed.round()} km/h',
              style: const TextStyle(color: AppColors.muted, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.wb_twilight_rounded,
                  size: 14,
                  color: AppColors.muted,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatTime(weather.sunrise),
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
                const Text(
                  '  ·  ',
                  style: TextStyle(color: AppColors.muted, fontSize: 12),
                ),
                const Icon(
                  Icons.nights_stay_rounded,
                  size: 14,
                  color: AppColors.muted,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatTime(weather.sunset),
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
                const Text(
                  '  ·  ',
                  style: TextStyle(color: AppColors.muted, fontSize: 12),
                ),
                const Icon(
                  Icons.water_drop_rounded,
                  size: 14,
                  color: AppColors.muted,
                ),
                const SizedBox(width: 4),
                Text(
                  '${weather.humidity}%',
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) {
                _centerCurrentHour(weather);
                final now = DateTime.now();
                final currentIndex = weather.hourly.isEmpty
                    ? -1
                    : weather.hourly.indexOf(
                        weather.hourly.reduce(
                          (a, b) =>
                              a.time.difference(now).inMinutes.abs() <
                                  b.time.difference(now).inMinutes.abs()
                              ? a
                              : b,
                        ),
                      );
                return SizedBox(
                  height: 68,
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (notification) =>
                        _onScrollEnd(notification, weather.hourly.length),
                    child: ListView.builder(
                      controller: _hourlyController,
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: (constraints.maxWidth / 2 - 29).clamp(
                          0.0,
                          double.infinity,
                        ),
                      ),
                      itemCount: weather.hourly.length,
                      itemBuilder: (_, i) {
                        final point = weather.hourly[i];
                        final current = i == currentIndex;
                        return SizedBox(
                          width: 58,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            decoration: BoxDecoration(
                              color: current
                                  ? AppColors.blue.withOpacity(.18)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: current
                                  ? Border.all(
                                      color: AppColors.blueDark.withOpacity(
                                        .55,
                                      ),
                                      width: 1.5,
                                    )
                                  : null,
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      current
                                          ? 'JETZT'
                                          : '${point.time.hour}:00',
                                      style: TextStyle(
                                        fontSize: current ? 9 : 10,
                                        fontWeight: FontWeight.w900,
                                        color: current
                                            ? AppColors.blueDark
                                            : AppColors.muted,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${point.temperature.round()}°',
                                  style: TextStyle(
                                    fontSize: current ? 16 : 14,
                                    fontWeight: FontWeight.w900,
                                    color: current
                                        ? AppColors.blueDark
                                        : AppColors.ink,
                                  ),
                                ),
                                if (point.precipitationProbability > 0)
                                  Text(
                                    '${point.precipitationProbability}%',
                                    style: const TextStyle(
                                      fontSize: 9,
                                      color: AppColors.blueDark,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

String _formatTime(DateTime time) =>
    '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

IconData _weatherIcon(int code) => switch (code) {
  0 => Icons.wb_sunny_rounded,
  1 || 2 => Icons.cloud_queue_rounded,
  3 => Icons.cloud_rounded,
  >= 71 && <= 77 => Icons.ac_unit_rounded,
  _ => Icons.grain_rounded,
};
