import 'address_model.dart';

class UserAddressModel {
  final int? id;
  final String? userId;
  final int? addressId;
  final bool isDefault;
  final DateTime? createdAt;

  final AddressModel? address;

  UserAddressModel({
    this.id,
    this.userId,
    this.addressId,
    this.isDefault = false,
    this.createdAt,
    this.address,
  });

  factory UserAddressModel.fromJson(Map<String, dynamic> json) {
    return UserAddressModel(
      id: json['id'] != null ? json['id'] as int : null,
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
