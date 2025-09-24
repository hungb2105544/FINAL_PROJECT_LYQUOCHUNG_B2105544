// cart_event.dart
import 'package:equatable/equatable.dart';

class CartEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadCart extends CartEvent {
  final String userId;

  LoadCart(this.userId);

  @override
  List<Object?> get props => [userId];
}

class AddToCart extends CartEvent {
  final String productId;
  final int quantity;
  final String userId;
  final String? variantId;
  AddToCart(this.productId, this.quantity, this.userId, this.variantId);

  @override
  List<Object?> get props => [productId, quantity, userId, variantId];
}

class RemoveFromCart extends CartEvent {
  final String cartItemId;
  final String userId;

  RemoveFromCart(this.cartItemId, this.userId);

  @override
  List<Object?> get props => [cartItemId, userId];
}

class UpdateCartItemQuantity extends CartEvent {
  final String cartItemId;
  final int quantity;
  final String userId;

  UpdateCartItemQuantity(this.cartItemId, this.quantity, this.userId);

  @override
  List<Object?> get props => [cartItemId, quantity, userId];
}

class ClearCart extends CartEvent {
  final String userId;

  ClearCart(this.userId);

  @override
  List<Object?> get props => [userId];
}

class GetTotalCartItems extends CartEvent {
  final String userId;

  GetTotalCartItems(this.userId);

  @override
  List<Object?> get props => [userId];
}
