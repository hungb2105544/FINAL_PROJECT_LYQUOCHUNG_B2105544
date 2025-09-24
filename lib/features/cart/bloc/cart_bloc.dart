import 'package:ecommerce_app/features/cart/bloc/cart_event.dart';
import 'package:ecommerce_app/features/cart/bloc/cart_state.dart';
import 'package:ecommerce_app/features/cart/data/model/cart_item_model.dart';
import 'package:ecommerce_app/features/cart/domain/repositories/cart_repositories.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository cartRepository;

  CartBloc({required this.cartRepository}) : super(const CartInitial()) {
    on<LoadCart>(_onLoadCart);
    on<AddToCart>(_onAddToCart);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<UpdateCartItemQuantity>(_onUpdateCartItemQuantity);
    on<ClearCart>(_onClearCart);
    on<GetTotalCartItems>(_getTotalCartItems);
  }

  // ✅ Helper method để tính totalItems
  int _calculateTotalItems(List<CartItem> items) {
    return items.fold<int>(0, (sum, item) => sum + item.quantity);
  }

  // ✅ Method chung để xử lý thành công và emit state mới
  Future<void> _handleSuccess(String userId, Emitter<CartState> emit) async {
    try {
      final cart = await cartRepository.getCart(userId);
      final items = cart.items;
      final totalItems = _calculateTotalItems(items);

      emit(CartLoaded(cart, items, totalItems: totalItems));
    } catch (e) {
      emit(CartError('Failed to update cart: ${e.toString()}'));
    }
  }

  Future<void> _getTotalCartItems(
      GetTotalCartItems event, Emitter<CartState> emit) async {
    // Có thể xử lý từ mọi state, không chỉ CartLoaded
    if (state is! CartLoading) {
      emit(state.copyWith(isLoading: true));
      await _handleSuccess(event.userId, emit);
    }
  }

  Future<void> _onLoadCart(LoadCart event, Emitter<CartState> emit) async {
    emit(const CartLoading());
    await _handleSuccess(event.userId, emit);
  }

  Future<void> _onAddToCart(AddToCart event, Emitter<CartState> emit) async {
    if (state is! CartLoading) {
      emit(state.copyWith(isLoading: true));
    }

    try {
      await cartRepository.addToCart(
        event.productId,
        event.quantity,
        event.userId,
        event.variantId,
      );
      await _handleSuccess(event.userId, emit);
    } catch (e) {
      emit(CartError('Failed to add to cart: ${e.toString()}'));
    }
  }

  // Áp dụng tương tự cho các method khác...
  Future<void> _onRemoveFromCart(
      RemoveFromCart event, Emitter<CartState> emit) async {
    if (state is! CartLoading) {
      emit(state.copyWith(isLoading: true));
    }

    try {
      await cartRepository.removeFromCart(event.cartItemId, event.userId);
      await _handleSuccess(event.userId, emit);
    } catch (e) {
      emit(CartError('Failed to remove from cart: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateCartItemQuantity(
    UpdateCartItemQuantity event,
    Emitter<CartState> emit,
  ) async {
    if (state is! CartLoading) {
      emit(state.copyWith(isLoading: true));
    }

    try {
      await cartRepository.updateCartItemQuantity(
        event.cartItemId,
        event.quantity,
        event.userId,
      );
      await _handleSuccess(event.userId, emit);
    } catch (e) {
      emit(CartError('Failed to update quantity: ${e.toString()}'));
    }
  }

  Future<void> _onClearCart(ClearCart event, Emitter<CartState> emit) async {
    emit(const CartLoading());
    try {
      await cartRepository.clearCart(event.userId);
      await _handleSuccess(event.userId, emit);
    } catch (e) {
      emit(CartError('Failed to clear cart: ${e.toString()}'));
    }
  }
}
