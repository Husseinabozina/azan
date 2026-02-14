// import 'dart:convert';

// import 'package:azan/core/helpers/location_helper.dart';
// import 'package:azan/core/models/daily_weather.dart';
// import 'package:azan/core/models/geo_location.dart';
// import 'package:azan/core/utils/extenstions.dart';
// import 'package:azan/data/data/city_country_data.dart';
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';

// class OpenMeteoWeatherService {
//   OpenMeteoWeatherService({Dio? dio}) : _dio = dio ?? Dio();

//   final Dio _dio;

//   /// ترجع درجة الحرارة العظمى لليوم الحالي (°C)
//   /// بناءً على اسم المدينة والدولة.
//   ///
//   /// لو مفيش نتيجة أو حصل Error بترجع null.
//   Future<double?> fetchTodayMaxTemperature({
//     required String city,
//     required String country,
//   }) async {
//     try {
//       // 1️⃣ نجيب إحداثيات المدينة من Geocoding API
//       final location = await fetchCoordinates(city: city, country: country);
//       if (location == null) {
//         return null;
//       }

//       // 2️⃣ نجيب forecast اليومي من Open-Meteo
//       final response = await _dio.get(
//         'https://api.open-meteo.com/v1/forecast',
//         queryParameters: {
//           'latitude': location.latitude,
//           'longitude': location.longitude,
//           'daily': 'temperature_2m_max', // العظمى بس
//           'forecast_days': 1, // يوم واحد (النهاردة)
//           'timezone': 'auto', // يخلي اليوم حسب توقيت المكان
//         },
//       );

//       if (response.statusCode != 200) {
//         return null;
//       }

//       final data = response.data is Map<String, dynamic>
//           ? response.data as Map<String, dynamic>
//           : jsonDecode(response.data as String) as Map<String, dynamic>;

//       if (data['daily'] == null) return null;

//       final daily = DailyWeather.fromJson(
//         data['daily'] as Map<String, dynamic>,
//       );

//       if (daily.temperatureMax.isEmpty) return null;

//       // بما إن forecast_days = 1 → أول عنصر = النهاردة
//       final double todayMax = daily.temperatureMax.first;
//       return todayMax;
//     } on DioException catch (e) {
//       // تقدر تحط هنا logging لو عندك logger
//       debugPrint(
//         'OpenMeteo error: ${e.message}  statusCode: ${e.response?.statusCode}',
//       );
//       return null;
//     } catch (e) {
//       debugPrint('OpenMeteo unknown error: $e');
//       return null;
//     }
//   }

//   /// دالة داخلية: تجيب إحداثيات المدينة من Geocoding API
//   Future<GeoLocation?> fetchCoordinates({
//     required String city,
//     String? country,
//   }) async {
//     try {
//       // final response = await _dio.get(
//       //   'https://geocoding-api.open-meteo.com/v1/search',
//       //   queryParameters: {
//       //     'name': city,
//       //     'count': 1, // أول نتيجة بس
//       //     'language': 'ar', // يرجع أسماء بالعربي لو متاحة
//       //     'format': 'json',
//       //   },
//       // );

//       // if (response.statusCode != 200) {
//       //   debugPrint(
//       //     'Geocoding error: ${response.data}. statusCode: ${response.statusCode}',
//       //   );
//       //   return null;
//       // }

//       // final data = response.data is Map<String, dynamic>
//       //     ? response.data as Map<String, dynamic>
//       //     : jsonDecode(response.data as String) as Map<String, dynamic>;

//       // final results = data['results'] as List<dynamic>?;

//       // if (results == null || results.isEmpty) {
//       //   return null;
//       // }
//       var cityModel = LocationHelper.findSaudiCityByName(city);
//       if (cityModel == null) {
//         return null;
//       }

//       final results = {
//         'latitude': cityModel.lat,
//         'longitude': cityModel.lon,
//         'name': cityModel.nameAr,
//         'country': country,
//       };

//       final first = results as Map<String, dynamic>;
//       return GeoLocation.fromJson(first);
//     } on DioException catch (e) {
//       debugPrint(
//         'Geocoding error: ${e.message},statusCode: ${e.response?.statusCode}',
//       );
//       return null;
//     } catch (e) {
//       debugPrint('Geocoding unknown error: $e');
//       return null;
//     }
//   }
// }

