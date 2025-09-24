// cart_state.dart
import 'package:ecommerce_app/features/cart/data/model/cart_item_model.dart';
import 'package:equatable/equatable.dart';
import 'package:ecommerce_app/features/cart/data/model/cart_model.dart';

class CartState extends Equatable {
  final Cart? cart;
  final List<CartItem> items;
  final bool isLoading;
  final String? error;
  final bool isSuccess;
  final int totalItems;
  const CartState({
    this.cart,
    this.items = const [],
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
    this.totalItems = 0,
  });

  CartState copyWith({
    Cart? cart,
    List<CartItem>? items,
    bool? isLoading,
    String? error,
    bool? isSuccess,
    int? totalItems,
  }) {
    return CartState(
      cart: cart ?? this.cart,
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSuccess: isSuccess ?? this.isSuccess,
      totalItems: totalItems ?? this.totalItems,
    );
  }

  int get calculatedTotalItems =>
      items.fold(0, (sum, item) => sum + item.quantity);
  @override
  List<Object?> get props => [cart, items, isLoading, error, isSuccess];
}

class CartInitial extends CartState {
  const CartInitial() : super();
}

class CartLoading extends CartState {
  const CartLoading() : super(isLoading: true);
}

class CartLoaded extends CartState {
  const CartLoaded(Cart cart, List<CartItem> items, {int totalItems = 0})
      : super(
          cart: cart,
          items: items,
          isSuccess: true,
          totalItems: totalItems, // Sử dụng đúng cách
        );
}

class CartError extends CartState {
  const CartError(String error) : super(error: error);
}

class CartOperationSuccess extends CartState {
  final String message;

  const CartOperationSuccess(this.message) : super(isSuccess: true);

  @override
  List<Object?> get props => [message, ...super.props];
}
