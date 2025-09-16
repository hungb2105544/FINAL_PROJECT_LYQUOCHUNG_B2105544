import 'address_model.dart';

class UserAddressModel {
  final int id;
  final String? userId; // uuid in Postgres → String in Flutter
  final int? addressId; // FK → addresses.id
  final bool isDefault;
  final DateTime? createdAt;

  /// Optional nested object
  final AddressModel? address;

  UserAddressModel({
    required this.id,
    this.userId,
    this.addressId,
    this.isDefault = false,
    this.createdAt,
    this.address,
  });

  /// From JSON (map from API/DB)
  factory UserAddressModel.fromJson(Map<String, dynamic> json) {
    return UserAddressModel(
      id: json['id'] as int,
      userId: json['user_id'] as String?,
      addressId: json['address_id'] as int?,
      isDefault: json['is_default'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      address: json['address'] != null
          ? AddressModel.fromJson(json['address'])
          : null,
    );
  }

  /// To JSON (map to send to API/DB)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'address_id': addressId,
      'is_default': isDefault,
      'created_at': createdAt?.toIso8601String(),
      'address': address?.toJson(),
    };
  }

  /// Copy with helper
  UserAddressModel copyWith({
    int? id,
    String? userId,
    int? addressId,
    bool? isDefault,
    DateTime? createdAt,
    AddressModel? address,
  }) {
    return UserAddressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      addressId: addressId ?? this.addressId,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      address: address ?? this.address,
    );
  }
}
