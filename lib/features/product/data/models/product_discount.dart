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
      id: json['id'],
      discountPercentage: json['discount_percentage'],
      discountAmount: json['discount_amount'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      isActive: json['is_active'],
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
