import 'package:azan/core/models/city_option.dart';
import 'package:azan/core/models/official_city_catalog_entry.dart';
import 'package:azan/core/models/umm_al_qura_bundle_manifest.dart';
import 'package:azan/core/services/umm_al_qura_bundle_service.dart';
import 'package:azan/data/data/city_country_data.dart';
import 'package:azan/data/data/umm_al_qura_city_overrides.dart';

class OfficialCityCatalogService {
  static const String _assetRoot = 'assets/data/umm_al_qura/v1';

  final UmmAlQuraBundleService _bundleService;
  List<OfficialCityCatalogEntry>? _catalogCache;
  Map<String, OfficialCityCatalogEntry>? _catalogByBundleId;

  OfficialCityCatalogService({UmmAlQuraBundleService? bundleService})
    : _bundleService = bundleService ?? UmmAlQuraBundleService();

  Future<List<OfficialCityCatalogEntry>> loadCatalog() async {
    final cached = _catalogCache;
    if (cached != null) return cached;

    final manifest = await _bundleService.loadManifest();
    final catalog = manifest.cities.map(_toCatalogEntry).toList()
      ..sort((left, right) => left.nameEn.compareTo(right.nameEn));
    _catalogCache = catalog;
    _catalogByBundleId = {for (final entry in catalog) entry.bundleId: entry};
    return catalog;
  }

  Future<List<CityOption>> loadCityOptions() async {
    final catalog = await loadCatalog();
    return catalog.map(cityOptionFromEntry).toList(growable: false);
  }

  Future<OfficialCityCatalogEntry?> findByBundleId(String? bundleId) async {
    if (bundleId == null || bundleId.trim().isEmpty) return null;
    final catalog =
        _catalogByBundleId ??
        {for (final entry in await loadCatalog()) entry.bundleId: entry};
    return catalog[bundleId];
  }

  Future<OfficialCityCatalogEntry?> resolveFromCityOption(
    CityOption? city,
  ) async {
    if (city == null) return null;
    final byBundleId = await findByBundleId(city.bundleId);
    if (byBundleId != null) return byBundleId;

    final normalizedSearchValues = <String>{
      _normalizeLookup(city.nameEn),
      _normalizeLookup(city.nameAr),
      for (final alias in city.nameAliases) _normalizeLookup(alias),
    }..remove('');

    for (final entry in await loadCatalog()) {
      final entryTokens = <String>{
        _normalizeLookup(entry.nameEn),
        _normalizeLookup(entry.nameAr),
        for (final alias in entry.aliases) _normalizeLookup(alias),
      }..remove('');
      if (entryTokens.any(normalizedSearchValues.contains)) {
        return entry;
      }
    }
    return null;
  }

  CityOption cityOptionFromEntry(OfficialCityCatalogEntry entry) {
    return CityOption(
      countryCode: entry.countryCode,
      nameAr: entry.nameAr,
      nameEn: entry.nameEn,
      lat: entry.lat,
      lon: entry.lon,
      bundleId: entry.bundleId,
      regionEn: entry.regionEn,
      nameAliases: entry.aliases,
    );
  }

  OfficialCityCatalogEntry _toCatalogEntry(UmmAlQuraManifestCity city) {
    final override = kUmmAlQuraCityOverrides[city.id];
    final matchedLegacyCity = _matchLegacyCity(city, override);
    final aliases = <String>{
      city.nameEn,
      city.id.replaceAll('-', ' '),
      if (override?.legacyNameEn != null) override!.legacyNameEn!,
      if (matchedLegacyCity != null) matchedLegacyCity.nameEn,
      if (matchedLegacyCity != null) matchedLegacyCity.nameAr,
      ...?override?.aliases,
    }.where((value) => value.trim().isNotEmpty).toList()..sort();

    return OfficialCityCatalogEntry(
      bundleId: city.id,
      nameEn: city.nameEn,
      nameAr: override?.nameAr ?? matchedLegacyCity?.nameAr ?? city.nameEn,
      regionEn: city.regionEn,
      countryCode: 'SA',
      timezone: 'Asia/Riyadh',
      lat: override?.lat ?? matchedLegacyCity?.lat,
      lon: override?.lon ?? matchedLegacyCity?.lon,
      scheduleAssetPath: '$_assetRoot/${city.file}',
      debugJsonPath: city.jsonFile == null
          ? null
          : '$_assetRoot/${city.jsonFile!}',
      availableHijriYears: city.availableYears,
      aliases: aliases,
    );
  }

  CityOption? _matchLegacyCity(
    UmmAlQuraManifestCity city,
    UmmAlQuraCityOverride? override,
  ) {
    final candidates = <String>{
      city.nameEn,
      city.id.replaceAll('-', ' '),
      if (override?.legacyNameEn != null) override!.legacyNameEn!,
      ...?override?.aliases,
    };
    final candidateTokens = candidates
        .map(_normalizeLookup)
        .where((value) => value.isNotEmpty)
        .toSet();

    for (final legacy in kSaudiCities) {
      final legacyTokens = <String>{
        _normalizeLookup(legacy.nameEn),
        _normalizeLookup(legacy.nameAr),
      }..remove('');
      if (legacyTokens.any(candidateTokens.contains)) {
        return legacy;
      }
    }
    return null;
  }

  String _normalizeLookup(String raw) {
    var normalized = raw.trim().toLowerCase();
    normalized = normalized
        .replaceAll('&', 'and')
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u');
    normalized = normalized.replaceAll(RegExp(r'[^a-z0-9\u0600-\u06FF]+'), ' ');

    final parts = normalized
        .split(' ')
        .where((part) => part.trim().isNotEmpty)
        .where(
          (part) => !const {
            'al',
            'ad',
            'as',
            'ash',
            'an',
            'ar',
            'the',
          }.contains(part),
        )
        .toList();
    return parts.join();
  }
}
