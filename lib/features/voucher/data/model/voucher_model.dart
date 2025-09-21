class VoucherModel {
  final String id;
  final String code;
  final String name;
  final String? description;
  final String type;
  final int value;
  final double minOrderValue;
  final double? maxDiscountAmount;
  final int? usageLimit;
  final int usageLimitPerUser;
  final int usedCount;
  final DateTime? validFrom;
  final DateTime validTo;
  final bool isActive;
  final DateTime? createdAt;
  bool isSaved;

  VoucherModel({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    required this.type,
    required this.value,
    required this.minOrderValue,
    this.maxDiscountAmount,
    this.usageLimit,
    required this.usageLimitPerUser,
    required this.usedCount,
    this.validFrom,
    required this.validTo,
    required this.isActive,
    this.createdAt,
    this.isSaved = false,
  });

  factory VoucherModel.fromJson(Map<String, dynamic> json) {
    return VoucherModel(
      // Convert bigserial to String
      id: json['id'].toString(),
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      type: json['type'] ?? '',

      // Keep as int
      value: json['value'] ?? 0,

      // Convert numeric to double with null safety
      minOrderValue: _parseDouble(json['min_order_value'] ?? 0),
      maxDiscountAmount: json['max_discount_amount'] != null
          ? _parseDouble(json['max_discount_amount'])
          : null,

      // Keep as int with null safety
      usageLimit: json['usage_limit'],
      usageLimitPerUser: json['usage_limit_per_user'] ?? 1,
      usedCount: json['used_count'] ?? 0,

      // Parse timestamps
      validFrom: json['valid_from'] != null
          ? DateTime.parse(json['valid_from'])
          : null,
      validTo: DateTime.parse(json['valid_to']),

      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  // Helper method to safely parse double values
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'description': description,
      'type': type,
      'value': value,
      'min_order_value': minOrderValue,
      'max_discount_amount': maxDiscountAmount,
      'usage_limit': usageLimit,
      'usage_limit_per_user': usageLimitPerUser,
      'used_count': usedCount,
      'valid_from': validFrom?.toIso8601String(),
      'valid_to': validTo.toIso8601String(),
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  VoucherModel copyWith({
    String? id,
    String? code,
    String? name,
    String? description,
    String? type,
    int? value,
    double? minOrderValue,
    double? maxDiscountAmount,
    int? usageLimit,
    int? usageLimitPerUser,
    int? usedCount,
    DateTime? validFrom,
    DateTime? validTo,
    bool? isActive,
    DateTime? createdAt,
    bool? isSaved,
  }) {
    return VoucherModel(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      value: value ?? this.value,
      minOrderValue: minOrderValue ?? this.minOrderValue,
      maxDiscountAmount: maxDiscountAmount ?? this.maxDiscountAmount,
      usageLimit: usageLimit ?? this.usageLimit,
      usageLimitPerUser: usageLimitPerUser ?? this.usageLimitPerUser,
      usedCount: usedCount ?? this.usedCount,
      validFrom: validFrom ?? this.validFrom,
      validTo: validTo ?? this.validTo,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}
