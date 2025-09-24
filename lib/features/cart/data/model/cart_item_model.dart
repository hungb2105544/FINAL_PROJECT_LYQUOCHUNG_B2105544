// cart_item_model.dart
import 'package:equatable/equatable.dart';

class CartItem extends Equatable {
  final int id;
  final int cartId;
  final int productId;
  final int? variantId;
  final int quantity;
  final DateTime addedAt;
  final double price;
  final Map<String, dynamic>? productData;
  final Map<String, dynamic>? variantData;

  final String? nameProduct;
  final String? imageProduct;

  const CartItem({
    required this.id,
    required this.cartId,
    required this.productId,
    this.variantId,
    required this.quantity,
    required this.addedAt,
    required this.price,
    this.productData,
    this.variantData,
    this.nameProduct,
    this.imageProduct,
  });

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'] as int,
      cartId: map['cart_id'] as int,
      productId: map['product_id'] as int,
      variantId: map['variant_id'] as int?,
      quantity: map['quantity'] as int,
      addedAt: DateTime.parse(map['added_at'] as String),
      productData: map['product_id'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(map['product_id'])
          : null,
      variantData: map['variant_id'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(map['variant_id'])
          : null,
      price: (map['price'] as num).toDouble(),
      nameProduct: map['name_product'] as String?,
      imageProduct: map['image_product'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cart_id': cartId,
      'product_id': productId,
      'variant_id': variantId,
      'quantity': quantity,
      'added_at': addedAt.toIso8601String(),
    };
  }

  // Helper methods để lấy thông tin sản phẩm
  String get productName => productData?['name'] ?? 'Unknown Product';
  double get productPrice {
    final price = productData?['price'] ?? 0;
    return double.parse(price.toString());
  }

  String get productImage {
    final images = productData?['image_urls'] ?? [];
    return images.isNotEmpty ? images.first : '';
  }

  @override
  List<Object?> get props => [
        id,
        cartId,
        productId,
        variantId,
        quantity,
        addedAt,
        productData,
        variantData
      ];
}
