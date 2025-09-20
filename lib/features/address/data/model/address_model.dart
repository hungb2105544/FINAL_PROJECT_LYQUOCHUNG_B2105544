import 'location_model.dart'; // import your LocationModel

class AddressModel {
  final int? id;
  final String street;
  final String ward;
  final String district;
  final String province;
  final String receiverName;
  final String receiverPhone;
  final int? locationId;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final LocationModel? location;

  AddressModel({
    this.id,
    required this.street,
    required this.ward,
    required this.district,
    required this.province,
    required this.receiverName,
    required this.receiverPhone,
    this.locationId,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.location,
  });

  /// From JSON (map from API/DB)
  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] != null ? json['id'] as int : null,
      street: json['street'] as String,
      ward: json['ward'] as String,
      district: json['district'] as String,
      province: json['province'] as String,
      receiverName: json['receiver_name'] as String,
      receiverPhone: json['receiver_phone'] as String,
      locationId:
          json['location_id'] != null ? json['location_id'] as int : null,
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      location: json['location'] != null
          ? LocationModel.fromJson(json['location'])
          : null,
    );
  }

  /// To JSON (map to send to API/DB)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'street': street,
      'ward': ward,
      'district': district,
      'province': province,
      'receiver_name': receiverName,
      'receiver_phone': receiverPhone,
      'location_id': locationId,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'location': location?.toJson(),
    };
  }

  /// Copy with (immutability helper)
  AddressModel copyWith({
    int? id,
    String? street,
    String? ward,
    String? district,
    String? province,
    String? receiverName,
    String? receiverPhone,
    int? locationId,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    LocationModel? location,
  }) {
    return AddressModel(
      id: id ?? this.id,
      street: street ?? this.street,
      ward: ward ?? this.ward,
      district: district ?? this.district,
      province: province ?? this.province,
      receiverName: receiverName ?? this.receiverName,
      receiverPhone: receiverPhone ?? this.receiverPhone,
      locationId: locationId ?? this.locationId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      location: location ?? this.location,
    );
  }
}
