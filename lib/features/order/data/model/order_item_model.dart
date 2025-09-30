class OrderItemModel {
  final int id;
  final int? orderId;
  final int? productId;
  final int? variantId;
  final int quantity;
  final double unitPrice;
  final double discountAmount;
  final double lineTotal;
  final bool canReview;
  final Map<String, dynamic>? product;
  final Map<String, dynamic>? variant;

  OrderItemModel({
    required this.id,
    this.orderId,
    this.productId,
    this.variantId,
    required this.quantity,
    required this.unitPrice,
    required this.discountAmount,
    required this.lineTotal,
    required this.canReview,
    this.product,
    this.variant,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'],
      orderId: json['order_id'],
      productId: json['product_id'],
      variantId: json['variant_id'],
      quantity: json['quantity'] ?? 0,
      unitPrice: (json['unit_price'] ?? 0).toDouble(),
      discountAmount: (json['discount_amount'] ?? 0).toDouble(),
      lineTotal: (json['line_total'] ?? 0).toDouble(),
      canReview: json['can_review'] ?? false,
      product: json['products'] as Map<String, dynamic>?,
      variant: json['product_variants'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'variant_id': variantId,
      'quantity': quantity,
      'unit_price': unitPrice,
      'discount_amount': discountAmount,
      'line_total': lineTotal,
      'can_review': canReview,
      'products': product,
      'product_variants': variant,
    };
  }
}
