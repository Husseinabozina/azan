class WeatherDay {
  final String date; // yyyy-MM-dd
  final double max;
  final double min;
  final double? morning;
  final double? night;

  final int? weatherCode; // ✅ جديد

  WeatherDay({
    required this.date,
    required this.max,
    required this.min,
    this.morning,
    this.night,
    this.weatherCode,
  });

  factory WeatherDay.fromJson(Map<String, dynamic> json) {
    return WeatherDay(
      date: json['date'] as String,
      max: (json['max'] as num).toDouble(),
      min: (json['min'] as num).toDouble(),
      morning: (json['morning'] as num?)?.toDouble(),
      night: (json['night'] as num?)?.toDouble(),
      weatherCode: (json['weatherCode'] as num?)?.toInt(), // ✅
    );
  }

  Map<String, dynamic> toJson() => {
    'date': date,
    'max': max,
    'min': min,
    'morning': morning,
    'night': night,
    'weatherCode': weatherCode, // ✅
  };
}

class WeatherForecast {
  final String timezone; // مثلا Asia/Riyadh
  final int utcOffsetSeconds;
  final int fetchedAtMs;
  final List<WeatherDay> days;

  const WeatherForecast({
    required this.timezone,
    required this.utcOffsetSeconds,
    required this.fetchedAtMs,
    required this.days,
  });

  Map<String, dynamic> toJson() => {
    'timezone': timezone,
    'utcOffsetSeconds': utcOffsetSeconds,
    'fetchedAtMs': fetchedAtMs,
    'days': days.map((e) => e.toJson()).toList(),
  };

  factory WeatherForecast.fromJson(Map<String, dynamic> json) =>
      WeatherForecast(
        timezone: json['timezone'] as String,
        utcOffsetSeconds: (json['utcOffsetSeconds'] as num).toInt(),
        fetchedAtMs: (json['fetchedAtMs'] as num).toInt(),
        days: (json['days'] as List)
            .map((e) => WeatherDay.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class WeatherCacheKeys {
  static const forecastJson = 'om_forecast_json';
  static const lastSyncYmd =
      'om_weather_last_sync_ymd'; // yyyy-MM-dd (بتوقيت المدينة)
  static const lastCityKey =
      'om_weather_last_city_key'; // lat,lon أو اسم المدينة
}
