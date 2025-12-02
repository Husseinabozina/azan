import 'dart:convert';

import 'package:azan/core/models/city_option.dart';
import 'package:azan/core/models/latlng.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheHelper {
  static late SharedPreferences sharedPreferences;
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
    return sharedPreferences.getString(_fixedDhikr) ?? '';
  }

  static removeFixedDhikr() async {
    await sharedPreferences.remove(_fixedDhikr);
  }
}
