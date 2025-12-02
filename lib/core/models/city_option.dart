class CityOption {
  final String? countryCode;
  final String nameAr;
  final String nameEn;
  final double? lat;
  final double? lon;

  const CityOption({
    this.countryCode,
    required this.nameAr,
    required this.nameEn,
    this.lat,
    this.lon,
  });

  Map<String, dynamic> toJson() => {
    'countryCode': countryCode,
    'nameAr': nameAr,
    'nameEn': nameEn,
    'lat': lat,
    'lon': lon,
  };

  factory CityOption.fromJson(Map<String, dynamic> json) {
    return CityOption(
      countryCode: json['countryCode'] as String?,
      nameAr: json['nameAr'] as String,
      nameEn: json['nameEn'] as String,
      lat: json['lat'] == null ? null : (json['lat'] as num).toDouble(),
      lon: json['lon'] == null ? null : (json['lon'] as num).toDouble(),
    );
  }
}
