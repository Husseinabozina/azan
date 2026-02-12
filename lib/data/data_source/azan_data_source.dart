import 'package:adhan/adhan.dart';
import 'package:azan/core/models/geo_location.dart';
import 'package:azan/core/models/latlng.dart';
import 'package:azan/core/services/open_weather_service.dart';
import 'package:azan/core/utils/extenstions.dart';
import 'package:dio/dio.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
// import 'package:prayers_times/prayers_times.dart' as pr;

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
    // "_selectCalculationMethod lat lang ${lat} ${lng}".log();
    // // try {
    // try {
    //   await placemarkFromCoordinates(lat, lng);
    // } catch (e) {
    //   ' erroooooroooooo ${e}'.log();
    // }
    return CalculationMethod.umm_al_qura; // 'SA';

    //   switch (countryCode) {
    //     case 'EG': // مصر - الأزهر الشريف
    //       return CalculationMethod.egyptian;
    //     case 'SA': // السعودية - أم القرى
    //       return CalculationMethod.umm_al_qura;
    //     case 'KW': // الكويت
    //       return CalculationMethod.kuwait;
    //     // case 'QA': // قطر
    //     //   return CalculationMethod.qatar;
    //     // case 'AE': // الإمارات
    //     //   return CalculationMethod.dubai;
    //     // case 'PK': // باكستان
    //     //   return CalculationMethod.karachi;
    //     // case 'MY': // ماليزيا
    //     //   return CalculationMethod.singapore;
    //     // case 'TR': // تركيا
    //     //   return CalculationMethod.turkey;
    //     // case 'IR': // إيران
    //     //   return CalculationMethod.tehran;
    //     // case 'US': // أمريكا
    //     // case 'CA': // كندا
    //     //   return CalculationMethod.north_america;
    //     // case 'SG': // سنغافورة
    //     //   return CalculationMethod.singapore;
    //     // case 'YE': // اليمن
    //     // case 'OM': // عمان
    //     //   return CalculationMethod.moon_sighting_committee;
    //     default: // باقي الدول
    //       return CalculationMethod.muslim_world_league;
    //   }
    // } catch (e) {
    //   'errorerrorerrorerrorerrorerror $e'.log();
    //   return CalculationMethod.muslim_world_league;
    // }
  }

  @override
  Future<PrayerTimes?> fetchPrayerTimes(LatLng latLng, DateTime time) async {
    try {
      // Coordinates coordinates = Coordinates(21.1959, 72.7933);

      // Specify the calculation parameters for prayer times

      // Create a PrayerTimes instance for the specified location

      final params = (await _selectCalculationMethod(
        latLng.latitude,
        latLng.longitude,
      )).getParameters();

      // params.madhab = pr.PrayerMadhab.shafi;
      final nyDate = DateComponents(
        time.year,
        time.month,
        time.day,
      ); //2025, 4, 20);

      'prayerTimes prayerTimes prayerTimes prayerTimes ${PrayerTimes(Coordinates(latLng.latitude, latLng.longitude), nyDate, params).asr}'
          .log();
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
