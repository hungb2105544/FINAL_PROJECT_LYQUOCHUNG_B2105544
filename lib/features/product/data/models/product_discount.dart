class ProductDiscountModel {
  final int id;
  final int? discountPercentage;
  final num? discountAmount;
  final String startDate;
  final String endDate;
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
