import 'dart:convert';

import 'package:azan/core/helpers/azan_adjust_model.dart';
import 'package:azan/core/models/city_option.dart';
import 'package:azan/core/models/latlng.dart';
import 'package:azan/core/utils/constants.dart';
import 'package:azan/core/utils/extenstions.dart';
import 'package:azan/gen/assets.gen.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:azan/views/change_%20background_settings/change_background_settings_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheHelper {
  static late SharedPreferences sharedPreferences;

  static const String _useMp3Azan = "_useMp3Azan"; // (1)
  static const String _useShortAzan = "_useShortAzan"; // (2)
  static const String _useShortIqama = "_useShortIqama"; // (3)

  static const String _kCurrentPrayerKey = "_currentPrayerKey";

  static const _language = 'LANGUAGE';
  static const _coordinate = "coordinate";
  static const _prayerTimes = "prayerTimes";
  static const _prayerTimesNotificationEnabled =
      "prayerTimesNotificationEnabled";
  static const _surahNumber = "surahNumber";
  static const _ayahNumber = "ayahNumber";
  static const _pageNumber = "pageNumber";
  static const _themeMode = "themeMode";
  static const _usableHeight = "usableHeight";
  static const _horizontalSafeArea = "horizontalSafeArea";
  static const _quranScreenData = "quranScreenData";
  static const _quranPagesLines = "quranPagesLines";
  static const _azkarNotficationEnabled = "azkarNotficationEnabled";
  static const _isAppConfigured = "isAppConfigured";
  static const _country = "country";
  static const _city = "city";
  static const _mosqueName = "mosqueName";
  static const _sliderOpened = "sliderOpened";
  static const _firstAppOpen = "firstAppOpen";
  static const _fixedDhikr = "fixedDhikr";
  static const _isIqamaAppTheme = "_isIqamaAppTheme";
  static const _isAzanAppTheme = "_isAzanAppTheme";
  static const _selectedBackground = "_selectedBackground";
  static const _palestinianFlag = "_palestinianFlag";
  static const _use24HourFormat = "_use24HourFormat";
  static const _isFullTimeEnabled = "_isFullTimeEnabled";
  static const _isPreviousPrayersDimmed = "_isPreviousPrayersDimmed";
  static const _isChangeCounterEnabled = "_isChangeCounterEnabled";
  static const _FontFamily = "_FontFamily";
  static const _azkarFontFamily = "_azkarFontFamily";
  static const _timeFontFamily = "_timeFontFamily";
  static const _timesFontFamily = "_timesFontFamily";
  static const _textsFontFamily = "_textsFontFamily";
  static const _arabicNumbersEnabled = "_arabicNumbersEnabled";
  static const _notificationMessageBeforeIqama =
      "_notificationMessageBeforeIqama";
  static const _fitrEid = "_fitrEid";
  static const _adhaEid = "_adhaEid";
  static const _showFitrEid = "_showFitrEid";
  static const _showAdhaEid = "_showAdhaEid";
  static const _enableCheckInternetConnection =
      "_enableCheckInternetConnection";
  static const _fridayTime = "_friDayTime";
  static const _enableHidingScreenDuringPrayer =
      "_enableHidingScreenDuringPrayer";
  static const _showTimeOnBlackScreen = "_showTimeOnBlackScreen";
  static const _showDateOnBlackScreen = "_showDateOnBlackScreen";

  static const _hideScreenAfterSunriseEnabled =
      "_hideScreenAfterSunriseEnabled";
  static const _hideScreenAfterSunriseMinutes =
      "_hideScreenAfterSunriseMinutes";

  static const _hideScreenAfterIshaaEnabled = "_hideScreenAfterIshaaEnabled";
  static const _hideScreenAfterIshaaMinutes = "_hideScreenAfterIshaaMinutes";
  static const _add30MinutesToIshaaInRamdan = "_add30MinutesToIshaaInRamdan";

  static const _isLandscape = "_isLandScape";
  static const String _kBgMode = 'bg_mode';
  static const String _kBgThemeIndex = 'bg_theme_index';
  static const String _kBgPerPrayer = 'bg_per_prayer_map';
  static const String _kBgPerDay = 'bg_per_day_map';
  static const String _kBgRandomPool = 'bg_random_pool';
  static const String _sliderTime = "sliderTime";
  static const String _hijriOffsetDays = "_hijriOffsetDays"; // int: -2..+2

  static const String _hijriOffsetDir = "_hijriOffsetDir"; // int: 1 or -1
  static const String _enableGlassPrayerRows = "_enableGlassPrayerRows";
  static const String _kAzanAdjustV1 = "_azanAdjustV1"; // json
  static const String _azanDuration = "_azanDuration";
  static const String _kMorningAzkarEnabled = 'morning_azkar_enabled';
  static const String _kEveningAzkarEnabled = 'evening_azkar_enabled';
  static const String _kMorningAzkarWindowMinutes =
      'morning_azkar_window_minutes';
  static const String _kEveningAzkarWindowMinutes =
      'evening_azkar_window_minutes';

  static const String _kAfterPrayerAzkarEnabled = 'after_prayer_azkar_enabled';
  static const String _kAfterPrayerAzkarWindowMinutes =
      'after_prayer_azkar_window_minutes';
  static const String _showSecondsInNextPrayer = "_showSecondsInNextPrayer";
  static const _mosqueLogoPathKey = 'mosque_logo_path';

  static init() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  static dynamic get({required String key}) {
    return sharedPreferences.get(key);
  }

  static Future<bool> save({
    required String key,
    required dynamic value,
  }) async {
    if (value is String) return await sharedPreferences.setString(key, value);
    if (value is bool) return await sharedPreferences.setBool(key, value);
    if (value is int) return await sharedPreferences.setInt(key, value);
    if (value is List<String>) {
      return await sharedPreferences.setStringList(key, value);
    }

    return await sharedPreferences.setDouble(key, value);
  }

  static Future<bool> remove({required String key}) async {
    return await sharedPreferences.remove(key);
  }

  static setLang(lang) async {
    await sharedPreferences.setString(_language, lang);
  }

  static String getLang() {
    return sharedPreferences.getString(_language) ?? "ar";
  }

  static setCoordinates(LatLng latLng) async {
    await save(
      key: _coordinate,
      value: [latLng.latitude.toString(), latLng.longitude.toString()],
    );
  }

  static removeCoordinates() async {
    await sharedPreferences.remove(_coordinate);
  }

  static setPrayersTimes(List<String> prayersTimes) async {
    await save(key: _prayerTimes, value: prayersTimes);
  }

  static List<String>? getPrayersTimes() {
    return sharedPreferences.getStringList(_prayerTimes);
  }

  static LatLng? getCoordinates() {
    final List<String>? data = sharedPreferences.getStringList(_coordinate);
    if (data != null) {
      return LatLng(double.parse(data[0]), double.parse(data[1]));
    }
    return null;
  }
  // =========================
  // Azan Adjustments (NEW)
  // =========================

  static Future<void> setAzanAdjustSettings(AzanAdjustSettings s) async {
    final fixed = s.normalized();
    await save(key: _kAzanAdjustV1, value: jsonEncode(fixed.toJson()));

    // ✅ compatibility مع المفتاح القديم
    await setAdd30MinutesToIshaaInRamdan(fixed.ramadanIshaPlus30);
  }

  static AzanAdjustSettings getAzanAdjustSettings({
    AzanAdjustSettings? fallback,
  }) {
    final raw = get(key: _kAzanAdjustV1);

    // ✅ لو موجود JSON جديد
    if (raw is String && raw.isNotEmpty) {
      try {
        final map = (jsonDecode(raw) as Map).cast<String, dynamic>();
        return AzanAdjustSettings.fromJson(map);
      } catch (_) {
        // لو JSON بايظ لأي سبب
        return fallback ?? _migrateOldToNewDefaults();
      }
    }

    // ✅ لو مش موجود (أول مرة) -> migrate من القديم
    return fallback ?? _migrateOldToNewDefaults();
  }

  static AzanAdjustSettings _migrateOldToNewDefaults() {
    // عندك مفتاح قديم لرمضان: _add30MinutesToIshaaInRamdan
    final ramadan = getAdd30MinutesToIshaaInRamdan();

    return AzanAdjustSettings.defaults().copyWith(
      ramadanIshaPlus30: ramadan,
      // باقي القيم default
    );
  }

  static bool getShowSecondsInNextPrayer() =>
      CacheHelper.get(key: _showSecondsInNextPrayer) ?? false;

  static Future<void> setShowSecondsInNextPrayer(bool v) async =>
      await CacheHelper.save(key: _showSecondsInNextPrayer, value: v);
  //remove
  static void removeSecondsInNextPrayer() async =>
      await CacheHelper.remove(key: _showSecondsInNextPrayer);

  static bool getMorningAzkarEnabled() =>
      CacheHelper.get(key: _kMorningAzkarEnabled) ?? true;

  static Future<void> setMorningAzkarEnabled(bool v) async =>
      await CacheHelper.save(key: _kMorningAzkarEnabled, value: v);

  static Future<void> setMosqueLogoPath(String path) async =>
      sharedPreferences.setString(_mosqueLogoPathKey, path);

  static String? getMosqueLogoPath() =>
      sharedPreferences.getString(_mosqueLogoPathKey);

  static Future<void> clearMosqueLogoPath() async =>
      sharedPreferences.remove(_mosqueLogoPathKey);
  static bool getEveningAzkarEnabled() =>
      CacheHelper.get(key: _kEveningAzkarEnabled) ?? true;

  static Future<void> setEveningAzkarEnabled(bool v) async =>
      await CacheHelper.save(key: _kEveningAzkarEnabled, value: v);

  static int getMorningAzkarWindowMinutes() =>
      CacheHelper.get(key: _kMorningAzkarWindowMinutes) ?? 5; // default = 2h

  static Future<void> setMorningAzkarWindowMinutes(int minutes) async =>
      await CacheHelper.save(key: _kMorningAzkarWindowMinutes, value: minutes);

  static int getEveningAzkarWindowMinutes() =>
      CacheHelper.get(key: _kEveningAzkarWindowMinutes) ?? 5; // default = 3h

  static Future<void> setEveningAzkarWindowMinutes(int minutes) async =>
      await CacheHelper.save(key: _kEveningAzkarWindowMinutes, value: minutes);
  static Future<void> removeAzanAdjustSettings() async {
    await sharedPreferences.remove(_kAzanAdjustV1);
  }

  static setPrayerTimesNotificationEnabled(bool value) async {
    await sharedPreferences.setBool(_prayerTimesNotificationEnabled, value);
  }

  static bool getPrayerTimesNotificationEnabled() {
    return sharedPreferences.getBool(_prayerTimesNotificationEnabled) ?? false;
  }

  static bool getAzkarNotficationEnabled() {
    return sharedPreferences.getBool(_azkarNotficationEnabled) ?? false;
  }

  static bool getAfterPrayerAzkarEnabled() =>
      CacheHelper.get(key: _kAfterPrayerAzkarEnabled) ?? false;

  static Future<void> setAfterPrayerAzkarEnabled(bool v) async =>
      await CacheHelper.save(key: _kAfterPrayerAzkarEnabled, value: v);

  static int getAfterPrayerAzkarWindowMinutes() =>
      CacheHelper.get(key: _kAfterPrayerAzkarWindowMinutes) ??
      5; // default = 20m

  static Future<void> setAfterPrayerAzkarWindowMinutes(int minutes) async =>
      await CacheHelper.save(
        key: _kAfterPrayerAzkarWindowMinutes,
        value: minutes,
      );

  static setAzkarNotficationEnabled(bool value) async {
    await sharedPreferences.setBool(_azkarNotficationEnabled, value);
  }

  static saveSurahNumber(int surahNo) {
    sharedPreferences.setInt(_surahNumber, surahNo);
  }

  static saveAyahNumber(int ayahNo) {
    sharedPreferences.setInt(_ayahNumber, ayahNo);
  }

  static int getSurahNumber() {
    return sharedPreferences.getInt(_surahNumber) ?? 1;
  }

  static int getAyahNumber() {
    return sharedPreferences.getInt(_ayahNumber) ?? 1;
  }

  static void setPageNumber(int page) {
    sharedPreferences.setInt(_pageNumber, page);
  }

  static int getPageNumber() {
    return sharedPreferences.getInt(_pageNumber) ?? 1;
  }

  static setThemeMode(String themeMode) async {
    await sharedPreferences.setString(_themeMode, themeMode);
  }

  static String getThemeMode() {
    return sharedPreferences.getString(_themeMode) ?? "light";
  }

  static setUsableHeight(double height) async {
    await sharedPreferences.setDouble(_usableHeight, height);
  }

  static double? getUsableHeight() {
    return sharedPreferences.getDouble(_usableHeight);
  }

  static setHorizontalSafeArea(double height) async {
    await sharedPreferences.setDouble(_horizontalSafeArea, height);
  }

  static double? getHorizontalSafeArea() {
    return sharedPreferences.getDouble(_horizontalSafeArea);
  }

  static Future<void> saveLinesCountMap(Map<int, int> map) async {
    final prefs = await SharedPreferences.getInstance();
    // نحول لماب<String, int> علشان JSON
    final converted = map.map((k, v) => MapEntry(k.toString(), v));
    await prefs.setString(_quranPagesLines, jsonEncode(converted));
  }

  static Future<Map<int, int>?> loadLinesCountMap() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_quranPagesLines);
    if (raw == null) return null;
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map((k, v) => MapEntry(int.parse(k), v as int));
  }

  static Future<void> clearLinesCountMap() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_quranPagesLines);
  }

  static saveIsAppConfigured(bool value) {
    sharedPreferences.setBool(_isAppConfigured, value);
  }

  static bool getIsAppConfigured() {
    return sharedPreferences.getBool(_isAppConfigured) ?? false;
  }

  static setCountry(String country) async {
    await sharedPreferences.setString(_country, country);
  }

  static String? getCountry() {
    return sharedPreferences.getString(_country);
  }

  // remove
  static removeCountry() async {
    await sharedPreferences.remove(_country);
  }

  static setCity(CityOption city) async {
    final jsonString = jsonEncode(city.toJson());
    await sharedPreferences.setString(_city, jsonString);
  }

  static CityOption? getCity() {
    final jsonString = sharedPreferences.getString(_city);
    if (jsonString == null) return null;

    try {
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      final result = CityOption.fromJson(map);
      return result;
    } catch (_) {
      return null;
    }
  }

  static removeCity() async {
    await sharedPreferences.remove(_city);
  }

  static setMosqueName(String mosqueName) async {
    await sharedPreferences.setString(_mosqueName, mosqueName);
  }

  static String? getMosqueName() {
    return sharedPreferences.getString(_mosqueName);
  }

  static removeMosqueName() async {
    await sharedPreferences.remove(_mosqueName);
  }

  static setSliderOpened(bool value) async {
    await sharedPreferences.setBool(_sliderOpened, value);
  }

  static bool getSliderOpened() {
    return sharedPreferences.getBool(_sliderOpened) ?? true;
  }

  // 1) Enable hiding during prayer
  static Future<void> setEnableHidingScreenDuringPrayer(bool v) async {
    await sharedPreferences.setBool(_enableHidingScreenDuringPrayer, v);
  }

  static bool getEnableHidingScreenDuringPrayer() {
    return sharedPreferences.getBool(_enableHidingScreenDuringPrayer) ?? true;
  }

  // 2) Show time/date on black screen
  static Future<void> setShowTimeOnBlackScreen(bool v) async {
    await sharedPreferences.setBool(_showTimeOnBlackScreen, v);
  }

  static bool getShowTimeOnBlackScreen() {
    return sharedPreferences.getBool(_showTimeOnBlackScreen) ?? true;
  }

  static Future<void> setShowDateOnBlackScreen(bool v) async {
    await sharedPreferences.setBool(_showDateOnBlackScreen, v);
  }

  static bool getShowDateOnBlackScreen() {
    return sharedPreferences.getBool(_showDateOnBlackScreen) ?? false;
  }

  // 3) Hide after sunrise
  static Future<void> setHideScreenAfterSunriseEnabled(bool v) async {
    await sharedPreferences.setBool(_hideScreenAfterSunriseEnabled, v);
  }

  static bool getHideScreenAfterSunriseEnabled() {
    return sharedPreferences.getBool(_hideScreenAfterSunriseEnabled) ?? false;
  }

  static Future<void> setHideScreenAfterSunriseMinutes(int v) async {
    await sharedPreferences.setInt(_hideScreenAfterSunriseMinutes, v);
  }

  static int getHideScreenAfterSunriseMinutes() {
    return sharedPreferences.getInt(_hideScreenAfterSunriseMinutes) ?? 30;
  }

  // 4) Hide after ishaa
  static Future<void> setHideScreenAfterIshaaEnabled(bool v) async {
    await sharedPreferences.setBool(_hideScreenAfterIshaaEnabled, v);
  }

  static bool getHideScreenAfterIshaaEnabled() {
    return sharedPreferences.getBool(_hideScreenAfterIshaaEnabled) ?? false;
  }

  static Future<void> setHideScreenAfterIshaaMinutes(int v) async {
    await sharedPreferences.setInt(_hideScreenAfterIshaaMinutes, v);
  }

  static int getHideScreenAfterIshaaMinutes() {
    return sharedPreferences.getInt(_hideScreenAfterIshaaMinutes) ?? 60;
  }

  static removeSliderOpened() async {
    await sharedPreferences.remove(_sliderOpened);
  }

  static setFirstAppOpen(bool value) async {
    await sharedPreferences.setBool(_firstAppOpen, value);
  }

  static bool getFirstAppOpen() {
    return sharedPreferences.getBool(_firstAppOpen) ?? false;
  }

  static removeFirstAppOpen() async {
    await sharedPreferences.remove(_firstAppOpen);
  }

  static setFixedDhikr(String value) async {
    await sharedPreferences.setString(_fixedDhikr, value);
  }

  static String getFixedDhikr() {
    return sharedPreferences.getString(_fixedDhikr) ?? fixedDhikr;
  }

  static removeFixedDhikr() async {
    await sharedPreferences.remove(_fixedDhikr);
  }

  static setIsIqamaAppTheme(bool value) async {
    await sharedPreferences.setBool(_isIqamaAppTheme, value);
  }

  static bool getIsIqamaAppTheme() {
    return sharedPreferences.getBool(_isIqamaAppTheme) ?? true;
  }

  static removeIsIqamaAppTheme() async {
    await sharedPreferences.remove(_isIqamaAppTheme);
  }

  static setIsAzanAppTheme(bool value) async {
    await sharedPreferences.setBool(_isAzanAppTheme, value);
  }

  static bool getIsAzanAppTheme() {
    return sharedPreferences.getBool(_isAzanAppTheme) ?? true;
  }

  static removeIsAzanAppTheme() async {
    await sharedPreferences.remove(_isAzanAppTheme);
  }

  static setSelectedBackground(String value) async {
    await sharedPreferences.setString(_selectedBackground, value);
  }

  static String _dayKey(int weekday) {
    switch (weekday) {
      case DateTime.sunday:
        return "sun";
      case DateTime.monday:
        return "mon";
      case DateTime.tuesday:
        return "tue";
      case DateTime.wednesday:
        return "wed";
      case DateTime.thursday:
        return "thu";
      case DateTime.friday:
        return "fri";
      case DateTime.saturday:
        return "sat";
      default:
        return "sun";
    }
  }

  static String getSelectedBackground() {
    final all = getAllBackgrounds();
    if (all.isEmpty) return Assets.images.home.path;

    int safeIndex(int i) {
      if (i < 0) return 0;
      if (i >= all.length) return all.length - 1;
      return i;
    }

    final mode = getBackgroundChangeMode();
    final now = DateTime.now();

    // manual
    if (mode == BackgroundChangeMode.manual) {
      final idx = getBackgroundThemeIndex(fallback: 0);
      return all[safeIndex(idx)];
    }

    // perPrayer
    if (mode == BackgroundChangeMode.perPrayer) {
      final map = getBackgroundPerPrayerMap();
      final prayerKey = getCurrentPrayerKey();
      final idx = map[prayerKey ?? ""] ?? getBackgroundThemeIndex(fallback: 0);
      return all[safeIndex(idx)];
    }

    // perDay
    if (mode == BackgroundChangeMode.perDay) {
      final map = getBackgroundPerDayMap();
      final key = _dayKey(now.weekday);
      final idx = map[key] ?? getBackgroundThemeIndex(fallback: 0);
      return all[safeIndex(idx)];
    }

    // randomPool
    final pool = getBackgroundRandomPool();
    if (pool.isEmpty) {
      final idx = getBackgroundThemeIndex(fallback: 0);
      return all[safeIndex(idx)];
    }

    final daySeed = now.year * 10000 + now.month * 100 + now.day;
    final pick = pool[daySeed % pool.length];
    return all[safeIndex(pick)];
  }

  static removeSelectedBackground() async {
    await sharedPreferences.remove(_selectedBackground);
  }

  static setpalestinianFlag(bool value) async {
    await sharedPreferences.setBool(_palestinianFlag, value);
  }

  static bool getpalestinianFlag() {
    return sharedPreferences.getBool(_palestinianFlag) ?? false;
  }

  static removepalestinianFlag() async {
    await sharedPreferences.remove(_palestinianFlag);
  }

  static Future<void> setUse24HoursFormat(bool value) async {
    await sharedPreferences.setBool(_use24HourFormat, value);
  }

  static bool getUse24HoursFormat() {
    return sharedPreferences.getBool(_use24HourFormat) ?? false;
  }

  static removeUse24HoursFormat() async {
    await sharedPreferences.remove(_use24HourFormat);
  }

  static setIsFullTimeEnabled(bool value) async {
    await sharedPreferences.setBool(_isFullTimeEnabled, value);
  }

  static bool getIsFullTimeEnabled() {
    return sharedPreferences.getBool(_isFullTimeEnabled) ?? false;
  }

  static removeIsFullTimeEnabled() async {
    await sharedPreferences.remove(_isFullTimeEnabled);
  }

  static setIsPreviousPrayersDimmed(bool value) async {
    await sharedPreferences.setBool(_isPreviousPrayersDimmed, value);
  }

  static bool getIsPreviousPrayersDimmed() {
    return sharedPreferences.getBool(_isPreviousPrayersDimmed) ?? false;
  }

  /*************  ✨ Windsurf Command ⭐  *************/
  /*******  6b227387-2993-445b-a510-0b17204e3508  *******/
  static removeIsPreviousPrayersDimmed() async {
    await sharedPreferences.remove(_isPreviousPrayersDimmed);
  }

  static setIsChangeCounterEnabled(bool value) async {
    await sharedPreferences.setBool(_isChangeCounterEnabled, value);
  }

  static bool getIsChangeCounterEnabled() {
    return sharedPreferences.getBool(_isChangeCounterEnabled) ?? false;
  }

  static removeIsChangeCounterEnabled() async {
    await sharedPreferences.remove(_isChangeCounterEnabled);
  }

  static setFontFamily(String value) async {
    await sharedPreferences.setString(_FontFamily, value);
  }

  static String getFontFamily() {
    return sharedPreferences.getString(_FontFamily) ?? sultanFont;
  }

  static removeFontFamily() async {
    await sharedPreferences.remove(_FontFamily);
  }

  static setAzkarFontFamily(String value) async {
    await sharedPreferences.setString(_azkarFontFamily, value);
  }

  static String getAzkarFontFamily() {
    return sharedPreferences.getString(_azkarFontFamily) ?? ksaFont;
  }

  static removeAzkarFontFamily() {
    sharedPreferences.remove(_azkarFontFamily);
  }

  static setTimeFontFamily(String value) async {
    sharedPreferences.setString(_timeFontFamily, value);
  }

  static String getTimeFontFamily() {
    return sharedPreferences.getString(_timeFontFamily) ?? freeSerifBoldFont;
  }

  static removeTimeFontFamily() {
    sharedPreferences.remove(_timeFontFamily);
  }

  static setTimesFontFamily(String value) async {
    await sharedPreferences.setString(_timesFontFamily, value);
  }

  static String getTimesFontFamily() {
    return sharedPreferences.getString(_timesFontFamily) ?? freeSerifBoldFont;
  }

  static removeTimesFontFamily() {
    sharedPreferences.remove(_timesFontFamily);
  }

  static setTextsFontFamily(String value) async {
    await sharedPreferences.setString(_textsFontFamily, value);
  }

  static String getTextsFontFamily() {
    return sharedPreferences.getString(_textsFontFamily) ?? amiriFont;
  }

  static removeTextsFontFamily() {
    sharedPreferences.remove(_textsFontFamily);
  }

  static setIsArabicNumbersEnabled(bool value) async {
    await sharedPreferences.setBool(_arabicNumbersEnabled, value);
  }

  static getIsArabicNumbersEnabled() {
    return sharedPreferences.getBool(_arabicNumbersEnabled) ?? false;
  }

  static removeIsArabicNumbersEnabled() {
    sharedPreferences.remove(_arabicNumbersEnabled);
  }

  static setNotificationMessageBeforeIqama(String value) async {
    await sharedPreferences.setString(_notificationMessageBeforeIqama, value);
  }

  static String getNotificationMessageBeforeIqama() {
    return sharedPreferences.getString(_notificationMessageBeforeIqama) ??
        LocaleKeys.please_turn_off_the_phone.tr();
  }

  static removeNotificationMessageBeforeIqama() {
    sharedPreferences.remove(_notificationMessageBeforeIqama);
  }

  static setFitrEid(String date, String time) async {
    await sharedPreferences.setStringList(_fitrEid, [date, time]);
  }

  static List<String>? getFitrEid() {
    return sharedPreferences.getStringList(_fitrEid);
  }

  static removeFitrEid() {
    sharedPreferences.remove(_fitrEid);
  }

  static setAdhaEid(String date, String time) async {
    await sharedPreferences.setStringList(_adhaEid, [date, time]);
  }

  static List<String>? getAdhaEid() {
    return sharedPreferences.getStringList(_adhaEid);
  }

  static removeAdhaEid() {
    sharedPreferences.remove(_adhaEid);
  }

  static setShowFitrEid(bool value) async {
    await sharedPreferences.setBool(_showFitrEid, value);
  }

  static getShowFitrEid() {
    return sharedPreferences.getBool(_showFitrEid) ?? false;
  }

  static removeShowFitrEid() {
    sharedPreferences.remove(_showFitrEid);
  }

  static setShowAdhaEid(bool value) async {
    await sharedPreferences.setBool(_showAdhaEid, value);
  }

  static getShowAdhaEid() {
    return sharedPreferences.getBool(_showAdhaEid) ?? false;
  }

  static removeShowAdhaEid() {
    sharedPreferences.remove(_showAdhaEid);
  }

  static setEnableCheckInternetConnection(bool value) async {
    await sharedPreferences.setBool(_enableCheckInternetConnection, value);
  }

  static bool getEnableCheckInternetConnection() {
    return sharedPreferences.getBool(_enableCheckInternetConnection) ?? false;
  }

  static removeEnableCheckInternetConnection() {
    sharedPreferences.remove(_enableCheckInternetConnection);
  }

  static setFridayTime(int value) async {
    await sharedPreferences.setInt(_fridayTime, value);
  }

  static int getFridayTime() {
    return sharedPreferences.getInt(_fridayTime) ?? 10;
  }

  static removeFridayTime() {
    sharedPreferences.remove(_fridayTime);
  }

  static setIsLandscape(bool value) async {
    await sharedPreferences.setBool(_isLandscape, value);
  }

  static getIsLandscape() {
    return sharedPreferences.getBool(_isLandscape) ?? false;
  }

  static removeIsLandscape() {
    sharedPreferences.remove(_isLandscape);
  }

  // =========================
  // Background Advanced Settings
  // =========================

  static Future<void> setBackgroundChangeMode(BackgroundChangeMode mode) async {
    await save(key: _kBgMode, value: mode.id);
  }

  static BackgroundChangeMode getBackgroundChangeMode() {
    final id = get(key: _kBgMode) as int?;
    return BackgroundChangeModeX.fromId(id);
  }

  static Future<void> setBackgroundThemeIndex(int index) async {
    await save(key: _kBgThemeIndex, value: index);
  }

  static int getBackgroundThemeIndex({int fallback = 0}) {
    return (get(key: _kBgThemeIndex) as int?) ?? fallback;
  }

  /// map: {"fajr":7,"sunrise":13,"dhuhr":0,"asr":16,"maghrib":33,"isha":4}
  static Future<void> setBackgroundPerPrayerMap(Map<String, int> map) async {
    await save(key: _kBgPerPrayer, value: jsonEncode(map));
  }

  static Map<String, int> getBackgroundPerPrayerMap({
    Map<String, int>? fallback,
  }) {
    final raw = get(key: _kBgPerPrayer);
    if (raw is! String || raw.isEmpty) return fallback ?? {};
    try {
      final m = (jsonDecode(raw) as Map).cast<String, dynamic>();
      return m.map((k, v) => MapEntry(k, (v as num).toInt()));
    } catch (_) {
      return fallback ?? {};
    }
  }

  /// map: {"sun":5,"mon":8,"tue":31,"wed":16,"thu":7,"fri":3,"sat":27}
  static Future<void> setBackgroundPerDayMap(Map<String, int> map) async {
    await save(key: _kBgPerDay, value: jsonEncode(map));
  }

  static Map<String, int> getBackgroundPerDayMap({Map<String, int>? fallback}) {
    final raw = get(key: _kBgPerDay);
    if (raw is! String || raw.isEmpty) return fallback ?? {};
    try {
      final m = (jsonDecode(raw) as Map).cast<String, dynamic>();
      return m.map((k, v) => MapEntry(k, (v as num).toInt()));
    } catch (_) {
      return fallback ?? {};
    }
  }

  /// list: [4,6,8,9,18]
  static Future<void> setBackgroundRandomPool(List<int> list) async {
    await save(key: _kBgRandomPool, value: jsonEncode(list));
  }

  static List<int> getBackgroundRandomPool({List<int>? fallback}) {
    final raw = get(key: _kBgRandomPool);
    if (raw is! String || raw.isEmpty) return fallback ?? [];
    try {
      final arr = (jsonDecode(raw) as List).cast<dynamic>();
      return arr.map((e) => (e as num).toInt()).toList();
    } catch (_) {
      return fallback ?? [];
    }
  }

  static Future<void> setCurrentPrayerKey(String key) async {
    // key: "fajr" "sunrise" "dhuhr" "asr" "maghrib" "isha"
    await save(key: _kCurrentPrayerKey, value: key);
  }

  static String? getCurrentPrayerKey() {
    final v = get(key: _kCurrentPrayerKey);
    return v is String ? v : null;
  }

  static List<String> getAllBackgrounds() {
    return BackgroundThemes.all;
  }

  // =========================
  // Azan/Iqama Sound Options (NEW)

  static Future<void> setUseMp3Azan(bool v) async {
    await sharedPreferences.setBool(_useMp3Azan, v);

    // لو اتقفل الأساس -> اقفل الباقي تلقائي
    if (!v) {
      await sharedPreferences.setBool(_useShortAzan, false);
      await sharedPreferences.setBool(_useShortIqama, false);
    }
  }

  static bool getUseMp3Azan({bool fallback = false}) {
    return sharedPreferences.getBool(_useMp3Azan) ?? fallback;
  }

  /// (2) أذان قصير - لا يعمل إلا لو (1) true
  static Future<void> setUseShortAzan(bool v) async {
    final base = getUseMp3Azan();
    await sharedPreferences.setBool(_useShortAzan, base ? v : false);
  }

  static bool getUseShortAzan({bool fallback = false}) {
    final base = getUseMp3Azan();
    final val = sharedPreferences.getBool(_useShortAzan) ?? fallback;
    return base ? val : false;
  }

  /// (3) إقامة قصيرة - لا يعمل إلا لو (1) true
  static Future<void> setUseShortIqama(bool v) async {
    final base = getUseMp3Azan();
    await sharedPreferences.setBool(_useShortIqama, base ? v : false);
  }

  static bool getUseShortIqama({bool fallback = false}) {
    final base = getUseMp3Azan();
    final val = sharedPreferences.getBool(_useShortIqama) ?? fallback;
    return base ? val : false;
  }

  // اختياري: remove لو محتاج
  static Future<void> removeAzanSoundOptions() async {
    await sharedPreferences.remove(_useMp3Azan);
    await sharedPreferences.remove(_useShortAzan);
    await sharedPreferences.remove(_useShortIqama);
  }

  static Future<void> setSliderTime(int seconds) async {
    await sharedPreferences.setInt(_sliderTime, seconds);
  }

  static Future<void> setHijriOffsetDays(int v) async {
    // clamp -2..+2
    final clamped = v.clamp(-2, 2);
    await sharedPreferences.setInt(_hijriOffsetDays, clamped);
  }

  static int getHijriOffsetDays() {
    final v = sharedPreferences.getInt(_hijriOffsetDays) ?? 0;
    return v.clamp(-2, 2);
  }

  static Future<void> removeHijriOffsetDays() async {
    await sharedPreferences.remove(_hijriOffsetDays);
  }

  static Future<void> setHijriOffsetDir(int v) async {
    await sharedPreferences.setInt(_hijriOffsetDir, v == -1 ? -1 : 1);
  }

  static int getHijriOffsetDir() {
    final v = sharedPreferences.getInt(_hijriOffsetDir) ?? 1;
    return (v == -1) ? -1 : 1;
  }

  /// Cycle: 0 → 1 → 2 → 1 → 0 → -1 → -2 → -1 → 0 ...
  static Future<int> stepHijriOffsetCycle() async {
    var offset = getHijriOffsetDays(); // -2..2
    var dir = getHijriOffsetDir(); // 1 or -1

    // لو وصلنا للأطراف نعكس الاتجاه
    if (offset == 2) dir = -1;
    if (offset == -2) dir = 1;

    offset += dir;

    // ✅ لو عدّينا 0 وهو راجع من + أو - هنكمل طبيعي
    // clamp للأمان
    offset = offset.clamp(-2, 2);

    await setHijriOffsetDir(dir);
    await setHijriOffsetDays(offset);
    offset.toString().log();
    return offset;
  }

  static bool getEnableGlassEffect() =>
      sharedPreferences.getBool(_enableGlassPrayerRows) ?? false;
  static Future<void> setEnableGlassEffect(bool v) =>
      sharedPreferences.setBool(_enableGlassPrayerRows, v);

  // get slidertime
  static int getSliderTime() {
    return sharedPreferences.getInt(_sliderTime) ?? 25;
  }

  static Future<void> removeSliderTime() async {
    await sharedPreferences.remove(_sliderTime);
  }

  static Future<void> setAdd30MinutesToIshaaInRamdan(bool v) async {
    await sharedPreferences.setBool(_add30MinutesToIshaaInRamdan, v);
  }

  static bool getAdd30MinutesToIshaaInRamdan() {
    return sharedPreferences.getBool(_add30MinutesToIshaaInRamdan) ?? true;
  }

  static Future<void> removeAdd30MinutesToIshaaInRamdan() async {
    await sharedPreferences.remove(_add30MinutesToIshaaInRamdan);
  }

  // azan duration
  static int getAzanDuration() {
    return sharedPreferences.getInt(_azanDuration) ??
        (CacheHelper.getUseMp3Azan() ? 3 : 1);
  }

  static Future<void> setAzanDuration(int v) async {
    await sharedPreferences.setInt(_azanDuration, v);
  }

  static Future<void> removeAzanDuration() async {
    await sharedPreferences.remove(_azanDuration);
  }
}

enum BackgroundChangeMode {
  manual, // تغيير يدوي
  perPrayer, // عند كل صلاة
  perDay, // كل يوم
  randomPool, // عشوائي من قائمة
}

extension BackgroundChangeModeX on BackgroundChangeMode {
  int get id => index;

  static BackgroundChangeMode fromId(int? v) {
    final i = v ?? 0;
    if (i < 0 || i >= BackgroundChangeMode.values.length) {
      return BackgroundChangeMode.manual;
    }
    return BackgroundChangeMode.values[i];
  }
}
