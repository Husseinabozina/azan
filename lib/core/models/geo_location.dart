class GeoLocation {
  final double latitude;
  final double longitude;
  final String name;
  final String country;

  GeoLocation({
    required this.latitude,
    required this.longitude,
    required this.name,
    required this.country,
  });

  factory GeoLocation.fromJson(Map<String, dynamic> json) {
    return GeoLocation(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      name: json['name'] as String? ?? '',
      country: json['country'] as String? ?? '',
    );
  }
}
