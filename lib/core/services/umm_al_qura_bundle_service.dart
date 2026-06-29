import 'dart:convert';
import 'dart:io';

import 'package:azan/core/helpers/prayer_calendar_helper.dart';
import 'package:azan/core/models/official_city_catalog_entry.dart';
import 'package:azan/core/models/prayer_calendar_day.dart';
import 'package:azan/core/models/umm_al_qura_bundle_manifest.dart';
import 'package:azan/core/models/umm_al_qura_schedule_day.dart';
import 'package:flutter/services.dart';

abstract class UmmAlQuraAssetLoader {
  Future<String> loadString(String assetPath);
  Future<Uint8List> loadBytes(String assetPath);
}

class RootBundleUmmAlQuraAssetLoader implements UmmAlQuraAssetLoader {
  const RootBundleUmmAlQuraAssetLoader();

  @override
  Future<String> loadString(String assetPath) {
    return rootBundle.loadString(assetPath);
  }

  @override
  Future<Uint8List> loadBytes(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }
}

class FileSystemUmmAlQuraAssetLoader implements UmmAlQuraAssetLoader {
  final String rootPath;

  const FileSystemUmmAlQuraAssetLoader(this.rootPath);

  String _resolve(String assetPath) {
    if (assetPath.startsWith(rootPath)) return assetPath;
    final normalized = assetPath.startsWith('/')
        ? assetPath.substring(1)
        : assetPath;
    return '$rootPath/$normalized';
  }

  @override
  Future<String> loadString(String assetPath) {
    return File(_resolve(assetPath)).readAsString();
  }

  @override
  Future<Uint8List> loadBytes(String assetPath) {
    return File(_resolve(assetPath)).readAsBytes();
  }
}

class UmmAlQuraBundleService {
  static const String manifestAssetPath =
      'assets/data/umm_al_qura/v1/manifest.json';
  static const int pinnedHijriYear = 1448;

  final UmmAlQuraAssetLoader _assetLoader;
  final Map<String, Map<String, UmmAlQuraScheduleDay>> _cityScheduleCache = {};
  UmmAlQuraBundleManifest? _manifestCache;

  UmmAlQuraBundleService({UmmAlQuraAssetLoader? assetLoader})
    : _assetLoader = assetLoader ?? const RootBundleUmmAlQuraAssetLoader();

  Future<UmmAlQuraBundleManifest> loadManifest() async {
    final cached = _manifestCache;
    if (cached != null) {
      return cached;
    }

    final raw = await _assetLoader.loadString(manifestAssetPath);
    final manifest = UmmAlQuraBundleManifest.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
    manifest.validateShape();
    final pinnedManifest = _pinManifestToYear(manifest);
    pinnedManifest.validateShape();
    _manifestCache = pinnedManifest;
    return pinnedManifest;
  }

  Future<String> loadOfficialSourceToken() async {
    return (await loadManifest()).officialSourceToken;
  }

  Future<UmmAlQuraScheduleDay?> loadDay({
    required OfficialCityCatalogEntry city,
    required DateTime date,
  }) async {
    final cityDays = await _loadCityScheduleMap(city);
    return cityDays[PrayerCalendarHelper.ymdForDate(date)];
  }

  Future<List<UmmAlQuraScheduleDay>> loadRange({
    required OfficialCityCatalogEntry city,
    required DateTime startInclusive,
    required DateTime endInclusive,
  }) async {
    final cityDays = await _loadCityScheduleMap(city);
    final result = <UmmAlQuraScheduleDay>[];
    for (
      var day = PrayerCalendarHelper.dateOnly(startInclusive);
      !day.isAfter(endInclusive);
      day = day.add(const Duration(days: 1))
    ) {
      final record = cityDays[PrayerCalendarHelper.ymdForDate(day)];
      if (record != null) {
        result.add(record);
      }
    }
    result.sort(
      (left, right) => left.gregorianYmd.compareTo(right.gregorianYmd),
    );
    return result;
  }

