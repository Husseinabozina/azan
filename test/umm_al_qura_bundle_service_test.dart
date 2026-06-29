import 'dart:io';

import 'package:azan/core/models/official_city_catalog_entry.dart';
import 'package:azan/core/services/official_city_catalog_service.dart';
import 'package:azan/core/services/umm_al_qura_bundle_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final repoRoot = Directory.current.path;

  late UmmAlQuraBundleService bundleService;
  late OfficialCityCatalogService catalogService;

  setUp(() {
    bundleService = UmmAlQuraBundleService(
      assetLoader: FileSystemUmmAlQuraAssetLoader(repoRoot),
    );
    catalogService = OfficialCityCatalogService(bundleService: bundleService);
  });

  Future<OfficialCityCatalogEntry> findCity(String bundleId) async {
    final city = await catalogService.findByBundleId(bundleId);
    expect(city, isNotNull);
    return city!;
  }

  test('loads the complete manifest and merged city catalog', () async {
    final manifest = await bundleService.loadManifest();
    final cities = await catalogService.loadCityOptions();

    expect(manifest.cityCount, 118);
    expect(manifest.availableHijriYears, [1448]);
    expect(manifest.yearSummary.every((entry) => entry.complete), isTrue);
    expect(cities, hasLength(118));

    final mecca = cities.firstWhere((city) => city.bundleId == 'mecca');
    expect(mecca.nameAr, 'مكة المكرمة');
    expect(mecca.nameAliases, contains('Makkah'));
  });

  test('loads and converts an official day for a selected city', () async {
    final city = await findCity('abha');
    final manifest = await bundleService.loadManifest();
    final day = await bundleService.loadDay(
      city: city,
      date: DateTime(2026, 6, 16),
    );

    expect(day, isNotNull);
    expect(day!.gregorianYmd, '2026-06-16');
    expect(day.sourceHijriYear, 1448);
    expect(day.timeStrings, hasLength(6));

    final prayerDay = bundleService.toPrayerCalendarDay(
      cityKey: 'bundle::abha',
      scheduleDay: day,
      officialSourceToken: manifest.officialSourceToken,
    );
    expect(prayerDay.cityKey, 'bundle::abha');
    expect(prayerDay.generatedAdhanMinutes, hasLength(6));
    expect(prayerDay.officialSourceToken, manifest.officialSourceToken);
  });

  test('loads only the pinned 1448 range from the bundle', () async {
    final city = await findCity('al-khobar');
    final days = await bundleService.loadRange(
      city: city,
      startInclusive: DateTime(2026, 1, 1),
      endInclusive: DateTime(2027, 12, 31),
    );

    expect(days, hasLength(355));
    expect(days.first.gregorianYmd, '2026-06-16');
    expect(days.last.gregorianYmd, '2027-06-05');
    expect(days.map((day) => day.sourceHijriYear).toSet(), {1448});
  });
}
