class LocationModel {
  final int? id;
  final double? latitude;
  final double? longitude;
  final DateTime? createdAt;

  LocationModel({
    this.id,
    this.latitude,
    this.longitude,
    this.createdAt,
  });

  /// From JSON (map from API/DB)
  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'] != null ? json['id'] as int : null,
      latitude: json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  /// To JSON (map to send to API/DB)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  /// Copy with (useful for immutability)
  LocationModel copyWith({
    int? id,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
  }) {
    return LocationModel(
      id: id ?? this.id,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
