import 'dart:convert';
import 'dart:math';

import 'package:adhan/adhan.dart' as adhan;
import 'package:azan/controllers/cubits/appcubit/app_state.dart';
import 'package:azan/core/helpers/azan_adjust_model.dart';
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

import 'package:jhijri/_src/_jHijri.dart';

class AppCubit extends Cubit<AppState> {
  AppCubit(this._dio) : super(AppInitial()) {
    loadAzanAdjustSettingsOnce(); // ✅ مرة واحدة
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
  bool isRamadan = false;

  Future<String?> getTodayHijriDate(BuildContext context) async {
    emit(AppInitial());

    try {
      final offsetDays = CacheHelper.getHijriOffsetDays();

      // ✅ التاريخ الميلادي بعد الـ offset
      final g = DateTime.now().add(Duration(days: offsetDays));

      // ✅ لازم تمرر g مش DateTime.now()
      final h = JHijri(fDate: g);
      final day = h.day.toString();
      final year = h.year.toString();
      final month = h.month.toString();

      // ✅ jhijri غالبًا monthName واحدة (عربي)
      // لو عايز إنجليزي لازم mapping منك أو lib تاني
      final monthName = CacheHelper.getLang() == 'en'
          ? englishHMonth(h.month)
          : h.monthName;

      final rawText = '$day $monthName $year';

      final formatted = LocalizationHelper.isArAndArNumberEnable()
          ? DateHelper.toArabicDigits(rawText)
          : DateHelper.toWesternDigits(rawText);
      isRamadan = month == '9' ? true : false;

      hijriDate = formatted;

      emit(AppChanged());
      'formatted formatted'.log();
      return formatted;
    } catch (e, st) {
      debugPrint('Hijri offline error: $e');
      debugPrint('$st');
      return null;
    }
  }

  final weatherService = OpenMeteoWeatherService();

  double? maxTemp;
  // =========================
  // Azan Adjust Settings (CORRECT)
  // =========================

  AzanAdjustSettings _azanAdjust = CacheHelper.getAzanAdjustSettings();
  AzanAdjustSettings get azanAdjust => _azanAdjust;

  /// load once
  void loadAzanAdjustSettingsOnce() {
    _azanAdjust = CacheHelper.getAzanAdjustSettings();
  }

  /// update + persist + refresh UI
  Future<void> updateAzanAdjustSettings(AzanAdjustSettings s) async {
    final fixed = s.normalized();
    _azanAdjust = fixed;
    await CacheHelper.setAzanAdjustSettings(fixed);
    emit(AppChanged());
  }

  static const List<String> _prayerKeysOrder = [
    "fajr",
    "sunrise",
    "dhuhr",
    "asr",
    "maghrib",
    "isha",
  ];

  int _prayerIndex(String key) {
    final i = _prayerKeysOrder.indexOf(key);
    return i < 0 ? 0 : i;
  }

  int _extraMinutesForPrayer(String key) {
    var minutes = 0;

    // +1 hour summer
    if (_azanAdjust.summerPlusHour) minutes += 60;

    // manual all shift: -60 / 0 / +60
    minutes += _azanAdjust.manualAllShiftMinutes;

    // per prayer minutes
    final idx = _prayerIndex(key);
    if (idx >= 0 && idx < _azanAdjust.perPrayerMinutes.length) {
      minutes += _azanAdjust.perPrayerMinutes[idx];
    }

    // رمضان: على العشاء فقط (وبشرط رمضان)
    if (key == "isha" && isRamadan && _azanAdjust.ramadanIshaPlus30) {
      minutes += 30;
    }

    return minutes;
  }

  DateTime _applyAzanAdjust(String key, DateTime base) {
    return base.add(Duration(minutes: _extraMinutesForPrayer(key)));
  }

  List<MapEntry<String, DateTime>> _adjustedEntriesFromTimes(
    adhan.PrayerTimes t,
  ) {
    return <MapEntry<String, DateTime>>[
      MapEntry("fajr", _applyAzanAdjust("fajr", t.fajr)),
      MapEntry("sunrise", _applyAzanAdjust("sunrise", t.sunrise)),
      MapEntry("dhuhr", _applyAzanAdjust("dhuhr", t.dhuhr)),
      MapEntry("asr", _applyAzanAdjust("asr", t.asr)),
      MapEntry("maghrib", _applyAzanAdjust("maghrib", t.maghrib)),
      MapEntry("isha", _applyAzanAdjust("isha", t.isha)),
    ]..sort((a, b) => a.value.compareTo(b.value));
  }

  /// null => مفيش صلاة جاية في نفس اليوم (يعني لازم بكرة)
  String? _nextPrayerKeyFromTimes(adhan.PrayerTimes t, {DateTime? now}) {
    final n = now ?? DateTime.now();
    final list = _adjustedEntriesFromTimes(t);
    for (final e in list) {
      if (e.value.isAfter(n)) return e.key;
    }
    return null;
  }

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
    'latLng: latlng: latlng; $latLng'.log();
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
        final nextKey = _nextPrayerKeyFromTimes(result, now: DateTime.now());
        if (nextKey == null) {
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
  String _time12(DateTime prayerTime) {
    return LocalizationHelper.isArAndArNumberEnable()
        ? DateFormat.jm(CacheHelper.getLang()).format(prayerTime)
        : DateFormat.jm('en').format(prayerTime);
  }

  String _time24(DateTime prayerTime) {
    return LocalizationHelper.isArAndArNumberEnable()
        ? DateFormat('HH:mm', CacheHelper.getLang()).format(prayerTime)
        : DateFormat('HH:mm', 'en').format(prayerTime);
  }

  List<Prayer> _mapToPrayers(
    adhan.PrayerTimes? times, {
    required BuildContext context,
  }) {
    // ✅ لو مفيش times رجّع prayers كلها null من غير أي ! ولا copywith
    if (times == null) {
      return [
        Prayer(
          id: 1,
          title: LocaleKeys.fajr.tr(),
          time: null,
          dateTime: null,
          time24: null,
        ),
        Prayer(
          id: 2,
          title: LocaleKeys.sunrise.tr(),
          time: null,
          dateTime: null,
          time24: null,
        ),
        Prayer(
          id: 3,
          title: DateHelper.isFriday()
              ? LocaleKeys.friday.tr()
              : LocaleKeys.dhuhr.tr(),
          time: null,
          dateTime: null,
          time24: null,
        ),
        Prayer(
          id: 4,
          title: LocaleKeys.asr.tr(),
          time: null,
          dateTime: null,
          time24: null,
        ),
        Prayer(
          id: 5,
          title: LocaleKeys.maghrib.tr(),
          time: null,
          dateTime: null,
          time24: null,
        ),
        Prayer(
          id: 6,
          title: LocaleKeys.isha.tr(),
          time: null,
          dateTime: null,
          time24: null,
        ),
      ];
    }

    // ✅ هنا times guaranteed مش null
    final fajr = _applyAzanAdjust("fajr", times.fajr);
    final sunrise = _applyAzanAdjust("sunrise", times.sunrise);
    final dhuhr = _applyAzanAdjust("dhuhr", times.dhuhr);
    final asr = _applyAzanAdjust("asr", times.asr);
    final maghrib = _applyAzanAdjust("maghrib", times.maghrib);
    final isha = _applyAzanAdjust("isha", times.isha);

    return [
      Prayer(
        id: 1,
        title: LocaleKeys.fajr.tr(),
        time: _time12(fajr),
        dateTime: fajr,
        time24: _time24(fajr),
      ),
      Prayer(
        id: 2,
        title: LocaleKeys.sunrise.tr(),
        time: _time12(sunrise),
        dateTime: sunrise,
        time24: _time24(sunrise),
      ),
      Prayer(
        id: 3,
        title: DateHelper.isFriday()
            ? LocaleKeys.friday.tr()
            : LocaleKeys.dhuhr.tr(),
        time: _time12(dhuhr),
        dateTime: dhuhr,
        time24: _time24(dhuhr),
      ),
      Prayer(
        id: 4,
        title: LocaleKeys.asr.tr(),
        time: _time12(asr),
        dateTime: asr,
        time24: _time24(asr),
      ),
      Prayer(
        id: 5,
        title: LocaleKeys.maghrib.tr(),
        time: _time12(maghrib),
        dateTime: maghrib,
        time24: _time24(maghrib),
      ),
      Prayer(
        id: 6,
        title: LocaleKeys.isha.tr(),
        time: _time12(isha),
        dateTime: isha,
        time24: _time24(isha),
      ),
    ];
  }

  List<Prayer> prayers(BuildContext context) =>
      _mapToPrayers(prayerTimes, context: context);

  Future<Prayer?> nextPrayer(context) async {
    final list = prayers(context); // ✅ already adjusted
    final now = DateTime.now();

    for (final p in list) {
      final dt = p.dateTime;
      if (dt != null && dt.isAfter(now)) return p;
    }

    // ✅ لو خلصنا صلوات اليوم -> هات بكرة
    await initializePrayerTimes(
      city: CacheHelper.getCity()!.nameEn,
      context: context,
    );

    final afterReload = prayers(context);
    return afterReload.isNotEmpty ? afterReload.first : null;
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
