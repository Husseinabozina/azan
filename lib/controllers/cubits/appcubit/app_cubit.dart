import 'dart:async';
import 'dart:convert';

import 'package:adhan/adhan.dart' as adhan;
import 'package:azan/controllers/cubits/appcubit/app_state.dart';
import 'package:azan/core/helpers/azan_adjust_model.dart';
import 'package:azan/core/helpers/date_helper.dart';
import 'package:azan/core/helpers/display_board_hive_helper.dart';
import 'package:azan/core/helpers/dhikr_hive_helper.dart';
import 'package:azan/core/helpers/iqama_hive_helper.dart';
import 'package:azan/core/helpers/localizationHelper.dart';
import 'package:azan/core/helpers/location_helper.dart';
import 'package:azan/core/helpers/prayer_calendar_helper.dart';
import 'package:azan/core/helpers/prayer_calendar_hive_helper.dart';
import 'package:azan/core/helpers/prayer_duration_hive_helper.dart';
import 'package:azan/core/helpers/slide_hive_helper.dart';
import 'package:azan/core/models/city_option.dart';
import 'package:azan/core/models/display_announcement.dart';
import 'package:azan/core/models/diker.dart';
import 'package:azan/core/models/geo_location.dart';
import 'package:azan/core/models/gregorian_coverage_window.dart';
import 'package:azan/core/models/latlng.dart';
import 'package:azan/core/models/next_Iqama.dart';
import 'package:azan/core/models/official_city_catalog_entry.dart';
import 'package:azan/core/models/prayer.dart';
import 'package:azan/core/models/prayer_calendar_day.dart';
import 'package:azan/core/models/weather_day.dart';
import 'package:azan/core/services/official_city_catalog_service.dart';
import 'package:azan/core/services/open_weather_service.dart';
import 'package:azan/core/services/sytem_time_guard_service.dart';
import 'package:azan/core/services/umm_al_qura_bundle_service.dart';
import 'package:azan/core/utils/cache_helper.dart';
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

import 'package:jhijri/_src/_jHijri.dart';

enum PrayerCyclePhase {
  idle,
  adhan,
  duaa,
  betweenAdhanAndIqama,
  iqama,
  prayerActive,
  ended,
}

class AppCubit extends Cubit<AppState> {
  final Dio _dio;

  AppCubit._internal(this._dio) : super(AppInitial()) {
    weatherService = OpenMeteoWeatherService(dio: _dio);
    ummAlQuraBundleService = UmmAlQuraBundleService();
    officialCityCatalogService = OfficialCityCatalogService(
      bundleService: ummAlQuraBundleService,
    );
    _initOnce();
  }

  SystemTimeGuardService? _systemTimeGuard;

  Future<void> init() async {
    _systemTimeGuard = SystemTimeGuardService(
      onDeviceTimeChanged: _onDeviceTimeChanged,
      onError: (e, st) {
        // log error
      },
    );

    _systemTimeGuard?.startListening();
  }

  Future<void> _onDeviceTimeChanged(DeviceTimeChangeEvent event) async {
    emit(AppInitial());
    // ✅ هنا الدالة اللي إنت عاوزها
    await handleDeviceTimeChanged(event);

    // لو عندك UI محتاج refresh:
    emit(AppChanged());
  }

  Future<void> handleDeviceTimeChanged(DeviceTimeChangeEvent event) async {
    _lastResolvedWeatherYmd = null;
    final city = getCity()?.nameEn ?? '';
    if (city.isNotEmpty) {
      await syncWeatherLifecycle(
        country: 'Saudi Arabia',
        city: city,
        hasInternet: () => hasInternet,
        forceRefresh: true,
      );
    }
  }

  @override
  Future<void> close() async {
    await _systemTimeGuard?.stopListening();
    return super.close();
  }

  static AppCubit? _instance;
  static Dio? _configuredDio;
  static bool _initialized = false;

  late final OpenMeteoWeatherService weatherService;
  late final OfficialCityCatalogService officialCityCatalogService;
  late final UmmAlQuraBundleService ummAlQuraBundleService;
  WeatherForecast? weatherForecast;
  CityOption? _selectedCity;
  PrayerCalendarDay? _todayPrayerCalendarDay;
  PrayerCalendarDay? _tomorrowPrayerCalendarDay;
  List<int>? _baseIqamaMinutes;
  String? _activePrayerCalendarCityKey;

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

  DateTime? _parseWeatherDayKey(String raw) {
    try {
      return DateTime.parse(raw);
    } catch (_) {
      return null;
    }
  }

  WeatherDay? _nearestWeatherDay(WeatherForecast f) {
    if (f.days.isEmpty) return null;

    final target = _parseWeatherDayKey(_cityTodayKey(f));
    if (target == null) {
      return f.days.first;
    }

    WeatherDay? best;
    int? bestDistance;

    for (final day in f.days) {
      final parsed = _parseWeatherDayKey(day.date);
      if (parsed == null) continue;

      final distance = parsed.difference(target).inDays.abs();
      if (best == null || bestDistance == null || distance < bestDistance) {
        best = day;
        bestDistance = distance;
      }
    }

    return best ?? f.days.first;
  }

  WeatherDay? get displayWeather {
    final f = weatherForecast;
    if (f == null) return null;
    return todayWeather ?? _nearestWeatherDay(f);
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
          weatherForecast = f;
          maxTemp = displayWeather?.max;
          await CacheHelper.save(
            key: WeatherCacheKeys.forecastJson,
            value: jsonEncode(f.toJson()),
          );

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
    final autoCoords = _selectedAutoWeatherCoordinates();
    if (autoCoords != null) {
      return '${autoCoords.latitude.toStringAsFixed(4)},${autoCoords.longitude.toStringAsFixed(4)}';
    }
    return '$country|$city';
  }

  String _legacyWeatherCityKey({
    required String country,
    required String city,
  }) {
    return '$country|$city';
  }

  bool _cacheMatchesWeatherKey({
    required Object? cachedKey,
    required String resolvedKey,
    required String country,
    required String city,
    required bool isManualWeatherSource,
  }) {
    if (cachedKey == resolvedKey) return true;

    // Backward compatibility: old auto-weather caches used `country|city`
    // before we switched to coordinate-based keys.
    if (!isManualWeatherSource &&
        cachedKey == _legacyWeatherCityKey(country: country, city: city)) {
      return true;
    }

    return false;
  }

  String _localYmd(DateTime date) {
    return DateFormat('yyyy-MM-dd', 'en').format(date);
  }

  LatLng? _selectedAutoWeatherCoordinates() {
    final selectedCity = getCity();
    if (selectedCity?.lat != null && selectedCity?.lon != null) {
      return LatLng(selectedCity!.lat!, selectedCity.lon!);
    }
    return CacheHelper.getCoordinates();
  }

