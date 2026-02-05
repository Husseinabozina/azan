import 'dart:convert';

import 'package:azan/core/helpers/location_helper.dart';
import 'package:azan/core/models/daily_weather.dart';
import 'package:azan/core/models/geo_location.dart';
import 'package:azan/core/utils/extenstions.dart';
import 'package:azan/data/data/city_country_data.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class OpenMeteoWeatherService {
  OpenMeteoWeatherService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  /// ترجع درجة الحرارة العظمى لليوم الحالي (°C)
  /// بناءً على اسم المدينة والدولة.
  ///
  /// لو مفيش نتيجة أو حصل Error بترجع null.
  Future<double?> fetchTodayMaxTemperature({
    required String city,
    required String country,
  }) async {
    try {
      // 1️⃣ نجيب إحداثيات المدينة من Geocoding API
      final location = await fetchCoordinates(city: city, country: country);
      if (location == null) {
        return null;
      }

      // 2️⃣ نجيب forecast اليومي من Open-Meteo
      final response = await _dio.get(
        'https://api.open-meteo.com/v1/forecast',
        queryParameters: {
          'latitude': location.latitude,
          'longitude': location.longitude,
          'daily': 'temperature_2m_max', // العظمى بس
          'forecast_days': 1, // يوم واحد (النهاردة)
          'timezone': 'auto', // يخلي اليوم حسب توقيت المكان
        },
      );

      if (response.statusCode != 200) {
        return null;
      }

      final data = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : jsonDecode(response.data as String) as Map<String, dynamic>;

      if (data['daily'] == null) return null;

      final daily = DailyWeather.fromJson(
        data['daily'] as Map<String, dynamic>,
      );

      if (daily.temperatureMax.isEmpty) return null;

      // بما إن forecast_days = 1 → أول عنصر = النهاردة
      final double todayMax = daily.temperatureMax.first;
      return todayMax;
    } on DioException catch (e) {
      // تقدر تحط هنا logging لو عندك logger
      debugPrint(
        'OpenMeteo error: ${e.message}  statusCode: ${e.response?.statusCode}',
      );
      return null;
    } catch (e) {
      debugPrint('OpenMeteo unknown error: $e');
      return null;
    }
  }

  /// دالة داخلية: تجيب إحداثيات المدينة من Geocoding API
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
      "${cityModel?.lat.toString()}".log();
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
      first.toString().log();
      GeoLocation.fromJson(first).longitude.toString().log();
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