  PrayerCalendarDay toPrayerCalendarDay({
    required String cityKey,
    required UmmAlQuraScheduleDay scheduleDay,
    DateTime? generatedAt,
    required String officialSourceToken,
  }) {
    return PrayerCalendarDay.generated(
      cityKey: cityKey,
      date: PrayerCalendarHelper.dateFromYmd(scheduleDay.gregorianYmd),
      generatedAdhanMinutes: scheduleDay.timeStrings
          .map(PrayerCalendarHelper.minutesFromTimeString)
          .toList(),
      generatedAt: generatedAt,
      officialSourceToken: officialSourceToken,
    );
  }

  Future<Map<String, UmmAlQuraScheduleDay>> _loadCityScheduleMap(
    OfficialCityCatalogEntry city,
  ) async {
    final cached = _cityScheduleCache[city.bundleId];
    if (cached != null) return cached;

    final gzBytes = await _assetLoader.loadBytes(city.scheduleAssetPath);
    final decodedBytes = gzip.decode(gzBytes);
    final payload =
        jsonDecode(utf8.decode(decodedBytes)) as Map<String, dynamic>;
    final years = Map<String, dynamic>.from(
      payload['years'] as Map<String, dynamic>? ?? const <String, dynamic>{},
    );

    final map = <String, UmmAlQuraScheduleDay>{};
    for (final entry in years.entries) {
      if (entry.key != pinnedHijriYear.toString()) {
        continue;
      }
      final yearPayload = Map<String, dynamic>.from(entry.value as Map);
      final sourceHijriYear =
          (yearPayload['hijri_year'] as num?)?.toInt() ?? int.parse(entry.key);
      final days = yearPayload['days'] as List<dynamic>? ?? const [];
      for (final rawDay in days) {
        final scheduleDay = UmmAlQuraScheduleDay.fromJson(
          Map<String, dynamic>.from(rawDay as Map),
          bundleId: city.bundleId,
          sourceHijriYear: sourceHijriYear,
        );
        map[scheduleDay.gregorianYmd] = scheduleDay;
      }
    }

    _cityScheduleCache[city.bundleId] = map;
    return map;
  }

  UmmAlQuraBundleManifest _pinManifestToYear(UmmAlQuraBundleManifest manifest) {
    if (!manifest.availableHijriYears.contains(pinnedHijriYear)) {
      throw FormatException(
        'Umm Al-Qura bundle is missing pinned Hijri year $pinnedHijriYear',
      );
    }

    final pinnedSummary = manifest.yearSummary
        .where((entry) => entry.hijriYear == pinnedHijriYear)
        .toList(growable: false);
    if (pinnedSummary.isEmpty ||
        pinnedSummary.any((entry) => !entry.complete)) {
      throw FormatException(
        'Umm Al-Qura pinned Hijri year $pinnedHijriYear is incomplete',
      );
    }

    final pinnedCities = manifest.cities
        .map((city) {
          if (!city.availableYears.contains(pinnedHijriYear)) {
            throw FormatException(
              'City ${city.id} is missing pinned Hijri year $pinnedHijriYear',
            );
          }
          return UmmAlQuraManifestCity(
            id: city.id,
            nameEn: city.nameEn,
            regionEn: city.regionEn,
            availableYears: const [pinnedHijriYear],
            file: city.file,
            jsonFile: city.jsonFile,
          );
        })
        .toList(growable: false);

    return UmmAlQuraBundleManifest(
      schemaVersion: manifest.schemaVersion,
      generatedAt: manifest.generatedAt,
      countryCode: manifest.countryCode,
      timezone: manifest.timezone,
      cityCount: manifest.cityCount,
      availableHijriYears: const [pinnedHijriYear],
      yearSummary: pinnedSummary,
      cities: pinnedCities,
    );
  }
}