  String _currentCityWeatherYmd({WeatherForecast? forecast}) {
    final activeForecast = forecast ?? weatherForecast;
    if (activeForecast != null) {
      return _cityYmdByOffset(activeForecast.utcOffsetSeconds);
    }
    return _localYmd(DateTime.now());
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
  static const _weatherRetryBackoff = Duration(minutes: 15);
  String? _lastResolvedWeatherYmd;
  DateTime? _lastWeatherRefreshAttemptAt;

  bool _isFresh(WeatherForecast f) {
    final fetched = DateTime.fromMillisecondsSinceEpoch(f.fetchedAtMs);
    return DateTime.now().difference(fetched) < _weatherTtl;
  }

  bool _syncResolvedWeatherSnapshot({bool emitIfChanged = false}) {
    final resolvedYmd = _currentCityWeatherYmd();
    final resolvedMax = displayWeather?.max;
    final changed =
        _lastResolvedWeatherYmd != resolvedYmd || maxTemp != resolvedMax;

    _lastResolvedWeatherYmd = resolvedYmd;
    maxTemp = resolvedMax;

    if (changed && emitIfChanged) {
      emit(AppChanged());
    }
    return changed;
  }

  bool _canAttemptWeatherRefreshNow({
    required DateTime now,
    bool forceRefresh = false,
    bool onHomeOpen = false,
  }) {
    if (forceRefresh) return true;

    final lastAttempt = _lastWeatherRefreshAttemptAt;
    if (lastAttempt == null) return true;

    final retryWindow = onHomeOpen ? _homeOpenThrottle : _weatherRetryBackoff;
    return now.difference(lastAttempt) >= retryWindow;
  }

  Future<void> syncWeatherLifecycle({
    required String country,
    required String city,
    required Future<bool> Function() hasInternet,
    bool onHomeOpen = false,
    bool forceRefresh = false,
  }) async {
    if (!CacheHelper.getWeatherEnabled()) return;

    final activeForecast = weatherForecast;
    final currentYmd = _currentCityWeatherYmd(forecast: activeForecast);
    final hasTodayInForecast =
        activeForecast != null && _forecastHasToday(activeForecast);
    final dayChanged =
        _lastResolvedWeatherYmd != null &&
        _lastResolvedWeatherYmd != currentYmd;
    final missingToday = activeForecast == null || !hasTodayInForecast;
    final staleForecast = activeForecast != null && !_isFresh(activeForecast);

    _syncResolvedWeatherSnapshot(emitIfChanged: true);

    final shouldRefresh =
        onHomeOpen ||
        forceRefresh ||
        dayChanged ||
        missingToday ||
        staleForecast;
    if (!shouldRefresh) return;

    final now = DateTime.now();
    final bypassBackoff = forceRefresh || dayChanged;
    if (!_canAttemptWeatherRefreshNow(
      now: now,
      forceRefresh: bypassBackoff,
      onHomeOpen: onHomeOpen,
    )) {
      return;
    }

    _lastWeatherRefreshAttemptAt = now;

    await maybeRefreshWeather(
      country: country,
      city: city,
      hasInternet: hasInternet,
      force: forceRefresh || dayChanged || missingToday || staleForecast,
      onHomeOpen: onHomeOpen,
    );

    _syncResolvedWeatherSnapshot(emitIfChanged: true);
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
      // ✅ Check if manual GPS is enabled
      final isWeatherEnabled = CacheHelper.getWeatherEnabled();
      final weatherSource =
          CacheHelper.getWeatherSource(); // 0 = Auto, 1 = Manual

      String cacheKey;

      if (isWeatherEnabled && weatherSource == 1) {
        // ✅ Manual GPS mode
        final manualLat = CacheHelper.getManualWeatherLat();
        final manualLng = CacheHelper.getManualWeatherLng();

        if (manualLat != null && manualLng != null) {
          cacheKey = 'manual_${manualLat}_$manualLng';
        } else {
          cacheKey = _weatherCityKey(country: country, city: city);
        }
      } else {
        // ✅ Auto mode (from city)
        cacheKey = _weatherCityKey(country: country, city: city);
      }

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
      final cacheMatchesCity = _cacheMatchesWeatherKey(
        cachedKey: cachedCity,
        resolvedKey: cacheKey,
        country: country,
        city: city,
        isManualWeatherSource: isWeatherEnabled && weatherSource == 1,
      );

      // 2) اعرض الكاش فورًا
      if (cachedForecast != null && cacheMatchesCity) {
        weatherForecast = cachedForecast;
        maxTemp = displayWeather?.max;
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
      WeatherForecast? f;

      if (isWeatherEnabled && weatherSource == 1) {
        // ✅ Manual GPS mode
        final manualLat = CacheHelper.getManualWeatherLat();
        final manualLng = CacheHelper.getManualWeatherLng();

        if (manualLat != null && manualLng != null) {
          final lat = double.tryParse(manualLat);
          final lng = double.tryParse(manualLng);

          if (lat != null && lng != null) {
            f = await weatherService.fetchMaxForecastByCoordinates(
              latitude: lat,
              longitude: lng,
              days: OpenMeteoWeatherService.maxForecastDays,
              morningHour: 8,
              nightHour: 20,
            );
          } else {
            f = await weatherService.fetchMaxForecast(
              city: city,
              country: country,
              days: OpenMeteoWeatherService.maxForecastDays,
              morningHour: 8,
              nightHour: 20,
            );
          }
        } else {
          f = await weatherService.fetchMaxForecast(
            city: city,
            country: country,
            days: OpenMeteoWeatherService.maxForecastDays,
            morningHour: 8,
            nightHour: 20,
          );
        }
      } else {
        // ✅ Auto mode (from city)
        final autoCoords = _selectedAutoWeatherCoordinates();
        if (autoCoords != null) {
          f = await weatherService.fetchMaxForecastByCoordinates(
            latitude: autoCoords.latitude,
            longitude: autoCoords.longitude,
            days: OpenMeteoWeatherService.maxForecastDays,
            morningHour: 8,
            nightHour: 20,
          );
        } else {
          f = await weatherService.fetchMaxForecast(
            city: city,
            country: country,
            days: OpenMeteoWeatherService.maxForecastDays,
            morningHour: 8,
            nightHour: 20,
          );
        }
      }

      if (f != null) {
        _lastWeatherFetchAt = DateTime.now(); // ✅ سجل وقت آخر fetch

        weatherForecast = f;
        maxTemp = displayWeather?.max;

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
          value: cacheKey,
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

      await syncWeatherLifecycle(
        country: country,
        city: city,
        hasInternet: hasInternet,
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

    _selectedCity = CacheHelper.getCity();
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

  DateTime _normalizedDate(DateTime date) =>
      PrayerCalendarHelper.dateOnly(date);

  bool _isSameCalendarDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  double? get _currentLatitude {
    final cityLat = getCity()?.lat;
    if (cityLat != null) return cityLat;
    return CacheHelper.getCoordinates()?.latitude;
  }

  String _dhuhrTitleForDate(DateTime date) {
    return PrayerCalendarHelper.isFriday(date)
        ? LocaleKeys.friday.tr()
        : LocaleKeys.dhuhr.tr();
  }

  PrayerCalendarDay? _syncDayRecordForDate(DateTime date) {
    final normalized = _normalizedDate(date);
    if (_todayPrayerCalendarDay != null &&
        _todayPrayerCalendarDay!.gregorianYmd ==
            PrayerCalendarHelper.ymdForDate(normalized)) {
      return _todayPrayerCalendarDay;
    }
    if (_tomorrowPrayerCalendarDay != null &&
        _tomorrowPrayerCalendarDay!.gregorianYmd ==
            PrayerCalendarHelper.ymdForDate(normalized)) {
      return _tomorrowPrayerCalendarDay;
    }
    final cityKey = _activePrayerCalendarCityKey;
    if (cityKey == null) return null;
    return PrayerCalendarHiveHelper.getDaySync(
      cityKey: cityKey,
      date: normalized,
    );
  }

  DateTime? _rawPrayerTimeFromTimes(int id, adhan.PrayerTimes t) {
    switch (id) {
      case 1:
        return t.fajr;
      case 2:
        return t.sunrise;
      case 3:
        return t.dhuhr;
      case 4:
        return t.asr;
      case 5:
        return t.maghrib;
      case 6:
        return t.isha;
      default:
        return null;
    }
  }

  int _extraMinutesForPrayerAtDate(String key, DateTime date) {
    return PrayerCalendarHelper.azanAdjustmentMinutesForPrayer(
      prayerKey: key,
      date: date,
      settings: _azanAdjust,
      offsetDays: CacheHelper.getHijriOffsetDays(),
      latitude: _currentLatitude,
    );
  }

  DateTime _applyAzanAdjustAtDate(String key, DateTime base, DateTime date) {
    return base.add(Duration(minutes: _extraMinutesForPrayerAtDate(key, date)));
  }

  DateTime? _effectiveAdhanTimeForDay(PrayerCalendarDay day, int prayerId) {
    final manual = day.manualAdhanDateTimeForPrayerId(prayerId);
    if (manual != null) return manual;

    final generated = day.generatedDateTimeForPrayerId(prayerId);
    if (generated == null) return null;

    return _applyAzanAdjustAtDate(
      PrayerCalendarHelper.prayerKeyForId(prayerId),
      generated,
      day.gregorianDate,
    );
  }

  /// ✅ يرجّع وقت الصلاة "بعد التعديل" حسب id (1..6)
  /// 1=fajr, 2=sunrise, 3=dhuhr, 4=asr, 5=maghrib, 6=isha
  DateTime? adjustedPrayerTimeById(
    int id, {
    adhan.PrayerTimes? times,
    DateTime? date,
  }) {
    final normalized = _normalizedDate(date ?? DateTime.now());

    if (times != null) {
      final raw = _rawPrayerTimeFromTimes(id, times);
      if (raw == null) return null;
      return _applyAzanAdjustAtDate(
        PrayerCalendarHelper.prayerKeyForId(id),
        raw,
        normalized,
      );
    }

    final dayRecord = _syncDayRecordForDate(normalized);
    if (dayRecord != null) {
      return _effectiveAdhanTimeForDay(dayRecord, id);
    }

    final t = prayerTimes;
    if (t == null) return null;
    final raw = _rawPrayerTimeFromTimes(id, t);
    if (raw == null) return null;
    return _applyAzanAdjustAtDate(
      PrayerCalendarHelper.prayerKeyForId(id),
      raw,
      normalized,
    );
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

  void notifyAppChanged() => emit(AppChanged());

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

      final monthName = CacheHelper.getLang() == 'en'
          ? PrayerCalendarHelper.englishHijriMonths[h.month - 1]
          : h.monthName;

      final rawText = '$day $monthName $year';

      final formatted = LocalizationHelper.isArAndArNumberEnable()
          ? DateHelper.toArabicDigits(rawText)
          : DateHelper.toWesternDigits(rawText);
      isRamadan = month == '9' ? true : false;

      hijriDate = formatted;

      emit(AppChanged());
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

  double? get todayMaxTemp => displayWeather?.max;
  int? get todayWeatherCode => displayWeather?.weatherCode;
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
    try {
      final result = await _connectivity.checkConnectivity();
      return !result.contains(ConnectivityResult.none);
    } catch (_) {
      return false;
    }
  }

  bool? connectivity;
  void checkConnectivity() {
    _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> result,
    ) {
      if (result.contains(ConnectivityResult.none)) {
        connectivity = false;

        emit(AppInitial());
      } else {
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
    LatLng latLng = LatLng(geoResponse.latitude, geoResponse.longitude);
    CacheHelper.setCoordinates(latLng);
    final knownCity = LocationHelper.findSaudiCityByName(city);
    final cityOption = CityOption(
      nameEn: city,
      nameAr: knownCity?.nameAr ?? city,
      lat: latLng.latitude,
      lon: latLng.longitude,
      bundleId: knownCity?.bundleId,
      regionEn: knownCity?.regionEn,
      nameAliases: knownCity?.nameAliases ?? const <String>[],
    );
    _selectedCity = cityOption;
    unawaited(CacheHelper.setCity(cityOption));
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
      return null;
    }
  }

  List<MapEntry<String, DateTime>> _adjustedEntriesFromTimes(
    adhan.PrayerTimes t,
  ) {
    return <MapEntry<String, DateTime>>[
      MapEntry("fajr", _applyAzanAdjustAtDate("fajr", t.fajr, t.fajr)),
      MapEntry(
        "sunrise",
        _applyAzanAdjustAtDate("sunrise", t.sunrise, t.sunrise),
      ),
      MapEntry("dhuhr", _applyAzanAdjustAtDate("dhuhr", t.dhuhr, t.dhuhr)),
      MapEntry("asr", _applyAzanAdjustAtDate("asr", t.asr, t.asr)),
      MapEntry(
        "maghrib",
        _applyAzanAdjustAtDate("maghrib", t.maghrib, t.maghrib),
      ),
      MapEntry("isha", _applyAzanAdjustAtDate("isha", t.isha, t.isha)),
    ]..sort((a, b) => a.value.compareTo(b.value));
  }

  String? _nextPrayerKeyFromTimes(adhan.PrayerTimes t, {DateTime? now}) {
    final n = now ?? DateTime.now();
    final list = _adjustedEntriesFromTimes(t);
    for (final entry in list) {
      if (entry.value.isAfter(n)) return entry.key;
    }
    return null;
  }

  Future<LatLng?> _ensureSelectedCityCoordinates({String? city}) async {
    if (cityChanged) {
      final selected = getCity();
      if (selected?.lat != null && selected?.lon != null) {
        final latLng = LatLng(selected!.lat!, selected.lon!);
        await CacheHelper.setCoordinates(latLng);
        cityChanged = false;
        return latLng;
      }
      if (city != null && city.isNotEmpty) {
        final fetched = await fetchCityCoordinate(city);
        cityChanged = false;
        if (fetched != null) return fetched;
      }
      cityChanged = false;
    }

    var coords = CacheHelper.getCoordinates();
    if (coords != null) return coords;

    final selected = getCity();
    if (selected?.lat != null && selected?.lon != null) {
      coords = LatLng(selected!.lat!, selected.lon!);
      await CacheHelper.setCoordinates(coords);
      return coords;
    }

    if (city != null && city.isNotEmpty) {
      return fetchCityCoordinate(city);
    }

    return null;
  }

  List<int> _generatedMinutesFromTimes(adhan.PrayerTimes times) {
    return [
      PrayerCalendarHelper.minutesSinceMidnight(times.fajr),
      PrayerCalendarHelper.minutesSinceMidnight(times.sunrise),
      PrayerCalendarHelper.minutesSinceMidnight(times.dhuhr),
      PrayerCalendarHelper.minutesSinceMidnight(times.asr),
      PrayerCalendarHelper.minutesSinceMidnight(times.maghrib),
      PrayerCalendarHelper.minutesSinceMidnight(times.isha),
    ];
  }

  String _resolvePrayerCalendarCityKey({LatLng? coords}) {
    final cityKey = PrayerCalendarHelper.cityKeyFor(
      city: getCity(),
      coordinates: coords,
    );
    _activePrayerCalendarCityKey = cityKey;
    return cityKey;
  }

  Future<String> _loadCurrentOfficialSourceToken() async {
    final token = await officialCityCatalogService.loadOfficialSourceToken();
    await CacheHelper.setLastOfficialRefreshCheckAtMs(
      DateTime.now().millisecondsSinceEpoch,
    );
    return token;
  }

  Future<void> _acknowledgeOfficialSourceToken(String token) async {
    await CacheHelper.setLastSeenOfficialSourceToken(token);
    await CacheHelper.setLastOfficialRefreshCheckAtMs(
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  void _emitOfficialBundleSelectionRequired() {
    emit(
      OfficialBundleCitySelectionRequired(
        LocaleKeys.offline_calendar_city_reselect_required.tr(),
      ),
    );
  }

  void _emitOfficialBundleRefreshFailure() {
    emit(
      OfficialBundleRefreshFailure(
        LocaleKeys.offline_calendar_bundle_refresh_failed.tr(),
      ),
    );
  }

  Future<OfficialCityCatalogEntry?> _resolveSelectedCatalogEntry({
    String? city,
  }) async {
    final selected = getCity();
    final resolved = await officialCityCatalogService.resolveFromCityOption(
      selected,
    );
    if (resolved != null) {
      final upgradedCity = officialCityCatalogService.cityOptionFromEntry(
        resolved,
      );
      if (selected?.bundleId != upgradedCity.bundleId ||
          selected?.nameAr != upgradedCity.nameAr ||
          selected?.lat != upgradedCity.lat ||
          selected?.lon != upgradedCity.lon) {
        _selectedCity = upgradedCity;
        unawaited(CacheHelper.setCity(upgradedCity));
      }
      return resolved;
    }

    if (city == null || city.trim().isEmpty) {
      return null;
    }

    final options = await officialCityCatalogService.loadCityOptions();
    try {
      final matched = options.firstWhere(
        (entry) =>
            entry.nameEn.toLowerCase() == city.toLowerCase() ||
            entry.nameAr == city,
      );
      _selectedCity = matched;
      unawaited(CacheHelper.setCity(matched));
      return officialCityCatalogService.resolveFromCityOption(matched);
    } catch (_) {
      return null;
    }
  }

  Future<PrayerCalendarDay?> _loadOfficialPrayerCalendarDay(
    DateTime date, {
    OfficialCityCatalogEntry? catalogEntry,
    String? cityKey,
  }) async {
    final resolvedEntry = catalogEntry ?? await _resolveSelectedCatalogEntry();
    if (resolvedEntry == null) {
      if (getCity()?.hasBundleId ?? false) {
        _emitOfficialBundleSelectionRequired();
      }
      return null;
    }

    final resolvedCityKey = cityKey ?? _resolvePrayerCalendarCityKey();
    final normalized = _normalizedDate(date);
    final officialSourceToken = await _loadCurrentOfficialSourceToken();
    final stored = await PrayerCalendarHiveHelper.getDay(
      cityKey: resolvedCityKey,
      date: normalized,
    );
    if (stored != null && stored.hasFreshOfficialSource(officialSourceToken)) {
      await _acknowledgeOfficialSourceToken(officialSourceToken);
      return stored;
    }

    final scheduleDay = await ummAlQuraBundleService.loadDay(
      city: resolvedEntry,
      date: normalized,
    );
    if (scheduleDay == null) {
      _emitOfficialBundleRefreshFailure();
      return null;
    }

    final created = PrayerCalendarHiveHelper.mergeOfficialRefresh(
      freshDay: ummAlQuraBundleService.toPrayerCalendarDay(
        cityKey: resolvedCityKey,
        scheduleDay: scheduleDay,
        officialSourceToken: officialSourceToken,
      ),
      existingDay: stored,
      refreshedAt: DateTime.now(),
    );
    await PrayerCalendarHiveHelper.putDay(created);
    await _acknowledgeOfficialSourceToken(officialSourceToken);
    return created;
  }

  Future<List<PrayerCalendarDay>> _loadOfficialPrayerCalendarRange({
    required DateTime startInclusive,
    required DateTime endInclusive,
    OfficialCityCatalogEntry? catalogEntry,
  }) async {
    final resolvedEntry = catalogEntry ?? await _resolveSelectedCatalogEntry();
    if (resolvedEntry == null) {
      if (getCity()?.hasBundleId ?? false) {
        _emitOfficialBundleSelectionRequired();
      }
      return const <PrayerCalendarDay>[];
    }

    final resolvedCityKey = _resolvePrayerCalendarCityKey();
    final normalizedStart = _normalizedDate(startInclusive);
    final normalizedEnd = _normalizedDate(endInclusive);
    final endExclusive = normalizedEnd.add(const Duration(days: 1));
    final officialSourceToken = await _loadCurrentOfficialSourceToken();
    final cached = await PrayerCalendarHiveHelper.getDaysInRange(
      cityKey: resolvedCityKey,
      startInclusive: normalizedStart,
      endExclusive: endExclusive,
    );
    final cachedByYmd = {for (final day in cached) day.gregorianYmd: day};

    final officialDays = await ummAlQuraBundleService.loadRange(
      city: resolvedEntry,
      startInclusive: normalizedStart,
      endInclusive: normalizedEnd,
    );
    if (officialDays.isEmpty) {
      _emitOfficialBundleRefreshFailure();
      return const <PrayerCalendarDay>[];
    }

    final refreshedDays = <PrayerCalendarDay>[];
    for (final officialDay in officialDays) {
      final existing = cachedByYmd[officialDay.gregorianYmd];
      if (existing != null &&
          existing.hasFreshOfficialSource(officialSourceToken)) {
        continue;
      }

      refreshedDays.add(
        PrayerCalendarHiveHelper.mergeOfficialRefresh(
          freshDay: ummAlQuraBundleService.toPrayerCalendarDay(
            cityKey: resolvedCityKey,
            scheduleDay: officialDay,
            officialSourceToken: officialSourceToken,
          ),
          existingDay: existing,
          refreshedAt: DateTime.now(),
        ),
      );
    }

    if (refreshedDays.isNotEmpty) {
      await PrayerCalendarHiveHelper.putDays(refreshedDays);
    }
    await _acknowledgeOfficialSourceToken(officialSourceToken);

    final hydrated = await PrayerCalendarHiveHelper.getDaysInRange(
      cityKey: resolvedCityKey,
      startInclusive: normalizedStart,
      endExclusive: endExclusive,
    );
    hydrated.sort(
      (left, right) => left.gregorianDate.compareTo(right.gregorianDate),
    );
    return hydrated;
  }

  Future<List<PrayerCalendarDay>> loadSupportedHijriYearPrayerCalendar({
    required int hijriYear,
    String? city,
  }) async {
    final window = currentSupportedScheduleWindow;
    if (!window.supportedHijriYears.contains(hijriYear)) {
      emit(
        OfflineCalendarOutOfRange(
          LocaleKeys.offline_calendar_out_of_range.tr(),
        ),
      );
      return const <PrayerCalendarDay>[];
    }

    final range = PrayerCalendarHelper.hijriYearRangeFor(
      hijriYear: hijriYear,
      offsetDays: CacheHelper.getHijriOffsetDays(),
    );
    final officialEntry = await _resolveSelectedCatalogEntry(city: city);
    if (officialEntry == null) {
      return loadHijriYearPrayerCalendar(hijriYear: hijriYear, city: city);
    }

    return _loadOfficialPrayerCalendarRange(
      startInclusive: range.startInclusive,
      endInclusive: range.endExclusive.subtract(const Duration(days: 1)),
      catalogEntry: officialEntry,
    );
  }

  Future<String?> _ensureHijriYearCalendar({
    required LatLng coords,
    required int hijriYear,
  }) async {
    final cityKey = _resolvePrayerCalendarCityKey(coords: coords);
    final range = PrayerCalendarHelper.hijriYearRangeFor(
      hijriYear: hijriYear,
      offsetDays: CacheHelper.getHijriOffsetDays(),
    );
    final existingYmds = await PrayerCalendarHiveHelper.getExistingYmdsInRange(
      cityKey: cityKey,
      startInclusive: range.startInclusive,
      endExclusive: range.endExclusive,
    );

    final batch = <PrayerCalendarDay>[];
    for (
      var day = range.startInclusive;
      day.isBefore(range.endExclusive);
      day = day.add(const Duration(days: 1))
    ) {
      final normalizedDay = _normalizedDate(day);
      final ymd = PrayerCalendarHelper.ymdForDate(normalizedDay);
      if (existingYmds.contains(ymd)) continue;

      final rawTimes = await fetchPrayerTimesExactDay(coords, normalizedDay);
      if (rawTimes == null) continue;

      batch.add(
        PrayerCalendarDay.generated(
          cityKey: cityKey,
          date: normalizedDay,
          generatedAdhanMinutes: _generatedMinutesFromTimes(rawTimes),
        ),
      );

      if (batch.length >= 24) {
        await PrayerCalendarHiveHelper.putDays(batch);
        batch.clear();
        await Future<void>.delayed(Duration.zero);
      }
    }

    if (batch.isNotEmpty) {
      await PrayerCalendarHiveHelper.putDays(batch);
    }

    return cityKey;
  }

  Future<String?> _ensureCurrentHijriYearCalendar({
    required LatLng coords,
  }) async {
    return _ensureHijriYearCalendar(
      coords: coords,
      hijriYear: currentSupportedScheduleWindow.currentHijriYear,
    );
  }

  Future<PrayerCalendarDay?> _loadOrGeneratePrayerCalendarDay(
    DateTime date, {
    LatLng? coords,
    String? cityKey,
    OfficialCityCatalogEntry? catalogEntry,
  }) async {
    if ((catalogEntry ?? await _resolveSelectedCatalogEntry()) != null) {
      return _loadOfficialPrayerCalendarDay(
        date,
        catalogEntry: catalogEntry,
        cityKey: cityKey,
      );
    }

    if (coords == null) return null;
    final normalized = _normalizedDate(date);
    final resolvedCityKey =
        cityKey ??
        _activePrayerCalendarCityKey ??
        PrayerCalendarHelper.cityKeyFor(city: getCity(), coordinates: coords);

    final stored = await PrayerCalendarHiveHelper.getDay(
      cityKey: resolvedCityKey,
      date: normalized,
    );
    if (stored != null) return stored;

    final rawTimes = await fetchPrayerTimesExactDay(coords, normalized);
    if (rawTimes == null) return null;

    final created = PrayerCalendarDay.generated(
      cityKey: resolvedCityKey,
      date: normalized,
      generatedAdhanMinutes: _generatedMinutesFromTimes(rawTimes),
    );
    await PrayerCalendarHiveHelper.putDay(created);
    return created;
  }

  Future<List<PrayerCalendarDay>> loadCurrentHijriYearPrayerCalendar({
    String? city,
  }) async {
    return loadSupportedHijriYearPrayerCalendar(
      city: city,
      hijriYear: currentSupportedScheduleWindow.currentHijriYear,
    );
  }

  Future<List<PrayerCalendarDay>> loadHijriYearPrayerCalendar({
    required int hijriYear,
    String? city,
  }) async {
    final coords = await _ensureSelectedCityCoordinates(city: city);
    if (coords == null) return const <PrayerCalendarDay>[];

    final cityKey = await _ensureHijriYearCalendar(
      coords: coords,
      hijriYear: hijriYear,
    );
    if (cityKey == null) return const <PrayerCalendarDay>[];

    final range = PrayerCalendarHelper.hijriYearRangeFor(
      hijriYear: hijriYear,
      offsetDays: CacheHelper.getHijriOffsetDays(),
    );
    return PrayerCalendarHiveHelper.getDaysInRange(
      cityKey: cityKey,
      startInclusive: range.startInclusive,
      endExclusive: range.endExclusive,
    );
  }

  bool cityChanged = false;

  void assignCityChanged(bool value) {
    cityChanged = value;
  }

  Prayer? nextFajrPrayer;

  Future<void> initializePrayerTimes({
    String? city,
    required BuildContext context,
  }) async {
    try {
      final hasNet = await _hasConnection;
      connectivity = hasNet;

      emit(FetchPrayerTimesLoading());

      final officialEntry = await _resolveSelectedCatalogEntry(city: city);
      final todayDate = _normalizedDate(DateTime.now());
      final tomorrowDate = todayDate.add(const Duration(days: 1));

      if (officialEntry != null) {
        final cityKey = _resolvePrayerCalendarCityKey();
        prayerTimes = null;
        _todayPrayerCalendarDay = await _loadOfficialPrayerCalendarDay(
          todayDate,
          catalogEntry: officialEntry,
          cityKey: cityKey,
        );
        _tomorrowPrayerCalendarDay = await _loadOfficialPrayerCalendarDay(
          tomorrowDate,
          catalogEntry: officialEntry,
          cityKey: cityKey,
        );

        if (_tomorrowPrayerCalendarDay != null) {
          nextFajrPrayer = _mapPrayerCalendarDayToPrayers(
            _tomorrowPrayerCalendarDay!,
            context: context,
            targetDate: tomorrowDate,
          ).first;
        } else {
          nextFajrPrayer = null;
        }

        if (_todayPrayerCalendarDay != null) {
          emit(FetchPrayerTimesSuccess());
        } else {
          emit(
            FetchPrayerTimesFailure(
              LocaleKeys.something_went_wrong_please_try_again.tr(),
            ),
          );
        }
        return;
      }

      if (getCity()?.hasBundleId ?? false) {
        _emitOfficialBundleSelectionRequired();
        return;
      }

      final coords = await _ensureSelectedCityCoordinates(city: city);
      if (coords == null) {
        emit(
          FetchPrayerTimesFailure(
            LocaleKeys.something_went_wrong_please_try_again.tr(),
          ),
        );
        return;
      }

      final cityKey = await _ensureCurrentHijriYearCalendar(coords: coords);

      _todayPrayerCalendarDay = await _loadOrGeneratePrayerCalendarDay(
        todayDate,
        coords: coords,
        cityKey: cityKey,
      );
      _tomorrowPrayerCalendarDay = await _loadOrGeneratePrayerCalendarDay(
        tomorrowDate,
        coords: coords,
        cityKey: cityKey,
      );

      final todayTimes = await fetchPrayerTimesExactDay(
        coords,
        todayDate,
        storeToMain: true,
      );

      if (_tomorrowPrayerCalendarDay != null) {
        nextFajrPrayer = _mapPrayerCalendarDayToPrayers(
          _tomorrowPrayerCalendarDay!,
          context: context,
          targetDate: tomorrowDate,
        ).first;
      } else {
        final tomorrowTimes = await fetchPrayerTimesExactDay(
          coords,
          tomorrowDate,
        );
        if (tomorrowTimes != null) {
          nextFajrPrayer = _mapToPrayers(
            tomorrowTimes,
            context: context,
            targetDate: tomorrowDate,
          ).first;
        }
      }

      if (todayTimes != null || _todayPrayerCalendarDay != null) {
        emit(FetchPrayerTimesSuccess());
      } else {
        emit(
          FetchPrayerTimesFailure(
            LocaleKeys.something_went_wrong_please_try_again.tr(),
          ),
        );
      }
    } catch (e) {}
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

  Prayer _buildPrayerItem({
    required int id,
    required String title,
    required DateTime? dateTime,
  }) {
    if (dateTime == null) {
      return Prayer(
        id: id,
        title: title,
        time: null,
        dateTime: null,
        time24: null,
      );
    }

    return Prayer(
      id: id,
      title: title,
      time: _time12(dateTime),
      dateTime: dateTime,
      time24: _time24(dateTime),
    );
  }

  List<Prayer> _emptyPrayersForDate(DateTime targetDate) {
    return [
      _buildPrayerItem(id: 1, title: LocaleKeys.fajr.tr(), dateTime: null),
      _buildPrayerItem(id: 2, title: LocaleKeys.sunrise.tr(), dateTime: null),
      _buildPrayerItem(
        id: 3,
        title: _dhuhrTitleForDate(targetDate),
        dateTime: null,
      ),
      _buildPrayerItem(id: 4, title: LocaleKeys.asr.tr(), dateTime: null),
      _buildPrayerItem(id: 5, title: LocaleKeys.maghrib.tr(), dateTime: null),
      _buildPrayerItem(id: 6, title: LocaleKeys.isha.tr(), dateTime: null),
    ];
  }

  List<Prayer> _mapToPrayers(
    adhan.PrayerTimes? times, {
    required BuildContext context,
    DateTime? targetDate,
  }) {
    final effectiveDate = _normalizedDate(targetDate ?? DateTime.now());

    if (times == null) {
      return _emptyPrayersForDate(effectiveDate);
    }

    final fajr = _applyAzanAdjustAtDate("fajr", times.fajr, effectiveDate);
    final sunrise = _applyAzanAdjustAtDate(
      "sunrise",
      times.sunrise,
      effectiveDate,
    );
    final dhuhr = _applyAzanAdjustAtDate("dhuhr", times.dhuhr, effectiveDate);
    final asr = _applyAzanAdjustAtDate("asr", times.asr, effectiveDate);
    final maghrib = _applyAzanAdjustAtDate(
      "maghrib",
      times.maghrib,
      effectiveDate,
    );
    final isha = _applyAzanAdjustAtDate("isha", times.isha, effectiveDate);

    return [
      _buildPrayerItem(id: 1, title: LocaleKeys.fajr.tr(), dateTime: fajr),
      _buildPrayerItem(
        id: 2,
        title: LocaleKeys.sunrise.tr(),
        dateTime: sunrise,
      ),
      _buildPrayerItem(
        id: 3,
        title: _dhuhrTitleForDate(effectiveDate),
        dateTime: dhuhr,
      ),
      _buildPrayerItem(id: 4, title: LocaleKeys.asr.tr(), dateTime: asr),
      _buildPrayerItem(
        id: 5,
        title: LocaleKeys.maghrib.tr(),
        dateTime: maghrib,
      ),
      _buildPrayerItem(id: 6, title: LocaleKeys.isha.tr(), dateTime: isha),
    ];
  }

  List<Prayer> _mapPrayerCalendarDayToPrayers(
    PrayerCalendarDay day, {
    required BuildContext context,
    DateTime? targetDate,
  }) {
    final effectiveDate = _normalizedDate(targetDate ?? day.gregorianDate);
    return [
      _buildPrayerItem(
        id: 1,
        title: LocaleKeys.fajr.tr(),
        dateTime: _effectiveAdhanTimeForDay(day, 1),
      ),
      _buildPrayerItem(
        id: 2,
        title: LocaleKeys.sunrise.tr(),
        dateTime: _effectiveAdhanTimeForDay(day, 2),
      ),
      _buildPrayerItem(
        id: 3,
        title: _dhuhrTitleForDate(effectiveDate),
        dateTime: _effectiveAdhanTimeForDay(day, 3),
      ),
      _buildPrayerItem(
        id: 4,
        title: LocaleKeys.asr.tr(),
        dateTime: _effectiveAdhanTimeForDay(day, 4),
      ),
      _buildPrayerItem(
        id: 5,
        title: LocaleKeys.maghrib.tr(),
        dateTime: _effectiveAdhanTimeForDay(day, 5),
      ),
      _buildPrayerItem(
        id: 6,
        title: LocaleKeys.isha.tr(),
        dateTime: _effectiveAdhanTimeForDay(day, 6),
      ),
    ];
  }

  List<Prayer> prayers(BuildContext context, {DateTime? date}) {
    final targetDate = _normalizedDate(date ?? DateTime.now());
    final dayRecord = _syncDayRecordForDate(targetDate);
    if (dayRecord != null) {
      return _mapPrayerCalendarDayToPrayers(
        dayRecord,
        context: context,
        targetDate: targetDate,
      );
    }
    return _mapToPrayers(prayerTimes, context: context, targetDate: targetDate);
  }

  Future<Prayer?> nextPrayer(BuildContext context) async {
    final todayDate = _normalizedDate(DateTime.now());
    final list = prayers(context, date: todayDate);
    final now = DateTime.now();

    for (final p in list) {
      final dt = p.dateTime;
      if (dt != null && dt.isAfter(now)) return p;
    }

    // لو خلصنا صلوات اليوم -> هات بكرة كـ nextPrayer فقط
    final tomorrowDate = todayDate.add(const Duration(days: 1));
    final officialEntry = await _resolveSelectedCatalogEntry();
    final tomorrowDay =
        _tomorrowPrayerCalendarDay ??
        await _loadOrGeneratePrayerCalendarDay(
          tomorrowDate,
          coords: CacheHelper.getCoordinates(),
          cityKey: _activePrayerCalendarCityKey,
          catalogEntry: officialEntry,
        );
    if (tomorrowDay != null) {
      _tomorrowPrayerCalendarDay = tomorrowDay;
      final tomorrowPrayers = _mapPrayerCalendarDayToPrayers(
        tomorrowDay,
        context: context,
        targetDate: tomorrowDate,
      );
      return tomorrowPrayers.isNotEmpty ? tomorrowPrayers.first : null;
    }

    final coords = CacheHelper.getCoordinates();
    if (coords == null) return null;

    final tomorrowTimes = await fetchPrayerTimesExactDay(coords, tomorrowDate);
    if (tomorrowTimes == null) return null;

    final tomorrowPrayers = _mapToPrayers(
      tomorrowTimes,
      context: context,
      targetDate: tomorrowDate,
    );
    return tomorrowPrayers.isNotEmpty ? tomorrowPrayers.first : null;
  }

  List<Dhikr>? adhkarList;
  Future<void> assignAdhkar() async {
    emit(AppInitial());
    adhkarList = await DhikrHiveHelper.getAllDhikr();
    emit(AppChanged());
  }

  List<Dhikr>? slideList;
  Future<void> assignSlides() async {
    emit(AppInitial());
    slideList = await SlideHiveHelper.getAllSlides();
    emit(AppChanged());
  }

  List<DisplayAnnouncement>? displayAnnouncementList;
  Future<void> assignDisplayAnnouncements() async {
    emit(AppInitial());
    displayAnnouncementList =
        await DisplayBoardHiveHelper.getAllAnnouncements();
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

  Future<List<CityOption>> loadOfflineCityOptions() {
    return officialCityCatalogService.loadCityOptions();
  }

  // CityOption? getCity() {
  //   emit(AppInitial());
  //   emit(AppChanged());
  //   return CacheHelper.getCity();
  // }

  void setCity(CityOption city) {
    emit(AppInitial());
    _selectedCity = city;
    _todayPrayerCalendarDay = null;
    _tomorrowPrayerCalendarDay = null;
    _activePrayerCalendarCityKey = null;
    prayerTimes = null;
    if (city.lat != null && city.lon != null) {
      unawaited(CacheHelper.setCoordinates(LatLng(city.lat!, city.lon!)));
    } else {
      unawaited(CacheHelper.removeCoordinates());
    }
    unawaited(CacheHelper.setCity(city));
    emit(AppChanged());
  }

  CityOption? getCity() => _selectedCity ??= CacheHelper.getCity();
  String? getCountry() => CacheHelper.getCountry();

  String clearCity() {
    _selectedCity = null;
    _todayPrayerCalendarDay = null;
    _tomorrowPrayerCalendarDay = null;
    _activePrayerCalendarCityKey = null;
    prayerTimes = null;
    unawaited(CacheHelper.removeCity());
    unawaited(CacheHelper.removeCoordinates());
    return '';
  }

  SupportedScheduleWindow get currentSupportedScheduleWindow =>
      PrayerCalendarHelper.currentSupportedScheduleWindow(
        offsetDays: CacheHelper.getHijriOffsetDays(),
      );

  HijriYearRange get currentDisplayedHijriYearRange =>
      PrayerCalendarHelper.hijriYearRangeFor(
        hijriYear: currentSupportedScheduleWindow.currentHijriYear,
        offsetDays: CacheHelper.getHijriOffsetDays(),
      );

  GregorianCoverageWindow get currentGregorianCoverageWindow =>
      currentSupportedScheduleWindow;

  List<int> get supportedHijriYears =>
      currentSupportedScheduleWindow.supportedHijriYears;

  List<int> get supportedGregorianYears => supportedHijriYears;

  bool get hasPrayerSchedule =>
      _todayPrayerCalendarDay != null || prayerTimes != null;

  DateAvailabilityState dateAvailabilityFor(DateTime date) {
    return currentSupportedScheduleWindow.availabilityFor(date);
  }

  bool isPrayerCalendarDateEditable(DateTime date) {
    return dateAvailabilityFor(date) == DateAvailabilityState.selectable;
  }

  DateTime? effectiveAdhanTimeForCalendarDay(
    PrayerCalendarDay day,
    int prayerId,
  ) {
    return _effectiveAdhanTimeForDay(day, prayerId);
  }

  Future<List<int>> _loadBaseIqamaMinutes() async {
    if (_baseIqamaMinutes != null && _baseIqamaMinutes!.length >= 6) {
      return List<int>.from(_baseIqamaMinutes!);
    }

    final loaded = await IqamaHiveHelper.loadIqamaMinutes(prayerCount: 6);
    _baseIqamaMinutes = List<int>.from(loaded);
    return List<int>.from(_baseIqamaMinutes!);
  }

  Future<List<int>> getStoredIqamaMinutes() async {
    return _loadBaseIqamaMinutes();
  }

  Future<List<int>> defaultIqamaOffsetsForDate(DateTime date) async {
    final baseMinutes = await _loadBaseIqamaMinutes();
    return PrayerCalendarHelper.defaultIqamaMinutesForDate(
      baseIqamaMinutes: baseMinutes,
      date: _normalizedDate(date),
      fridayMinutes: CacheHelper.getFridayTime(),
    );
  }

  DateTime? effectiveIqamaTimeForCalendarDay(
    PrayerCalendarDay day,
    int prayerId, {
    List<int>? defaultIqamaOffsets,
  }) {
    final manual = day.manualIqamaDateTimeForPrayerId(prayerId);
    if (manual != null) return manual;

    final adhanTime = _effectiveAdhanTimeForDay(day, prayerId);
    if (adhanTime == null) return null;

    final defaultOffset =
        defaultIqamaOffsets != null &&
            prayerId > 0 &&
            prayerId <= defaultIqamaOffsets.length
        ? defaultIqamaOffsets[prayerId - 1]
        : 10;
    return adhanTime.add(Duration(minutes: defaultOffset));
  }

  Future<List<int>> _effectiveIqamaOffsetsForDate(
    DateTime date, {
    PrayerCalendarDay? day,
  }) async {
    final normalized = _normalizedDate(date);
    final defaultOffsets = await defaultIqamaOffsetsForDate(normalized);
    final dayRecord = day ?? _syncDayRecordForDate(normalized);
    if (dayRecord == null) return defaultOffsets;

    return List<int>.generate(defaultOffsets.length, (index) {
      final prayerId = index + 1;
      final manualIqama = dayRecord.manualIqamaDateTimeForPrayerId(prayerId);
      final effectiveAdhan = _effectiveAdhanTimeForDay(dayRecord, prayerId);
      if (manualIqama == null || effectiveAdhan == null) {
        return defaultOffsets[index];
      }
      return manualIqama.difference(effectiveAdhan).inMinutes;
    });
  }

  Future<PrayerCalendarDay?> savePrayerCalendarDayOverrides({
    required DateTime date,
    required Map<int, int> manualAdhanMinutesByPrayerId,
    required Map<int, int> manualIqamaMinutesByPrayerId,
    String? city,
  }) async {
    final normalized = _normalizedDate(date);
    final coords = await _ensureSelectedCityCoordinates(city: city);
    if (coords == null) return null;

    final cityKey = _resolvePrayerCalendarCityKey(coords: coords);
    final current = await _loadOrGeneratePrayerCalendarDay(
      normalized,
      coords: coords,
      cityKey: cityKey,
    );
    if (current == null) return null;

    final updated = current.copyWith(
      manualAdhanMinutesByPrayerId: Map<int, int>.from(
        manualAdhanMinutesByPrayerId,
      ),
      manualIqamaMinutesByPrayerId: Map<int, int>.from(
        manualIqamaMinutesByPrayerId,
      ),
      updatedAtMs: DateTime.now().millisecondsSinceEpoch,
    );
    await PrayerCalendarHiveHelper.putDay(updated);

    if (_isSameCalendarDay(normalized, DateTime.now())) {
      _todayPrayerCalendarDay = updated;
      await getIqamaTime();
    }

    if (_isSameCalendarDay(
      normalized,
      DateTime.now().add(const Duration(days: 1)),
    )) {
      _tomorrowPrayerCalendarDay = updated;
      nextFajrPrayer = _buildPrayerItem(
        id: 1,
        title: LocaleKeys.fajr.tr(),
        dateTime: _effectiveAdhanTimeForDay(updated, 1),
      );
    }

    emit(AppChanged());
    return updated;
  }

  Future<PrayerCalendarDay?> resetPrayerCalendarDayOverrides({
    required DateTime date,
    String? city,
  }) async {
    final normalized = _normalizedDate(date);
    final coords = await _ensureSelectedCityCoordinates(city: city);
    if (coords == null) return null;

    final cityKey = _resolvePrayerCalendarCityKey(coords: coords);
    final current = await _loadOrGeneratePrayerCalendarDay(
      normalized,
      coords: coords,
      cityKey: cityKey,
    );
    if (current == null) return null;

    final reset = current.clearAllOverrides();
    await PrayerCalendarHiveHelper.putDay(reset);

    if (_isSameCalendarDay(normalized, DateTime.now())) {
      _todayPrayerCalendarDay = reset;
      await getIqamaTime();
    }

    if (_isSameCalendarDay(
      normalized,
      DateTime.now().add(const Duration(days: 1)),
    )) {
      _tomorrowPrayerCalendarDay = reset;
      nextFajrPrayer = _buildPrayerItem(
        id: 1,
        title: LocaleKeys.fajr.tr(),
        dateTime: _effectiveAdhanTimeForDay(reset, 1),
      );
    }

    emit(AppChanged());
    return reset;
  }

  List<int>? iqamaMinutes;
  Future<void> getIqamaTime() async {
    emit(AppInitial());
    final today = _normalizedDate(DateTime.now());
    iqamaMinutes = await _effectiveIqamaOffsetsForDate(
      today,
      day: _todayPrayerCalendarDay,
    );
    emit(AppChanged());
  }

  Future<void> saveIqamaTimes() async {
    emit(saveIqamaTimesLoading());
    try {
      await IqamaHiveHelper.saveIqamaMinutes(iqamaMinutes!);
      _baseIqamaMinutes = List<int>.from(iqamaMinutes!);
      iqamaMinutes = await _effectiveIqamaOffsetsForDate(
        _normalizedDate(DateTime.now()),
        day: _todayPrayerCalendarDay,
      );
      emit(saveIqamaTimesSuccess());
    } catch (e) {
      emit(saveIqamaTimesFailure());
    }
  }

  Future<void> saveBaseIqamaTimes(
    List<int> baseIqamaMinutes, {
    int? fridayMinutes,
  }) async {
    emit(saveIqamaTimesLoading());
    try {
      if (fridayMinutes != null) {
        await CacheHelper.setFridayTime(fridayMinutes);
      }
      await IqamaHiveHelper.saveIqamaMinutes(baseIqamaMinutes);
      _baseIqamaMinutes = List<int>.from(baseIqamaMinutes);
      iqamaMinutes = await _effectiveIqamaOffsetsForDate(
        _normalizedDate(DateTime.now()),
        day: _todayPrayerCalendarDay,
      );
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
      prayerCount: 5,
    );

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

    if (idx == null) return 7;
    // ''
    //     " prayersDuration${prayersDuration?[idx].toString()}"

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

  List<Dhikr>? get todaysSlides {
    if (slideList == null) return null;
    return slideList!
        .where((element) => element.active && element.isForDay(DateTime.now()))
        .toList();
  }

  List<DisplayAnnouncement>? get activeDisplayAnnouncements {
    if (displayAnnouncementList == null) return null;
    return displayAnnouncementList!.where((element) => element.active).toList();
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

  bool _homeBlackScreenVisible = false;
  bool _azanBlackScreenVisible = false;

  bool get isBlackScreenVisible =>
      _homeBlackScreenVisible || _azanBlackScreenVisible;
  bool get isAzanBlackScreenVisible => _azanBlackScreenVisible;

  void setHomeBlackScreenVisible(bool visible) {
    if (_homeBlackScreenVisible == visible) return;
    _homeBlackScreenVisible = visible;
    emit(AppChanged());
  }

  void setAzanBlackScreenVisible(bool visible) {
    if (_azanBlackScreenVisible == visible) return;
    _azanBlackScreenVisible = visible;
    emit(AppChanged());
  }

  void togglePrayerAzanPage() {
    emit(AppChanged());
    showPrayerAzanPage = !showPrayerAzanPage;
    emit(AppInitial());
  }

  void closePrayerAzanPage() {
    if (!showPrayerAzanPage) return;
    showPrayerAzanPage = false;
    emit(AppChanged());
  }

  void finishPrayerAzanCycle() {
    showPrayerAzanPage = false;
    startAzanAtIqamaPhase = false;
    isBetweenAdhanAndIqama = false;
    currentAdhanTime = null;
    currentIqamaTime = null;
    currentPrayerEndsAt = null;
    prayerCyclePhase = PrayerCyclePhase.ended;
    setAzanBlackScreenVisible(false);
    emit(AppChanged());
  }

  NextAdhan? nextAdhan;
  Prayer? nextPrayerVar;
  void assignNextPrayerVar(Prayer? prayer) {
    emit(AppInitial());
    nextPrayerVar = prayer;
    emit(AppChanged());
  }

  // =========================
  // Adhan → Iqama cycle state
  // =========================

  DateTime? currentAdhanTime;
  DateTime? currentIqamaTime;
  DateTime? currentPrayerEndsAt;
  PrayerCyclePhase prayerCyclePhase = PrayerCyclePhase.idle;
  bool isBetweenAdhanAndIqama = false;
  bool startAzanAtIqamaPhase = false;

  void startAdhanCycle({
    required Prayer prayer,
    required DateTime adhanTime,
    required DateTime iqamaTime,
  }) {
    currentPrayer = prayer;
    currentAdhanTime = adhanTime;
    currentIqamaTime = iqamaTime;
    isBetweenAdhanAndIqama = false; // يبدأ الأذان أولاً
    startAzanAtIqamaPhase = false;
    currentPrayerEndsAt = null;
    prayerCyclePhase = PrayerCyclePhase.adhan;
    setAzanBlackScreenVisible(false);
  }

  void markBetweenAdhanAndIqama() {
    if (currentIqamaTime == null) return;
    isBetweenAdhanAndIqama = true;
    startAzanAtIqamaPhase = false;
    prayerCyclePhase = PrayerCyclePhase.betweenAdhanAndIqama;
    emit(AppChanged());
  }

  void startIqamaPhase() {
    if (currentPrayer == null || currentPrayer?.id == 2) return;
    isBetweenAdhanAndIqama = false;
    startAzanAtIqamaPhase = true;
    showPrayerAzanPage = true;
    prayerCyclePhase = PrayerCyclePhase.iqama;
    emit(AppChanged());
  }

  void startPrayerPhase({required int durationMinutes, DateTime? startedAt}) {
    final start = startedAt ?? DateTime.now();
    showPrayerAzanPage = false;
    startAzanAtIqamaPhase = false;
    isBetweenAdhanAndIqama = false;
    prayerCyclePhase = PrayerCyclePhase.prayerActive;
    currentPrayerEndsAt = start.add(Duration(minutes: durationMinutes));

    if (!isPrayerActiveNow(start)) {
      finishPrayerAzanCycle();
      return;
    }

    setAzanBlackScreenVisible(shouldShowPrayerHideScreen(start));
    emit(AppChanged());
  }

  bool isPrayerActiveNow([DateTime? now]) {
    final effectiveNow = now ?? DateTime.now();
    return prayerCyclePhase == PrayerCyclePhase.prayerActive &&
        currentPrayerEndsAt != null &&
        effectiveNow.isBefore(currentPrayerEndsAt!);
  }

  bool shouldShowPrayerHideScreen([DateTime? now]) {
    return CacheHelper.getEnableHidingScreenDuringPrayer() &&
        isPrayerActiveNow(now);
  }

  void refreshPrayerCycle([DateTime? now]) {
    final effectiveNow = now ?? DateTime.now();
    if (prayerCyclePhase == PrayerCyclePhase.prayerActive &&
        currentPrayerEndsAt != null &&
        !effectiveNow.isBefore(currentPrayerEndsAt!)) {
      finishPrayerAzanCycle();
      return;
    }
    setAzanBlackScreenVisible(shouldShowPrayerHideScreen(effectiveNow));
  }

  void handleHideDuringPrayerSettingChanged(bool enabled, [DateTime? now]) {
    setAzanBlackScreenVisible(enabled && isPrayerActiveNow(now));
    emit(AppChanged());
  }

  Duration? remainingToIqama() {
    if (!isBetweenAdhanAndIqama || currentIqamaTime == null) return null;
    final now = DateTime.now();
    final diff = currentIqamaTime!.difference(now);
    if (diff.isNegative) return Duration.zero;
    return diff;
  }

  double iqamaProgress() {
    if (!isBetweenAdhanAndIqama ||
        currentIqamaTime == null ||
        currentAdhanTime == null) {
      return 0.0;
    }
    final now = DateTime.now();
    final total = currentIqamaTime!.difference(currentAdhanTime!).inSeconds;
    if (total <= 0) return 1.0;
    final elapsed = now.difference(currentAdhanTime!).inSeconds;
    final progress = elapsed / total;
    return progress.clamp(0.0, 1.0);
  }
}
