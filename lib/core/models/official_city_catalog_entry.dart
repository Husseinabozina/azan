class OfficialCityCatalogEntry {
  final String bundleId;
  final String nameEn;
  final String nameAr;
  final String? regionEn;
  final String countryCode;
  final String timezone;
  final double? lat;
  final double? lon;
  final String scheduleAssetPath;
  final String? debugJsonPath;
  final List<int> availableHijriYears;
  final List<String> aliases;

  const OfficialCityCatalogEntry({
    required this.bundleId,
    required this.nameEn,
    required this.nameAr,
    required this.regionEn,
    required this.countryCode,
    required this.timezone,
    required this.lat,
    required this.lon,
    required this.scheduleAssetPath,
    required this.debugJsonPath,
    required this.availableHijriYears,
    required this.aliases,
  });

  String get cityKey => 'bundle::$bundleId';
}
