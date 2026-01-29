import 'dart:convert';

import 'package:azan/core/models/city_option.dart';
import 'package:azan/core/models/latlng.dart';
import 'package:azan/core/utils/constants.dart';
import 'package:azan/gen/assets.gen.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheHelper {
  static late SharedPreferences sharedPreferences;
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

  static const _isLandscape = "_isLandScape";
  static const String _kBgMode = 'bg_mode';
  static const String _kBgThemeIndex = 'bg_theme_index';
  static const String _kBgPerPrayer = 'bg_per_prayer_map';
  static const String _kBgPerDay = 'bg_per_day_map';
  static const String _kBgRandomPool = 'bg_random_pool';

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

  static setPrayerTimesNotificationEnabled(bool value) async {
    await sharedPreferences.setBool(_prayerTimesNotificationEnabled, value);
  }

  static bool getPrayerTimesNotificationEnabled() {
    return sharedPreferences.getBool(_prayerTimesNotificationEnabled) ?? false;
  }

  static bool getAzkarNotficationEnabled() {
    return sharedPreferences.getBool(_azkarNotficationEnabled) ?? false;
  }

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
    return sharedPreferences.getString(_FontFamily) ?? tajwalFont;
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
    return sharedPreferences.getString(_timeFontFamily) ?? tajwalFont;
  }

  static removeTimeFontFamily() {
    sharedPreferences.remove(_timeFontFamily);
  }

  static setTimesFontFamily(String value) async {
    await sharedPreferences.setString(_timesFontFamily, value);
  }

  static String getTimesFontFamily() {
    return sharedPreferences.getString(_timesFontFamily) ?? tajwalFont;
  }

  static removeTimesFontFamily() {
    sharedPreferences.remove(_timesFontFamily);
  }

  static setTextsFontFamily(String value) async {
    await sharedPreferences.setString(_textsFontFamily, value);
  }

  static String getTextsFontFamily() {
    return sharedPreferences.getString(_textsFontFamily) ?? tajwalFont;
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
    return [
      Assets.images.home.path,
      Assets.images.backgroundBroundWithMosBird.path,
      Assets.images.backgroundLight2.path,
      Assets.images.backgroundOliveGreenWithMosq.path,
      Assets.images.backgroundGreenWith.path,

      Assets.images.awesomeBackground.path,
      Assets.images.awesome2.path,
      Assets.images.darkBrownBackground.path,
      Assets.images.lightBackground1.path,
      Assets.images.lightBrownBackground.path,
      Assets.images.brownBackground.path,
      Assets.images.background2.path,
      Assets.images.whiteBackgroundWithNaqsh.path,
      Assets.images.elegantTealArabesqueBackground.path,
      Assets.images.elegantBurgundyArabesqueBackground.path,
      Assets.images.convinentOliveGreenBackground.path,
      Assets.images.convinentBeigeBackground.path,
      Assets.images.tealBlueBackground.path,

      Assets.images.hr0.path,
      Assets.images.hr1.path,
      Assets.images.hr2.path,
      Assets.images.hr3.path,
      Assets.images.hr4.path,
      Assets.images.hr5.path,
      Assets.images.hr6.path,
      Assets.images.hr7.path,
      Assets.images.hr8.path,
      Assets.images.hr9.path,
      Assets.images.hr10.path,
      Assets.images.hr11.path,
      Assets.images.hr12.path,
      Assets.images.hr13.path,
      Assets.images.hr14.path,
      Assets.images.hr15.path,
      Assets.images.hr16.path,
      Assets.images.hr17.path,
      Assets.images.hr18.path,
      Assets.images.hr19.path,
      Assets.images.hr20.path,
      Assets.images.hr21.path,
      Assets.images.hr22.path,
      Assets.images.hr23.path,
      Assets.images.hr24.path,
      Assets.images.hr25.path,
      Assets.images.hr26.path,
      Assets.images.hr27.path,
      Assets.images.hr28.path,
      Assets.images.hr29.path,
      Assets.images.hr30.path,
      Assets.images.hr31.path,
      Assets.images.hr32.path,
      Assets.images.hr33.path,
      Assets.images.hr34.path,
      Assets.images.hr35.path,
      Assets.images.hr36.path,
      Assets.images.hr37.path,
      Assets.images.hr38.path,

      Assets.images.vr20.path,
      Assets.images.vr21.path,
      Assets.images.vr22.path,
      Assets.images.vr23.path,
      Assets.images.vr24.path,
      Assets.images.vr25.path,
      Assets.images.vr26.path,
      Assets.images.vr27.path,
    ];
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
