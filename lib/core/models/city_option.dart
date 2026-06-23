class CityOption {
  final String? countryCode;
  final String nameAr;
  final String nameEn;
  final double? lat;
  final double? lon;
  final String? bundleId;
  final String? regionEn;
  final List<String> nameAliases;

  const CityOption({
    this.countryCode,
    required this.nameAr,
    required this.nameEn,
    this.lat,
    this.lon,
    this.bundleId,
    this.regionEn,
    this.nameAliases = const <String>[],
  });

  bool get hasBundleId => bundleId != null && bundleId!.trim().isNotEmpty;

  CityOption copyWith({
    String? countryCode,
    String? nameAr,
    String? nameEn,
    double? lat,
    double? lon,
    String? bundleId,
    String? regionEn,
    List<String>? nameAliases,
  }) {
    return CityOption(
      countryCode: countryCode ?? this.countryCode,
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      bundleId: bundleId ?? this.bundleId,
      regionEn: regionEn ?? this.regionEn,
      nameAliases: nameAliases ?? this.nameAliases,
    );
  }

  Map<String, dynamic> toJson() => {
    'countryCode': countryCode,
    'nameAr': nameAr,
    'nameEn': nameEn,
    'lat': lat,
    'lon': lon,
    'bundleId': bundleId,
    'regionEn': regionEn,
    'nameAliases': nameAliases,
  };

  factory CityOption.fromJson(Map<String, dynamic> json) {
    return CityOption(
      countryCode: json['countryCode'] as String?,
      nameAr: json['nameAr'] as String,
      nameEn: json['nameEn'] as String,
      lat: json['lat'] == null ? null : (json['lat'] as num).toDouble(),
      lon: json['lon'] == null ? null : (json['lon'] as num).toDouble(),
      bundleId: json['bundleId'] as String?,
      regionEn: json['regionEn'] as String?,
      nameAliases: (json['nameAliases'] as List<dynamic>? ?? const [])
          .map((value) => value.toString())
          .where((value) => value.trim().isNotEmpty)
          .toList(),
    );
  }
}
