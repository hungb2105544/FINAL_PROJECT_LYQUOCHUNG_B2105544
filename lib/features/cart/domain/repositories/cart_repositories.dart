import 'package:ecommerce_app/features/cart/data/model/cart_item_model.dart';
import 'package:ecommerce_app/features/cart/data/model/cart_model.dart';

abstract class CartRepository {
  Future<Cart> getCart(String userId);
  Future<CartItem> addToCart(
      String productId, int quantity, String userId, String? variantId);
  Future<void> removeFromCart(String cartItemId, String userId);
  Future<CartItem> updateCartItemQuantity(
      String cartItemId, int quantity, String userId);
  Future<void> clearCart(String userId);
  Future<List<CartItem>> getCartItems(String cartId);
  Future<int> getTotalCartItems(String userId);
}