import 'dart:convert';
import 'package:azan/core/helpers/location_helper.dart';
import 'package:azan/core/models/geo_location.dart';
import 'package:azan/core/models/weather_day.dart';
import 'package:azan/core/utils/extenstions.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class OpenMeteoWeatherService {
  OpenMeteoWeatherService({required Dio dio}) : _dio = dio;

  final Dio _dio;

  static const int maxForecastDays = 16;

  List<double?> _toDoubleListNullable(dynamic v) {
    final list = (v is List) ? v : const [];
    return list.map<double?>((e) => (e is num) ? e.toDouble() : null).toList();
  }

  List<int?> _toIntListNullable(dynamic v) {
    final list = (v is List) ? v : const [];
    return list.map<int?>((e) => (e is num) ? e.toInt() : null).toList();
  }

  List<String> _toStringList(dynamic v) {
    final list = (v is List) ? v : const [];
    return list.map((e) => e.toString()).toList();
  }

  Future<WeatherForecast?> fetchMaxForecast({
    required String city,
    required String country,
    int morningHour = 8,
    int nightHour = 20,
    int days = maxForecastDays,
  }) async {
    try {
      final location = await fetchCoordinates(city: city, country: country);
      if (location == null) return null;

      final safeDays = days.clamp(1, maxForecastDays);

      final response = await _dio.get(
        'https://api.open-meteo.com/v1/forecast',
        queryParameters: {
          'latitude': location.latitude,
          'longitude': location.longitude,

          // daily for max/min
          'daily': 'temperature_2m_max,temperature_2m_min,weather_code',

          // hourly to pick morning/night
          'hourly': 'temperature_2m',

          'forecast_days': safeDays,
          'timezone': 'auto',
        },
      );

      if (response.statusCode != 200) {
        return null;
      }

      final data = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : jsonDecode(response.data as String) as Map<String, dynamic>;

      final daily = data['daily'] as Map<String, dynamic>?;
      final hourly = data['hourly'] as Map<String, dynamic>?;

      if (daily == null || hourly == null) return null;

      final timezone = (data['timezone'] as String?) ?? 'auto';
      final utcOffsetSeconds =
          (data['utc_offset_seconds'] as num?)?.toInt() ?? 0;
      final dailyDates = _toStringList(daily['time']);
      final maxList = _toDoubleListNullable(daily['temperature_2m_max']);
      final minList = _toDoubleListNullable(daily['temperature_2m_min']);
      final codeList = _toIntListNullable(daily['weather_code']);

      final hourlyTimes = _toStringList(hourly['time']);
      final hourlyTemps = _toDoubleListNullable(hourly['temperature_2m']);

      // final List<int?> codeList = (daily['weather_code'] as List)
      //     .map((e) => (e != null ? (e as num).toInt() : null))
      //     .toList();
      final Map<String, double> tempByTime = {};
      for (int i = 0; i < hourlyTimes.length && i < hourlyTemps.length; i++) {
        final t = hourlyTemps[i];
        if (t != null) tempByTime[hourlyTimes[i]] = t;
      }

      double? pickAt(String date, int hour) {
        final hh = hour.toString().padLeft(2, '0');
        final key = '${date}T$hh:00'; // ✅ لازم T
        final direct = tempByTime[key];
        if (direct != null) return direct;

        final prevH = (hour - 1).clamp(0, 23);
        final nextH = (hour + 1).clamp(0, 23);

        final prevKey = '${date}T${prevH.toString().padLeft(2, '0')}:00';
        final nextKey = '${date}T${nextH.toString().padLeft(2, '0')}:00';
        return tempByTime[prevKey] ?? tempByTime[nextKey];
      }

      final daysOut = <WeatherDay>[];
      final n = dailyDates.length;

      for (int i = 0; i < n; i++) {
        final date = dailyDates[i];

        final max = (i < maxList.length) ? maxList[i] : null;
        final min = (i < minList.length) ? minList[i] : null;

        if (max == null || min == null) {
          // skip this day to avoid crash / fake values
          continue;
        }

        daysOut.add(
          WeatherDay(
            date: date,
            max: max,
            min: min,
            morning: pickAt(date, morningHour),
            night: pickAt(date, nightHour),
            weatherCode: (i < codeList.length) ? codeList[i] : null,
          ),
        );
      }

      return WeatherForecast(
        timezone: timezone,
        utcOffsetSeconds: utcOffsetSeconds,
        fetchedAtMs: DateTime.now().millisecondsSinceEpoch,
        days: daysOut,
      );
    } on DioException catch (e) {
      return null;
    } catch (e) {
      return null;
    }
  }

  /// نفس دالتك (Offline city list)
  Future<GeoLocation?> fetchCoordinates({
    required String city,
    String? country,
  }) async {
    try {
      // final response = await _dio.get(
      //   'https://geocoding-api.open-meteo.com/v1/search',
      //   queryParameters: {
      //     'name': city,
      //     'count': 1, // أول نتيجة بس
      //     'language': 'ar', // يرجع أسماء بالعربي لو متاحة
      //     'format': 'json',
      //   },
      // );

      // if (response.statusCode != 200) {
      //   debugPrint(
      //     'Geocoding error: ${response.data}. statusCode: ${response.statusCode}',
      //   );
      //   return null;
      // }

      // final data = response.data is Map<String, dynamic>
      //     ? response.data as Map<String, dynamic>
      //     : jsonDecode(response.data as String) as Map<String, dynamic>;

      // final results = data['results'] as List<dynamic>?;

      // if (results == null || results.isEmpty) {
      //   return null;
      // }
      var cityModel = LocationHelper.findSaudiCityByName(city);
      if (cityModel == null) {
        return null;
      }

      final results = {
        'latitude': cityModel.lat,
        'longitude': cityModel.lon,
        'name': cityModel.nameAr,
        'country': country,
      };

      final first = results as Map<String, dynamic>;
      return GeoLocation.fromJson(first);
    } on DioException catch (e) {
      debugPrint(
        'Geocoding error: ${e.message},statusCode: ${e.response?.statusCode}',
      );
      return null;
    } catch (e) {
      debugPrint('Geocoding unknown error: $e');
      return null;
    }
  }
}
