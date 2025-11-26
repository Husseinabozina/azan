class LatLng {
  final double latitude;
  final double longitude;

  LatLng(this.latitude, this.longitude);

  /// Creates a [LatLng] instance from a JSON map.
  factory LatLng.fromJson(Map<String, dynamic> json) {
    return LatLng(
      (json['latitude'] as num?)?.toDouble() ?? 0.0,
      (json['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Converts this [LatLng] instance into a JSON map.
  Map<String, dynamic> toJson() {
    return {'latitude': latitude, 'longitude': longitude};
  }

  @override
  String toString() => 'LatLng(latitude: $latitude, longitude: $longitude)';
}
