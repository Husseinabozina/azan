import 'package:azan/core/models/official_city_catalog_entry.dart';
import 'package:azan/core/services/official_city_catalog_service.dart';
import 'package:azan/core/services/umm_al_qura_bundle_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const repoRoot = '/Users/husseinabozina/azan';

  late UmmAlQuraBundleService bundleService;
  late OfficialCityCatalogService catalogService;

  setUp(() {
    bundleService = UmmAlQuraBundleService(
      assetLoader: const FileSystemUmmAlQuraAssetLoader(repoRoot),
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
    expect(manifest.yearSummary.every((entry) => entry.complete), isTrue);
    expect(cities, hasLength(118));

    final mecca = cities.firstWhere((city) => city.bundleId == 'mecca');
    expect(mecca.nameAr, 'مكة المكرمة');
    expect(mecca.nameAliases, contains('Makkah'));
  });

  test('loads and converts an official day for a selected city', () async {
    final city = await findCity('abha');
    final day = await bundleService.loadDay(
      city: city,
      date: DateTime(2026, 1, 1),
    );

    expect(day, isNotNull);
    expect(day!.gregorianYmd, '2026-01-01');
    expect(day.timeStrings, hasLength(6));

    final prayerDay = bundleService.toPrayerCalendarDay(
      cityKey: 'bundle::abha',
      scheduleDay: day,
    );
    expect(prayerDay.cityKey, 'bundle::abha');
    expect(prayerDay.generatedAdhanMinutes, hasLength(6));
  });

  test('loads the full Gregorian year range from the bundle', () async {
    final city = await findCity('al-khobar');
    final days = await bundleService.loadRange(
      city: city,
      startInclusive: DateTime(2026, 1, 1),
      endInclusive: DateTime(2026, 12, 31),
    );

    expect(days, hasLength(365));
    expect(days.first.gregorianYmd, '2026-01-01');
    expect(days.last.gregorianYmd, '2026-12-31');
  });
}
