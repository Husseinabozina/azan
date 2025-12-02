import 'package:adhan/adhan.dart';
import 'package:azan/core/models/geo_location.dart';
import 'package:azan/core/models/latlng.dart';
import 'package:azan/core/services/open_weather_service.dart';
import 'package:dio/dio.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

abstract class AzanDataSource {
  Future<PrayerTimes?> fetchPrayerTimes(LatLng latLng, DateTime time);
}

class AzanDataSourceImpl extends AzanDataSource {
  Dio dio;

  AzanDataSourceImpl(this.dio);
  Future<CalculationMethod> _selectCalculationMethod(
    double lat,
    double lng,
  ) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      final countryCode = placemarks.first.isoCountryCode?.toUpperCase() ?? '';
      print('countryCode: $countryCode');

      switch (countryCode) {
        case 'EG': // مصر - الأزهر الشريف
          return CalculationMethod.egyptian;
        case 'SA': // السعودية - أم القرى
          return CalculationMethod.umm_al_qura;
        case 'KW': // الكويت
          return CalculationMethod.kuwait;
        // case 'QA': // قطر
        //   return CalculationMethod.qatar;
        // case 'AE': // الإمارات
        //   return CalculationMethod.dubai;
        // case 'PK': // باكستان
        //   return CalculationMethod.karachi;
        // case 'MY': // ماليزيا
        //   return CalculationMethod.singapore;
        // case 'TR': // تركيا
        //   return CalculationMethod.turkey;
        // case 'IR': // إيران
        //   return CalculationMethod.tehran;
        // case 'US': // أمريكا
        // case 'CA': // كندا
        //   return CalculationMethod.north_america;
        // case 'SG': // سنغافورة
        //   return CalculationMethod.singapore;
        // case 'YE': // اليمن
        // case 'OM': // عمان
        //   return CalculationMethod.moon_sighting_committee;
        default: // باقي الدول
          return CalculationMethod.muslim_world_league;
      }
    } catch (e) {
      return CalculationMethod.muslim_world_league;
    }
  }

  @override
  Future<PrayerTimes?> fetchPrayerTimes(LatLng latLng, DateTime time) async {
    try {
      final CalculationMethod f = await _selectCalculationMethod(
        latLng.latitude,
        latLng.longitude,
      );
      f.toString();

      final params = (await _selectCalculationMethod(
        latLng.latitude,
        latLng.longitude,
      )).getParameters();

      params.madhab = Madhab.shafi;
      final nyDate = DateComponents(
        time.year,
        time.month,
        time.day,
      ); //2025, 4, 20);

      return PrayerTimes(
        Coordinates(latLng.latitude, latLng.longitude),
        nyDate,
        params,
      );
    } catch (e) {
      rethrow;
    }
  }
}
