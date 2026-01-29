import 'dart:convert';
import 'dart:math';

import 'package:adhan/adhan.dart' as adhan;
import 'package:azan/controllers/cubits/appcubit/app_state.dart';
import 'package:azan/core/helpers/date_helper.dart';
import 'package:azan/core/helpers/dhikr_hive_helper.dart';
import 'package:azan/core/helpers/iqama_hive_helper.dart';
import 'package:azan/core/helpers/localizationHelper.dart';
import 'package:azan/core/helpers/location_helper.dart';
import 'package:azan/core/helpers/prayer_duration_hive_helper.dart';
import 'package:azan/core/models/city_option.dart';
import 'package:azan/core/models/diker.dart';
import 'package:azan/core/models/geo_location.dart';
import 'package:azan/core/models/latlng.dart';
import 'package:azan/core/models/next_Iqama.dart';
import 'package:azan/core/models/prayer.dart';
import 'package:azan/core/services/open_weather_service.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/core/utils/extenstions.dart';
import 'package:azan/data/data_source/azan_data_source.dart';
import 'package:azan/gen/assets.gen.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:azan/views/home/home_screen_landscape.dart';
import 'package:azan/views/home/home_screen_mobile.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:typed_data';
import 'dart:io' show gzip;

class AppCubit extends Cubit<AppState> {
  AppCubit(this._dio) : super(AppInitial()) {
    _loadUiRotation();
  }
  int uiQuarterTurns = 0; // 0..3

  Future<void> _loadUiRotation() async {
    final saved = CacheHelper.get(key: 'ui_qt');
    final v = (saved is int) ? saved : 0;
    uiQuarterTurns = ((v % 4) + 4) % 4;
    emit(UiRotationChanged(uiQuarterTurns));
  }

  Future<void> setUiQuarterTurns(int qt) async {
    final v = ((qt % 4) + 4) % 4;
    uiQuarterTurns = v;
    await CacheHelper.save(key: 'ui_qt', value: v);
    emit(UiRotationChanged(v));
  }

  /// زر "Portrait / Landscape" اللي انت عايزه
  Future<void> togglePortraitLandscapeUi() async {
    final next = (uiQuarterTurns == 0) ? 1 : 0;
    debugPrint('TOGGLE: before=$uiQuarterTurns next=$next');
    await setUiQuarterTurns(next);
    debugPrint('TOGGLE: after=$uiQuarterTurns');
  }

  Future<void> resetUiRotation() async => setUiQuarterTurns(0);

  static AppCubit get(context) => BlocProvider.of(context);

  final Dio _dio;
  final AzanDataSource azanDataSource = AzanDataSourceImpl(Dio());

  HomeScreenMobileState? homeScreenMobile;
  HomeScreenLandscapeState? homeScreenLandscape;
  String? hijriDate;

