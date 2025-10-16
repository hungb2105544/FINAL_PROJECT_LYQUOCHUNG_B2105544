import 'package:hive_flutter/hive_flutter.dart';
part 'product_discount.g.dart';

@HiveType(typeId: 4)
class ProductDiscountModel {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final int? discountPercentage;
  @HiveField(2)
  final num? discountAmount;
  @HiveField(3)
  final String startDate;
  @HiveField(4)
  final String endDate;
  @HiveField(5)
  final bool? isActive;

  ProductDiscountModel({
    required this.id,
    this.discountPercentage,
    this.discountAmount,
    required this.startDate,
    required this.endDate,
    this.isActive,
  });

  factory ProductDiscountModel.fromJson(Map<String, dynamic> json) {
    return ProductDiscountModel(
      id: _parseIntSafely(json['id']) ?? 0,
      discountPercentage: _parseIntSafely(json['discount_percentage']),
      discountAmount: _parseNumSafely(json['discount_amount']),
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
      isActive: _parseBoolSafely(json['is_active']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'discount_percentage': discountPercentage,
        'discount_amount': discountAmount,
        'start_date': startDate,
        'end_date': endDate,
        'is_active': isActive,
      };
}

int? _parseIntSafely(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

num? _parseNumSafely(dynamic value) {
  if (value == null) return null;
  if (value is num) return value;
  if (value is String) return num.tryParse(value);
  return null;
}

bool? _parseBoolSafely(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is String) {
    final lower = value.toLowerCase();
    if (lower == 'true' || lower == '1') return true;
    if (lower == 'false' || lower == '0') return false;
  }
  if (value is int) return value != 0;
  return null;
}
