import 'dart:async';
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
import 'package:azan/core/models/weather_day.dart';
import 'package:azan/core/services/open_weather_service.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/core/utils/extenstions.dart';
import 'package:azan/data/data_source/azan_data_source.dart';
import 'package:azan/gen/assets.gen.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:azan/views/additional_settings/components/azkar_time_helper.dart';
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
  final Dio _dio;

  AppCubit._internal(this._dio) : super(AppInitial()) {
    weatherService = OpenMeteoWeatherService(dio: _dio);
    _initOnce();
  }

  static AppCubit? _instance;
  static Dio? _configuredDio;
  static bool _initialized = false;

  late final OpenMeteoWeatherService weatherService;
  WeatherForecast? weatherForecast;

  String _cityTodayKey(WeatherForecast f) {
    final cityNow = DateTime.now().toUtc().add(
      Duration(seconds: f.utcOffsetSeconds),
    );
    return DateFormat('yyyy-MM-dd', 'en').format(cityNow);
  }

  String _cityTomorrowKey(WeatherForecast f) {
    final cityNow = DateTime.now().toUtc().add(
      Duration(seconds: f.utcOffsetSeconds),
    );
    final tmr = cityNow.add(const Duration(days: 1));
    return DateFormat('yyyy-MM-dd', 'en').format(tmr);
  }

  WeatherDay? get todayWeather {
    final f = weatherForecast;
    if (f == null) return null;
    final key = _cityTodayKey(f);
    return f.days.cast<WeatherDay?>().firstWhere(
      (d) => d!.date == key,
      orElse: () => null,
    );
  }

  WeatherDay? get tomorrowWeather {
    final f = weatherForecast;
    if (f == null) return null;
    final key = _cityTomorrowKey(f);
    return f.days.cast<WeatherDay?>().firstWhere(
      (d) => d!.date == key,
      orElse: () => null,
    );
  }

  Future<void> loadWeatherForecast({
    required String country,
    required String city,
    bool forceRefresh = false,
  }) async {
    // 1) حاول من الكاش الأول (لو مش forced)
    if (!forceRefresh) {
      final cached = CacheHelper.get(key: WeatherCacheKeys.forecastJson);
      if (cached is String && cached.isNotEmpty) {
        try {
          final map = jsonDecode(cached) as Map<String, dynamic>;
          final f = WeatherForecast.fromJson(map);
          if (f != null) {
            weatherForecast = f;
            maxTemp = todayWeather?.max; // ✅ أضف ده
            await CacheHelper.save(
              key: WeatherCacheKeys.forecastJson,
              value: jsonEncode(f.toJson()),
            );
          }

          // كفاية جدًا: لو الكاش فيه النهاردة (بتوقيت المدينة) استخدمه
          final todayKey = _cityTodayKey(f);
          final hasToday = f.days.any((d) => d.date == todayKey);

          if (hasToday) {
            weatherForecast = f;
            emit(AppChanged());
            return;
          }
        } catch (_) {
          // ignore -> هننزل نجيب من النت
        }
      }
    }

    // 2) هات من النت
    emit(AppInitial());
    final f = await weatherService.fetchMaxForecast(
      city: city,
      country: country,
      days: OpenMeteoWeatherService.maxForecastDays,
      morningHour: 8,
      nightHour: 20,
    );

    if (f != null) {
      weatherForecast = f;
      await CacheHelper.save(
        key: WeatherCacheKeys.forecastJson,
        value: jsonEncode(f.toJson()),
      );
    }

    emit(AppChanged());
  }

  String _weatherCityKey({required String country, required String city}) {
    // لو عندك lat/lon في CacheHelper.getCity() يبقى أحسن
    final c = getCity();
    if (c != null) {
      return '${c.lat!.toStringAsFixed(4)},${c.lon!.toStringAsFixed(4)}';
    }
    return '$country|$city';
  }

  String _cityYmdByOffset(int utcOffsetSeconds) {
    final cityNow = DateTime.now().toUtc().add(
      Duration(seconds: utcOffsetSeconds),
    );
    return DateFormat('yyyy-MM-dd', 'en').format(cityNow);
  }

  bool _forecastHasToday(WeatherForecast f) {
    final todayKey = _cityYmdByOffset(f.utcOffsetSeconds);
    return f.days.any((d) => d.date == todayKey);
  }

  bool _weatherInFlight = false;
  static const _weatherTtl = Duration(hours: 6);

  bool _isFresh(WeatherForecast f) {
    final fetched = DateTime.fromMillisecondsSinceEpoch(f.fetchedAtMs);
    return DateTime.now().difference(fetched) < _weatherTtl;
  }

  Future<void> maybeRefreshWeather({
    required String country,
    required String city,
    required Future<bool> Function() hasInternet,
    bool force = false,
    bool onHomeOpen = false, // ✅ جديد
  }) async {
    if (_weatherInFlight) return;
    _weatherInFlight = true;

    try {
      final cityKey = _weatherCityKey(country: country, city: city);

      // 1) اقرأ الكاش
      WeatherForecast? cachedForecast;
      final cached = CacheHelper.get(key: WeatherCacheKeys.forecastJson);
      if (cached is String && cached.isNotEmpty) {
        try {
          cachedForecast = WeatherForecast.fromJson(
            jsonDecode(cached) as Map<String, dynamic>,
          );
        } catch (_) {}
      }

      final cachedCity = CacheHelper.get(key: WeatherCacheKeys.lastCityKey);
      final cacheMatchesCity = (cachedCity == cityKey);

      // 2) اعرض الكاش فورًا
      if (cachedForecast != null && cacheMatchesCity) {
        weatherForecast = cachedForecast;
        maxTemp = todayWeather?.max;
        emit(AppChanged());
      }

      // 3) قرار الـ refresh
      // ✅ لو دي نداء "فتح HomeScreen" → اعمل fetch كل مرة
      if (onHomeOpen) {
        final now = DateTime.now();
        if (_lastWeatherFetchAt != null &&
            now.difference(_lastWeatherFetchAt!) < _homeOpenThrottle) {
          return; // منع تكرار سريع
        }
        // كمل fetch
      } else if (!force) {
        // منطقك القديم (مرة في اليوم + freshness)
        if (cachedForecast != null && cacheMatchesCity) {
          final todayYmd = _cityYmdByOffset(cachedForecast.utcOffsetSeconds);
          final lastSync = CacheHelper.get(key: WeatherCacheKeys.lastSyncYmd);
          final syncedToday = (lastSync == todayYmd);

          if (syncedToday && _isFresh(cachedForecast)) return;
        }
      }

      // 4) net
      final net = await hasInternet();
      if (!net) return;

      // 5) fetch من النت
      final f = await weatherService.fetchMaxForecast(
        city: city,
        country: country,
        days: OpenMeteoWeatherService.maxForecastDays,
        morningHour: 8,
        nightHour: 20,
      );

      if (f != null) {
        _lastWeatherFetchAt = DateTime.now(); // ✅ سجل وقت آخر fetch

        weatherForecast = f;
        maxTemp = todayWeather?.max;

        await CacheHelper.save(
          key: WeatherCacheKeys.forecastJson,
          value: jsonEncode(f.toJson()),
        );

        await CacheHelper.save(
          key: WeatherCacheKeys.lastSyncYmd,
          value: _cityYmdByOffset(f.utcOffsetSeconds),
        );

        await CacheHelper.save(
          key: WeatherCacheKeys.lastCityKey,
          value: cityKey,
        );

        emit(AppChanged());
      }
    } finally {
      _weatherInFlight = false;
    }
  }

  Future<bool> get hasInternet => _hasConnection;

  StreamSubscription? _netSub;
  DateTime _lastNetEvent = DateTime.fromMillisecondsSinceEpoch(0);

  void startWeatherAutoSync({
    required String country,
    required String city,
    required Future<bool> Function() hasInternet,
  }) {
    _netSub?.cancel();

    _netSub = Connectivity().onConnectivityChanged.listen((
      dynamic result,
    ) async {
      final now = DateTime.now();
      if (now.difference(_lastNetEvent).inSeconds < 5) return;
      _lastNetEvent = now;

      final connected = (result is List<ConnectivityResult>)
          ? !result.contains(ConnectivityResult.none)
          : result != ConnectivityResult.none;

      if (!connected) return;

      await maybeRefreshWeather(
        country: country,
        city: city,
        hasInternet: hasInternet,
        force: false,
      );
    });
  }

  void stopWeatherAutoSync() {
    _netSub?.cancel();
    _netSub = null;
  }

  static void configure({required Dio dio}) {
    _configuredDio ??= dio;
  }

  factory AppCubit({Dio? dio}) {
    if (_instance != null) return _instance!;

    final resolved = dio ?? _configuredDio;
    if (resolved == null) {
      throw StateError('Call AppCubit.configure(dio: ...) before AppCubit()');
    }

    _instance = AppCubit._internal(resolved);
    return _instance!;
  }

  void _initOnce() {
    if (_initialized) return;
    _initialized = true;

    loadAzanAdjustSettingsOnce();
    _loadUiRotation();
  }

  //
  // AppCubit(this._dio) : super(AppInitial()) {
  //   loadAzanAdjustSettingsOnce(); // ✅ مرة واحدة
  //   _loadUiRotation();
  // }
  // singelton
  // static final AppCubit _instance = AppCubit(Dio());
  // static AppCubit get instance => _instance;
  // final Dio _dio;

  int uiQuarterTurns = 0; // 0..3
  /// ✅ يرجّع وقت الصلاة "بعد التعديل" حسب id (1..6)
  /// 1=fajr, 2=sunrise, 3=dhuhr, 4=asr, 5=maghrib, 6=isha
  DateTime? adjustedPrayerTimeById(int id, {adhan.PrayerTimes? times}) {
    final t = times ?? prayerTimes;
    if (t == null) return null;

    switch (id) {
      case 1:
        return _applyAzanAdjust("fajr", t.fajr);
      case 2:
        return _applyAzanAdjust("sunrise", t.sunrise);
      case 3:
        return _applyAzanAdjust("dhuhr", t.dhuhr);
      case 4:
        return _applyAzanAdjust("asr", t.asr);
      case 5:
        return _applyAzanAdjust("maghrib", t.maghrib);
      case 6:
        return _applyAzanAdjust("isha", t.isha);
      default:
        return null;
    }
  }

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

  bool _isSummerByLatitude(DateTime d, double lat) {
    // Northern hemisphere: Apr..Sep
    if (lat >= 0) {
      return d.month >= 4 && d.month <= 9;
    }
    // Southern hemisphere: Oct..Mar
    return (d.month >= 10) || (d.month <= 3);
  }

  bool _isSummerNow() {
    final coords = CacheHelper.getCoordinates();
    final lat = coords?.latitude;

    // fallback لو مفيش coords (اعتبره شمالي)
    if (lat == null) {
      final m = DateTime.now().month;
      return m >= 4 && m <= 9;
    }

    return _isSummerByLatitude(DateTime.now(), lat);
  }

  // int _extraMinutesForPrayer(String key) {
  //   var minutes = 0;

  //   // ✅ Summer +1h (only during summer)
  //   if (_azanAdjust.summerPlusHour && _isSummerNow()) {
  //     minutes += 60;
  //   }

  //   // ✅ manual global shift
  //   minutes += _azanAdjust.manualAllShiftMinutes;

  //   // ✅ per prayer shift
  //   final idx = _prayerIndex(key);
  //   if (idx >= 0 && idx < _azanAdjust.perPrayerMinutes.length) {
  //     minutes += _azanAdjust.perPrayerMinutes[idx];
  //   }

  //   // ✅ Ramadan Isha +30
  //   if (key == "isha" && isRamadan && _azanAdjust.ramadanIshaPlus30) {
  //     minutes += 30;
  //   }

  //   return minutes;
  // }

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

  int _dstDeltaMinutesNow() {
    final y = DateTime.now().year;
    final jan = DateTime(y, 1, 1).timeZoneOffset.inMinutes;
    final jul = DateTime(y, 7, 1).timeZoneOffset.inMinutes;

    final standard = min(jan, jul); // غالبًا ده الشتوي
    final current = DateTime.now().timeZoneOffset.inMinutes;

    // الناتج غالبًا 0 أو 60 (حسب البلد)
    return current - standard;
  }

  int _extraMinutesForPrayer(String key) {
    var minutes = 0;

    // ✅ Summer +1h (only during summer)
    if (_azanAdjust.summerPlusHour && _isSummerNow()) {
      minutes += 60;
    }

    // ✅ manual global shift
    minutes += _azanAdjust.manualAllShiftMinutes;

    // ✅ per prayer shift
    final idx = _prayerIndex(key);
    if (idx >= 0 && idx < _azanAdjust.perPrayerMinutes.length) {
      minutes += _azanAdjust.perPrayerMinutes[idx];
    }

    // ✅ Ramadan Isha +30
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

  double? get todayMaxTemp => todayWeather?.max;
  int? get todayWeatherCode => todayWeather?.weatherCode;
  DateTime? _lastWeatherFetchAt;
  static const _homeOpenThrottle = Duration(seconds: 30);

  // Future<void> loadTodayMaxTemp({
  //   required String country,
  //   required String city,
  // }) async {
  //   emit(AppInitial());
  //   final maxTemp = await weatherService.fetchTodayMaxTemperature(
  //     city: city, // اللي المستخدم يدخله
  //     country: country, // أو "مصر"، بس الإنجليزي أدق للـ API
  //   );

  //   this.maxTemp = maxTemp;
  //   print('maxTemp: $maxTemp');
  //   emit(AppChanged());
  // }

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

  Future<adhan.PrayerTimes?> fetchPrayerTimesExactDay(
    LatLng latLng,
    DateTime day, {
    bool storeToMain = false,
  }) async {
    try {
      final result = await azanDataSource.fetchPrayerTimes(latLng, day);
      if (result != null && storeToMain) {
        prayerTimes = result;
      }
      return result;
    } catch (e) {
      'e: $e'.log();
      return null;
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
          'storeToMain'.log();
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

  Prayer? nextFajrPrayer;

  Future<void> initializePrayerTimes({
    String? city,
    required BuildContext context,
  }) async {
    try {
      final hasNet = await _hasConnection;
      'hasNet: $hasNet'.log();
      connectivity = hasNet;

      emit(FetchPrayerTimesLoading());

      // 1) جهّز الإحداثيات (دي عندك Offline من LocationHelper)
      if (cityChanged) {
        await fetchCityCoordinate(city!);
        cityChanged = false;
      }
      if (CacheHelper.getCoordinates() == null && city != null) {
        'CacheHelper.getCoordinates() == null && city != null'.log();
        await fetchCityCoordinate(city);
        " fetch coordinate: fetch coordinate:${await fetchCityCoordinate(city)}"
            .log();
      }

      final coords = CacheHelper.getCoordinates();
      if (coords == null) {
        emit(
          FetchPrayerTimesFailure(
            LocaleKeys.something_went_wrong_please_try_again.tr(),
          ),
        );
        return;
      }

      // 2) احسب صلوات اليوم (Offline)
      // 2) احسب صلوات اليوم (زي ما هي حتى لو بعد العشاء)
      final todayTimes = await fetchPrayerTimesExactDay(
        coords,
        DateTime.now(),
        storeToMain: true,
      );

      // 3) احسب صلوات بكرة عشان nextFajrPrayer فقط
      final tomorrowTimes = await fetchPrayerTimesExactDay(
        coords,
        DateTime.now().add(const Duration(days: 1)),
      );

      if (tomorrowTimes != null) {
        nextFajrPrayer = _mapToPrayers(tomorrowTimes, context: context).first;
      }

      if (todayTimes != null) {
        emit(FetchPrayerTimesSuccess());
      } else {
        emit(
          FetchPrayerTimesFailure(
            LocaleKeys.something_went_wrong_please_try_again.tr(),
          ),
        );
      }
    } catch (e) {
      'eeeeeeee$e'.log();
    }
    // ما تمنعش الصلاة بسبب النت

    // 4) الحاجات اللي محتاجة نت خليها اختيارية
    //   if (hasNet) {
    //    unawaited(
    //   loadWeatherForecast(
    //     country: 'Saudi Arabia',
    //     city: city ?? CacheHelper.getCity()?.nameEn ?? '',
    //   ),
    // );
    //   }
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

  Future<Prayer?> nextPrayer(BuildContext context) async {
    final list = prayers(context); // from prayerTimes (جدول اليوم)
    final now = DateTime.now();

    for (final p in list) {
      final dt = p.dateTime;
      if (dt != null && dt.isAfter(now)) return p;
    }

    // لو خلصنا صلوات اليوم -> هات بكرة كـ nextPrayer فقط
    final coords = CacheHelper.getCoordinates();
    if (coords == null) return null;

    final tomorrowTimes = await fetchPrayerTimesExactDay(
      coords,
      DateTime.now().add(const Duration(days: 1)),
    );
    if (tomorrowTimes == null) return null;

    final tomorrowPrayers = _mapToPrayers(tomorrowTimes, context: context);
    return tomorrowPrayers.isNotEmpty ? tomorrowPrayers.first : null;
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

  String setCountry(String country) {
    CacheHelper.setCountry(country);
    return country;
  }

  String clearCountry() {
    CacheHelper.removeCountry();
    return '';
  }

  // CityOption? getCity() {
  //   emit(AppInitial());
  //   emit(AppChanged());
  //   return CacheHelper.getCity();
  // }

  void setCity(CityOption city) {
    emit(AppInitial());
    CacheHelper.setCity(city);
    emit(AppChanged());
  }

  CityOption? getCity() => CacheHelper.getCity();
  String? getCountry() => CacheHelper.getCountry();

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
    'prayersDuration $prayersDuration'.log();
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
      prayerCount: 5,
    );

    'prayersDuration $prayersDuration'.log();
    emit(AppChanged());
  }

  int? currentPrayerDuration;
  int getCurrentPrayerDuraion() {
    final p = currentPrayer;
    if (p == null) return 7;

    final idx = AzkarTimeHelper.durationIndexForPrayerId(p.id);
    if (idx == null) return 7;

    currentPrayerDuration =
        prayersDuration != null && prayersDuration!.length > idx
        ? prayersDuration![idx]
        : 7;

    return currentPrayerDuration!;
  }

  int getPrayerDurationForId(int prayerId) {
    final idx = AzkarTimeHelper.durationIndexForPrayerId(prayerId);

    // 'idx ${idx}'.log();

    if (idx == null) return 7;
    // ''
    //     " prayersDuration${prayersDuration?[idx].toString()}"
    // .log();

    return (prayersDuration != null && prayersDuration!.length > idx)
        ? prayersDuration![idx]
        : 7;
  }

  List<Dhikr>? get todaysAdkar {
    if (adhkarList == null) return null;
    return adhkarList!
        .where((element) => element.active && element.isForDay(DateTime.now()))
        .toList();
  }

  String get getAzanSoundSource {
    try {
      if (CacheHelper.getUseMp3Azan() && !CacheHelper.getUseShortAzan()) {
        final path = Assets.sounds.azanLong;
        return path;
      } else if (CacheHelper.getUseMp3Azan() && CacheHelper.getUseShortAzan()) {
        final path = Assets.sounds.azan;
        return path;
      }

      final fallback = Assets.sounds.alarmSound;
      return fallback;
    } catch (e) {
      return Assets.sounds.alarmSound;
    }
  }

  String get getIqamaSoundSource {
    if (CacheHelper.getUseShortIqama()) {
      return Assets.sounds.iqama;
    }
    return Assets.sounds.alarmSound;
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