  Future<String?> getTodayHijriDate(BuildContext context) async {
    emit(AppInitial());

    try {
      final now = DateTime.now();

      final dateParam =
          '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';

      debugPrint('getTodayHijriDate -> dateParam = $dateParam');

      final response = await _dio.get(
        'https://api.aladhan.com/v1/gToH',

        queryParameters: {'date': dateParam},

        options: Options(
          responseType: ResponseType.json,
          headers: {
            'Accept': 'application/json',

            'Accept-Encoding': 'gzip, deflate',
          },
        ),
      );
      debugPrint('sssss');
      debugPrint(
        'Hijri status = ${response.statusCode}, data type = ${response.data.runtimeType}',
      );

      if (response.statusCode != 200 || response.data == null) {
        return null;
      }

      Map<String, dynamic> decoded;

      final raw = response.data;

      if (raw is Map<String, dynamic>) {
        decoded = raw;
      } else if (raw is String) {
        // لو لأي سبب رجع String
        decoded = jsonDecode(raw) as Map<String, dynamic>;
      } else {
        debugPrint('Unexpected hijri response type: ${raw.runtimeType}');
        return null;
      }

      final data = decoded['data'] as Map<String, dynamic>;
      final hijri = data['hijri'] as Map<String, dynamic>;

      final String day = hijri['day']; // "20"
      final String year = hijri['year']; // "1447"

      final String monthName = context.locale.languageCode == 'ar'
          ? hijri['month']['ar']
          : hijri['month']['en'];

      final rawText = '$day $monthName $year';

      final formatted = LocalizationHelper.isArAndArNumberEnable(context)
          ? DateHelper.toArabicDigits(rawText)
          : DateHelper.toWesternDigits(rawText);

      debugPrint('Hijri final formatted = $formatted');

      emit(AppChanged());
      hijriDate = formatted;
      return formatted;
    } on DioException catch (e, st) {
      debugPrint('DioException in getTodayHijriDate: $e');
      debugPrint('Response status: ${e.response?.statusCode}');
      debugPrint('Raw data: ${e.response?.data}');
      debugPrint('Stack: $st');
      return null;
    } on FormatException catch (e, st) {
      debugPrint('JSON FormatException in getTodayHijriDate: $e');
      debugPrint('Stack: $st');
      return null;
    } catch (e, st) {
      debugPrint('Unknown error in getTodayHijriDate: $e');
      debugPrint('Stack: $st');
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

  final Connectivity _connectivity = Connectivity();

  Future<bool> get _hasConnection async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  bool? connectivity;
  void checkConnectivity() {
    'start  checkConnectivity'.log();
    _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> result,
    ) {
      if (result.contains(ConnectivityResult.none)) {
        'result.contains(ConnectivityResult.none)'.log();
        connectivity = false;

        emit(AppInitial());
      } else {
        '} else {'.log();
        connectivity = true;

        emit(AppChanged());
      }
    });
  }

