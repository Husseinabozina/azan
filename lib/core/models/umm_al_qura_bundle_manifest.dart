class UmmAlQuraBundleManifest {
  final int schemaVersion;
  final DateTime generatedAt;
  final String countryCode;
  final String timezone;
  final int cityCount;
  final List<int> availableHijriYears;
  final List<UmmAlQuraYearSummary> yearSummary;
  final List<UmmAlQuraManifestCity> cities;

  const UmmAlQuraBundleManifest({
    required this.schemaVersion,
    required this.generatedAt,
    required this.countryCode,
    required this.timezone,
    required this.cityCount,
    required this.availableHijriYears,
    required this.yearSummary,
    required this.cities,
  });

  factory UmmAlQuraBundleManifest.fromJson(Map<String, dynamic> json) {
    return UmmAlQuraBundleManifest(
      schemaVersion: (json['schema_version'] as num?)?.toInt() ?? 0,
      generatedAt: DateTime.parse(
        (json['generated_at'] as String?) ??
            DateTime.fromMillisecondsSinceEpoch(0).toIso8601String(),
      ),
      countryCode: (json['country_code'] as String?) ?? '',
      timezone: (json['timezone'] as String?) ?? '',
      cityCount: (json['city_count'] as num?)?.toInt() ?? 0,
      availableHijriYears:
          (json['available_hijri_years'] as List<dynamic>? ?? const <dynamic>[])
              .map((value) => (value as num).toInt())
              .toList(),
      yearSummary: (json['year_summary'] as List<dynamic>? ?? const [])
          .map(
            (entry) => UmmAlQuraYearSummary.fromJson(
              Map<String, dynamic>.from(entry as Map),
            ),
          )
          .toList(),
      cities: (json['cities'] as List<dynamic>? ?? const [])
          .map(
            (entry) => UmmAlQuraManifestCity.fromJson(
              Map<String, dynamic>.from(entry as Map),
            ),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'schema_version': schemaVersion,
      'generated_at': generatedAt.toIso8601String(),
      'country_code': countryCode,
      'timezone': timezone,
      'city_count': cityCount,
      'available_hijri_years': availableHijriYears,
      'year_summary': yearSummary.map((entry) => entry.toJson()).toList(),
      'cities': cities.map((entry) => entry.toJson()).toList(),
    };
  }

  String get officialSourceToken =>
      '$schemaVersion@${generatedAt.toUtc().toIso8601String()}';

  void validateShape() {
    if (schemaVersion != 1) {
      throw FormatException(
        'Unsupported Umm Al-Qura schema version: $schemaVersion',
      );
    }
    if (cityCount != cities.length) {
      throw FormatException(
        'Manifest city_count $cityCount does not match cities length ${cities.length}',
      );
    }
    for (final city in cities) {
      if (city.file.trim().isEmpty) {
        throw FormatException('City ${city.id} is missing a gz asset path');
      }
    }
  }

  void validateYearSummaryComplete() {
    final incomplete = yearSummary.where((entry) => !entry.complete).toList();
    if (incomplete.isEmpty) return;

    final summary = incomplete
        .map(
          (entry) =>
              '${entry.hijriYear}:${entry.cityCount}/${entry.expectedCityCount}',
        )
        .join(', ');
    throw FormatException('Bundle year_summary is incomplete: $summary');
  }
}

class UmmAlQuraYearSummary {
  final int hijriYear;
  final int cityCount;
  final int expectedCityCount;
  final bool complete;

  const UmmAlQuraYearSummary({
    required this.hijriYear,
    required this.cityCount,
    required this.expectedCityCount,
    required this.complete,
  });

  factory UmmAlQuraYearSummary.fromJson(Map<String, dynamic> json) {
    return UmmAlQuraYearSummary(
      hijriYear: (json['hijri_year'] as num?)?.toInt() ?? 0,
      cityCount: (json['city_count'] as num?)?.toInt() ?? 0,
      expectedCityCount: (json['expected_city_count'] as num?)?.toInt() ?? 0,
      complete: json['complete'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hijri_year': hijriYear,
      'city_count': cityCount,
      'expected_city_count': expectedCityCount,
      'complete': complete,
    };
  }
}

class UmmAlQuraManifestCity {
  final String id;
  final String nameEn;
  final String? regionEn;
  final List<int> availableYears;
  final String file;
  final String? jsonFile;

  const UmmAlQuraManifestCity({
    required this.id,
    required this.nameEn,
    required this.regionEn,
    required this.availableYears,
    required this.file,
    required this.jsonFile,
  });

  factory UmmAlQuraManifestCity.fromJson(Map<String, dynamic> json) {
    return UmmAlQuraManifestCity(
      id: (json['id'] as String?) ?? '',
      nameEn: (json['name_en'] as String?) ?? '',
      regionEn: json['region_en'] as String?,
      availableYears: (json['available_years'] as List<dynamic>? ?? const [])
          .map((value) => (value as num).toInt())
          .toList(),
      file: (json['file'] as String?) ?? '',
      jsonFile: json['json_file'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_en': nameEn,
      'region_en': regionEn,
      'available_years': availableYears,
      'file': file,
      'json_file': jsonFile,
    };
  }
}
