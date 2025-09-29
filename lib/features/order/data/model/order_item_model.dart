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
    };
  }

  /// ✅ copyWith cho phép clone model và thay đổi một số field
  OrderItemModel copyWith({
    int? id,
    int? orderId,
    int? productId,
    int? variantId,
    int? quantity,
    double? unitPrice,
    double? discountAmount,
    double? lineTotal,
    bool? canReview,
  }) {
    return OrderItemModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      productId: productId ?? this.productId,
      variantId: variantId ?? this.variantId,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      discountAmount: discountAmount ?? this.discountAmount,
      lineTotal: lineTotal ?? this.lineTotal,
      canReview: canReview ?? this.canReview,
    );
  }

  @override
  String toString() {
    return 'OrderItemModel(id: $id, orderId: $orderId, productId: $productId, variantId: $variantId, quantity: $quantity, unitPrice: $unitPrice, discountAmount: $discountAmount, lineTotal: $lineTotal, canReview: $canReview)';
  }
}