  Future<LatLng?> fetchCityCoordinate(String city) async {
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

  bool cityChanged = false;

  void assignCityChanged(bool value) {
    cityChanged = true;
  }

  Future<void> initializePrayerTimes({
    String? city,
    required BuildContext context,
  }) async {
    if (!await _hasConnection) {
      emit(FetchPrayerTimesFailure("لا يوجد انترنت"));
      return;
    }

    emit(FetchPrayerTimesLoading());
    if (cityChanged) {
      await fetchCityCoordinate(city!);
      cityChanged = false;
    }
    if (CacheHelper.getCoordinates() == null && city != null) {
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
      allPrayers.addAll(_mapToPrayers(success, context: context));
      final lastPrayerTime = success.isha;

      emit(FetchPrayerTimesSuccess());

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
  String _time12(DateTime prayerTime, BuildContext context) {
    return LocalizationHelper.isArAndArNumberEnable(context)
        ? DateFormat.jm(CacheHelper.getLang()).format(prayerTime)
        : DateFormat.jm('en').format(prayerTime);
  }

  String _time24(DateTime prayerTime, BuildContext context) {
    return LocalizationHelper.isArAndArNumberEnable(context)
        ? DateFormat('HH:mm', CacheHelper.getLang()).format(prayerTime)
        : DateFormat('HH:mm', 'en').format(prayerTime);
  }

  List<Prayer> _mapToPrayers(
    adhan.PrayerTimes? times, {
    required BuildContext context,
  }) {
    return [
      Prayer(
        id: 1,
        title: LocaleKeys.fajr.tr(),
        time: times == null ? null : _time12(times.fajr, context),
        dateTime: times?.fajr,
        time24: times == null ? null : _time24(times.fajr, context),
      ),
      Prayer(
        id: 2,
        title: LocaleKeys.sunrise.tr(),
        time: times == null ? null : _time12(times.sunrise, context),
        dateTime: times?.sunrise,
        time24: times == null ? null : _time24(times.sunrise, context),
      ),
      Prayer(
        id: 3,
        title: DateHelper.isFriday()
            ? LocaleKeys.friday.tr()
            : LocaleKeys.dhuhr.tr(),
        time: times == null ? null : _time12(times.dhuhr, context),
        dateTime: times?.dhuhr,
        time24: times == null ? null : _time24(times.dhuhr, context),
      ),
      Prayer(
        id: 4,
        title: LocaleKeys.asr.tr(),
        time: times == null ? null : _time12(times.asr, context),
        dateTime: times?.asr,
        time24: times == null ? null : _time24(times.asr, context),
      ),
      Prayer(
        id: 5,
        title: LocaleKeys.maghrib.tr(),
        time: times == null ? null : _time12(times.maghrib, context),
        dateTime: times?.maghrib,
        time24: times == null ? null : _time24(times.maghrib, context),
      ),
      Prayer(
        id: 6,
        title: LocaleKeys.isha.tr(),
        time: times == null ? null : _time12(times.isha, context),
        dateTime: times?.isha,
        time24: times == null ? null : _time24(times.isha, context),
      ),
    ];
  }

  List<Prayer> prayers(BuildContext context) =>
      _mapToPrayers(prayerTimes, context: context);

  Future<Prayer?> nextPrayer(context) async {
    // fetchPrayerTimesNew(latLng, time)
    switch (prayerTimes?.nextPrayer()) {
      case adhan.Prayer.fajr:
        return prayers(context)[0];
      case adhan.Prayer.sunrise:
        return prayers(context)[1];
      case adhan.Prayer.dhuhr:
        return prayers(context)[2];
      case adhan.Prayer.asr:
        return prayers(context)[3];
      case adhan.Prayer.maghrib:
        return prayers(context)[4];
      case adhan.Prayer.isha:
        return prayers(context)[5];
      case adhan.Prayer.none:
        await initializePrayerTimes(
          city: CacheHelper.getCity()!.nameEn,
          context: context,
        );
        return prayers(context)[0];

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
    if (DateHelper.isFriday() && iqamaMinutes != null) {
      iqamaMinutes![2] = CacheHelper.getFridayTime();
    }
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

  Future<void> savePrayerDurations(List<int> prayersDuration) async {
    emit(savePrayerDurationLoading());
    try {
      await PrayerDurationHiveHelper.savePrayerDurations(prayersDuration);
      emit(savePrayerDurationSuccess());
    } catch (e) {
      emit(savePrayerDurationFailure());
    }
  }

  List<int>? prayersDuration;

  Future<void> getPrayerDurations() async {
    emit(AppInitial());
    prayersDuration = await PrayerDurationHiveHelper.loadPrayerDurations(
      prayerCount: 6,
    );
    emit(AppChanged());
  }

  int? currentPrayerDuration;
  int getCurrentPrayerDuraion() {
    currentPrayerDuration = prayersDuration![currentPrayer!.id - 1];
    return currentPrayerDuration!;
  }

  List<Dhikr>? get todaysAdkar {
    if (adhkarList == null) return null;
    return adhkarList!
        .where((element) => element.active && element.isForDay(DateTime.now()))
        .toList();
  }

  String get getAzanSoundSource {
    return CacheHelper.getIsAzanAppTheme()
        ? Assets.sounds.alarmSound
        : Assets.sounds.azan;
  }

  String get getIqamaSoundSource {
    return CacheHelper.getIsIqamaAppTheme()
        ? Assets.sounds.alarmSound
        : Assets.sounds.iqama;
  }

  bool showPrayerAzanPage = false;
  Prayer? currentPrayer;

  void togglePrayerAzanPage() {
    emit(AppChanged());
    showPrayerAzanPage = !showPrayerAzanPage;
    emit(AppInitial());
  }

  NextAdhan? nextAdhan;
  Prayer? nextPrayerVar;
  void assignNextPrayerVar(Prayer? prayer) {
    emit(AppInitial());
    nextPrayerVar = prayer;
    emit(AppChanged());
  }
}
