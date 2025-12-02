import 'package:adhan/adhan.dart' as adhan;
import 'package:azan/controllers/cubits/appcubit/app_state.dart';
import 'package:azan/core/helpers/date_helper.dart';
import 'package:azan/core/helpers/dhikr_hive_helper.dart';
import 'package:azan/core/helpers/iqama_hive_helper.dart';
import 'package:azan/core/helpers/location_helper.dart';
import 'package:azan/core/models/city_option.dart';
import 'package:azan/core/models/diker.dart';
import 'package:azan/core/models/geo_location.dart';
import 'package:azan/core/models/latlng.dart';
import 'package:azan/core/models/prayer.dart';
import 'package:azan/core/services/open_weather_service.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/data/data_source/azan_data_source.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppCubit extends Cubit<AppState> {
  AppCubit(this._dio) : super(AppInitial());
  static AppCubit get(context) => BlocProvider.of(context);

  final Dio _dio;
  final AzanDataSource azanDataSource = AzanDataSourceImpl(Dio());
  Future<String?> getTodayHijriDate() async {
    emit(AppInitial());
    try {
      final now = DateTime.now();

      // صيغة التاريخ المطلوبة للـ API: DD-MM-YYYY
      final dateParam =
          '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';

      final response = await _dio.get(
        'https://api.aladhan.com/v1/gToH',
        queryParameters: {'date': dateParam},
      );

      if (response.statusCode != 200 || response.data == null) {
        return null;
      }

      final data = response.data['data'];
      final hijri = data['hijri'];

      final String day = hijri['day']; // "8"
      final String year = hijri['year']; // "1447"
      final String monthAr = hijri['month']['ar']; // "جُمادى الآخرة"

      // تبديل الاسم لو حابب الشكل اللي إنت كتبته
      final String monthName = monthAr;

      final raw = '$day $monthName $year';

      // نحول الأرقام لأرقام عربية
      final formatted = DateHelper.toArabicDigits(raw);

      // النتيجة: "٨ جمادى الثاني ١٤٤٧"
      emit(AppChanged());

      return formatted;
    } catch (e) {
      // تقدر تعمل log هنا لو حابب
      return null;
    }
  }

  final weatherService = OpenMeteoWeatherService();

  double? maxTemp;

  Future<void> loadTodayMaxTemp({
    required String country,
    required String city,
  }) async {
    emit(AppInitial());
    final maxTemp = await weatherService.fetchTodayMaxTemperature(
      city: city, // اللي المستخدم يدخله
      country: country, // أو "مصر"، بس الإنجليزي أدق للـ API
    );

    this.maxTemp = maxTemp;
    print('maxTemp: $maxTemp');
    emit(AppChanged());
  }

  adhan.PrayerTimes? prayerTimes;

  Future<LatLng?> fetchCityCoordinate(String city) async {
    if (CacheHelper.getCoordinates() == null) {
      OpenMeteoWeatherService service = OpenMeteoWeatherService(dio: _dio);

      GeoLocation? geoResponse = await service.fetchCoordinates(city: city);

      if (geoResponse == null) {
        return null;
      }
      LatLng latLng = LatLng(geoResponse!.latitude, geoResponse!.longitude);
      CacheHelper.setCoordinates(latLng);
      CacheHelper.setCity(
        CityOption(
          nameEn: city,
          nameAr: LocationHelper.findSaudiCityByName(city)!.nameAr,
          lat: latLng.latitude,
          lon: latLng.longitude,
        ),
      );
      return latLng;
    }
  }

  Future<adhan.PrayerTimes?> fetchPrayerTimesNew(
    LatLng latLng,
    DateTime time, {
    int retryCount = 0,
    bool storeToMain = false,
  }) async {
    try {
      final result = await azanDataSource.fetchPrayerTimes(latLng, time);

      if (result != null) {
        if (result.nextPrayer() == adhan.Prayer.none) {
          if (retryCount < 3) {
            return fetchPrayerTimesNew(
              latLng,
              time.add(const Duration(days: 1)),
              retryCount: retryCount + 1,
              storeToMain: storeToMain,
            );
          } else {
            return null;
          }
        }
        if (storeToMain) {
          prayerTimes = result;
        }
        return result;
      }
      return null;
    } catch (e) {
      emit(
        FetchPrayerTimesFailure(
          LocaleKeys.something_went_wrong_please_try_again.tr(),
        ),
      );
    }
  }

  Future<void> initializePrayerTimes(String city) async {
    if (CacheHelper.getCoordinates() == null) {
      await fetchCityCoordinate(city);
    }
    if (CacheHelper.getCoordinates() == null) {
      emit(
        FetchPrayerTimesFailure(
          LocaleKeys.something_went_wrong_please_try_again.tr(),
        ),
      );
      return;
    }
    List<Prayer> allPrayers = [];

    final success = await fetchPrayerTimesNew(
      CacheHelper.getCoordinates()!,
      DateTime.now(),
      storeToMain: true,
    );
    if (success != null) {
      allPrayers.addAll(_mapToPrayers(success));
      final lastPrayerTime = success.isha;

      // لو اليوم هو السادس (i==5) أو السابع (i==6) جدّول تذكير التحديث

      // نضيف buffer صغير بعد العشاء
    }
  }

  /*************  ✨ Windsurf Command ⭐  *************/
  /// Maps the given [adhan.PrayerTimes] to a list of [Prayer]
  ///
  /// The returned list will contain the following prayers in order:
  /// 1. Fajr
  /// 2. Sunrise
  /// 3. Dhuhr
  /// 4. Asr
  /// 5. Maghrib
  /// 6. Isha
  ///
  /// The [Prayer] objects in the returned list will contain the title
  /// of the prayer, its time, and the corresponding [DateTime] object.
  /*******  51c0fe4a-49d1-4cf4-972d-0db43860890e  *******/
  List<Prayer> _mapToPrayers(adhan.PrayerTimes? times) {
    return [
      Prayer(
        id: 1,
        title: LocaleKeys.fajr.tr(),
        time: times == null ? null : DateFormat.jm().format(times.fajr),
        dateTime: times?.fajr,
      ),
      Prayer(
        id: 2,
        title: LocaleKeys.sunrise.tr(),
        time: times == null ? null : DateFormat.jm().format(times.sunrise),
        dateTime: times?.sunrise,
      ),
      Prayer(
        id: 3,
        title: LocaleKeys.dhuhr.tr(),
        time: times == null ? null : DateFormat.jm().format(times.dhuhr),
        dateTime: times?.dhuhr,
      ),
      Prayer(
        id: 4,
        title: LocaleKeys.asr.tr(),
        time: times == null ? null : DateFormat.jm().format(times.asr),
        dateTime: times?.asr,
      ),
      Prayer(
        id: 5,
        title: LocaleKeys.maghrib.tr(),
        time: times == null ? null : DateFormat.jm().format(times.maghrib),
        dateTime: times?.maghrib,
      ),
      Prayer(
        id: 6,
        title: LocaleKeys.isha.tr(),
        time: times == null ? null : DateFormat.jm().format(times.isha),
        dateTime: times?.isha,
      ),
    ];
  }

  List<Prayer> get prayers => _mapToPrayers(prayerTimes);

  Future<Prayer?> get nextPrayer async {
    // fetchPrayerTimesNew(latLng, time)
    switch (prayerTimes?.nextPrayer()) {
      case adhan.Prayer.fajr:
        return prayers[0];
      case adhan.Prayer.sunrise:
        return prayers[1];
      case adhan.Prayer.dhuhr:
        return prayers[2];
      case adhan.Prayer.asr:
        return prayers[3];
      case adhan.Prayer.maghrib:
        return prayers[4];
      case adhan.Prayer.isha:
        return prayers[5];
      case adhan.Prayer.none:
        await initializePrayerTimes(CacheHelper.getCity()!.nameEn);
        return prayers[0];

      default:
        return null;
    }
  }

  List<Dhikr>? adhkarList;
  Future<void> assignAdhkar() async {
    emit(AppInitial());
    adhkarList = await DhikrHiveHelper.getAllDhikr();
    emit(AppChanged());
  }

  void toggleSlider() {
    emit(AppInitial());
    CacheHelper.setSliderOpened(!CacheHelper.getSliderOpened());
    emit(AppChanged());
  }

  String? getCountry() {
    return CacheHelper.getCountry();
  }

  String setCountry(String country) {
    CacheHelper.setCountry(country);
    return country;
  }

  String clearCountry() {
    CacheHelper.removeCountry();
    return '';
  }

  CityOption? getCity() {
    emit(AppInitial());
    emit(AppChanged());
    return CacheHelper.getCity();
  }

  void setCity(CityOption city) {
    emit(AppInitial());
    CacheHelper.setCity(city);
    emit(AppChanged());
  }

  String clearCity() {
    CacheHelper.removeCity();
    return '';
  }

  List<int>? iqamaMinutes;
  Future<void> getIqamaTime() async {
    emit(AppInitial());
    iqamaMinutes = await IqamaHiveHelper.loadIqamaMinutes(prayerCount: 6);
    emit(AppChanged());
  }

  Future<void> saveIqamaTimes() async {
    emit(saveIqamaTimesLoading());
    try {
      await IqamaHiveHelper.saveIqamaMinutes(iqamaMinutes!);
      emit(saveIqamaTimesSuccess());
    } catch (e) {
      emit(saveIqamaTimesFailure());
    }
  }

  List<Dhikr>? get todaysAdkar {
    if (adhkarList == null) return null;
    return adhkarList!
        .where((element) => element.active && element.isForDay(DateTime.now()))
        .toList();
  }
}
