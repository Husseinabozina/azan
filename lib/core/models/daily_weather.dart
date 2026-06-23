class DailyWeather {
  final List<String> time; // تواريخ الأيام (yyyy-MM-dd)
  final List<double> temperatureMax; // العظمى لكل يوم

  DailyWeather({required this.time, required this.temperatureMax});

  factory DailyWeather.fromJson(Map<String, dynamic> json) {
    final times = (json['time'] as List).cast<String>();
    final temps = (json['temperature_2m_max'] as List)
        .map((e) => (e as num).toDouble())
        .toList();

    return DailyWeather(time: times, temperatureMax: temps);
  }
}
