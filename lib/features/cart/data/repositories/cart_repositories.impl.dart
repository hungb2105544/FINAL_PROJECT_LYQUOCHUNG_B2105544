import 'package:ecommerce_app/core/data/datasources/supabase_client.dart';
import 'package:ecommerce_app/features/cart/data/model/cart_item_model.dart';
import 'package:ecommerce_app/features/cart/data/model/cart_model.dart';
import 'package:ecommerce_app/features/cart/domain/repositories/cart_repositories.dart';

class CartRepositoryImpl implements CartRepository {
  final client = SupabaseConfig.client;

  @override
  Future<Cart> getCart(String userId) async {
    try {
      final cartResponse = await client
          .from('carts')
          .select()
          .eq('user_id', userId)
          .eq('status', 'active');

      Cart cart;

      if (cartResponse.isEmpty) {
        final newCartResponse = await client.from('carts').insert({
          'user_id': userId,
          'status': 'active',
        }).select();

        cart = Cart.fromMap(newCartResponse.first);
      } else {
        cart = Cart.fromMap(cartResponse.first);
      }

      final items = await getCartItems(cart.id.toString());
      return cart.copyWith(items: items, totalItems: items.length);
    } catch (e) {
      print('GetCart Error: $e');
      throw Exception('Cart operation failed: $e');
    }
  }

  Future<double> _getCurrentProductPrice(
      String productId, String? variantId) async {
    try {
      final int pid = int.parse(productId);

      // 1. Lấy giá mới nhất từ product_price_history
      final priceHistoryResponse = await client
          .from('product_price_history')
          .select('price')
          .eq('product_id', pid)
          .eq('is_active', true)
          .order('effective_date', ascending: false)
          .limit(1)
          .maybeSingle();

      double basePrice = 0.0;
      if (priceHistoryResponse != null) {
        basePrice = (priceHistoryResponse['price'] as num).toDouble();
      }

      // 2. Nếu có variantId thì cộng thêm giá phụ
      if (variantId != null) {
        final variantResponse = await client
            .from('product_variants')
            .select('additional_price')
            .eq('id', int.parse(variantId))
            .maybeSingle();

        if (variantResponse != null) {
          basePrice += (variantResponse['additional_price'] as num).toDouble();
        }
      }

      // 3. Kiểm tra giảm giá còn hiệu lực
      final discountResponse = await client
          .from('product_discounts')
          .select('discount_percentage, discount_amount, start_date, end_date')
          .eq('product_id', pid)
          .eq('is_active', true)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (discountResponse != null) {
        final now = DateTime.now();
        final start = DateTime.parse(discountResponse['start_date']);
        final end = DateTime.parse(discountResponse['end_date']);

        if (now.isAfter(start) && now.isBefore(end)) {
          if (discountResponse['discount_percentage'] != null) {
            final percent = discountResponse['discount_percentage'] as int;
            basePrice = basePrice * (1 - percent / 100);
          } else if (discountResponse['discount_amount'] != null) {
            basePrice -=
                (discountResponse['discount_amount'] as num).toDouble();
            if (basePrice < 0) basePrice = 0;
          }
        }
      }

      return basePrice;
    } catch (e) {
      print('Error getting price: $e');
      return 0.0;
    }
  }

  @override
  Future<CartItem> addToCart(
      String productId, int quantity, String userId, String? variantId) async {
    try {
      print('=== ADD TO CART WITH PRICE ===');
      print(
          'productId: $productId, quantity: $quantity, variantId: $variantId');

      // Lấy giá hiện tại của sản phẩm
      final currentPrice = await _getCurrentProductPrice(productId, variantId);
      print('Current price: $currentPrice');

      final cart = await getCart(userId);
      print('Cart ID: ${cart.id}');

      // Kiểm tra sản phẩm đã tồn tại
      final existingItems = await client
          .from('cart_items')
          .select()
          .eq('cart_id', cart.id)
          .eq('product_id', int.parse(productId));

      final matchingItem = existingItems.where((item) {
        if (variantId == null) {
          return item['variant_id'] == null;
        } else {
          return item['variant_id'] == int.parse(variantId);
        }
      }).toList();

      if (matchingItem.isNotEmpty) {
        final existingItem = matchingItem.first;
        print('Updating existing item: ${existingItem['id']}');

        return await updateCartItemQuantity(
          existingItem['id'].toString(),
          existingItem['quantity'] + quantity,
          userId,
        );
      } else {
        final insertData = {
          'cart_id': cart.id,
          'product_id': int.parse(productId),
          'quantity': quantity,
          'price': currentPrice,
        };

        if (variantId != null) {
          insertData['variant_id'] = int.parse(variantId);
        }

        print('Insert data: $insertData');

        final response =
            await client.from('cart_items').insert(insertData).select();

        print('Insert response: $response');

        if (response.isNotEmpty) {
          final item = response.first;

          return CartItem(
              id: item['id'],
              cartId: item['cart_id'],
              productId: item['product_id'],
              variantId: item['variant_id'],
              quantity: item['quantity'],
              price: (item['price'] as num).toDouble(),
              addedAt: DateTime.now() // THÊM PRICE VÀO MODEL
              );
        } else {
          throw Exception('No response from insert operation');
        }
      }
    } catch (e) {
      print('AddToCart Error: $e');
      throw Exception('Add to cart failed: $e');
    }
  }

  @override
  Future<void> removeFromCart(String cartItemId, String userId) async {
    try {
      await client.from('cart_items').delete().eq('id', int.parse(cartItemId));
    } catch (e) {
      print('RemoveFromCart Error: $e');
      throw Exception('Remove from cart failed: $e');
    }
  }

  @override
  Future<CartItem> updateCartItemQuantity(
      String cartItemId, int quantity, String userId) async {
    try {
      if (quantity <= 0) {
        await removeFromCart(cartItemId, userId);
        throw Exception('Item removed due to zero quantity');
      }

      // CHỈ UPDATE QUANTITY, KHÔNG UPDATE PRICE
      final response = await client
          .from('cart_items')
          .update({'quantity': quantity})
          .eq('id', int.parse(cartItemId))
          .select();

      print('Update response: $response');

      if (response.isNotEmpty) {
        final item = response.first;
        return CartItem(
            id: item['id'],
            cartId: item['cart_id'],
            productId: item['product_id'],
            variantId: item['variant_id'],
            quantity: item['quantity'],
            price: (item['price'] as num).toDouble(),
            addedAt: DateTime.now() // GIỮ GIÁ CŨ
            );
      } else {
        throw Exception('No response from update operation');
      }
    } catch (e) {
      print('UpdateCartItemQuantity Error: $e');
      throw Exception('Update cart item failed: $e');
    }
  }

  @override
  Future<void> clearCart(String userId) async {
    try {
      final cart = await getCart(userId);
      await client.from('cart_items').delete().eq('cart_id', cart.id);
    } catch (e) {
      print('ClearCart Error: $e');
      throw Exception('Clear cart failed: $e');
    }
  }

  @override
  Future<List<CartItem>> getCartItems(String cartId) async {
    try {
      print('Getting cart items for cartId: $cartId');

      final response = await client
          .from('cart_items')
          .select()
          .eq('cart_id', int.parse(cartId));

      print('Cart items response: $response');

      final List<CartItem> items = response.map((item) {
        return CartItem(
          id: item['id'],
          cartId: item['cart_id'],
          productId: item['product_id'],
          variantId: item['variant_id'],
          quantity: item['quantity'],
          price: (item['price'] as num?)?.toDouble() ?? 0.0,
          addedAt: DateTime.now(), // HANDLE NULL PRICE
        );
      }).toList();

      print('Parsed ${items.length} cart items');
      return items;
    } catch (e) {
      print('GetCartItems Error: $e');
      throw Exception('Get cart items failed: $e');
    }
  }

  // THÊM METHOD MỚI: CẬP NHẬT GIÁ CHO TẤT CẢ ITEMS (nếu cần)
  Future<void> updateCartPrices(String userId) async {
    try {
      final cart = await getCart(userId);
      final items = await getCartItems(cart.id.toString());

      for (var item in items) {
        final newPrice = await _getCurrentProductPrice(
          item.productId.toString(),
          item.variantId?.toString(),
        );

        if (newPrice != item.price) {
          await client
              .from('cart_items')
              .update({'price': newPrice}).eq('id', item.id);
        }
      }
    } catch (e) {
      print('UpdateCartPrices Error: $e');
      throw Exception('Update cart prices failed: $e');
    }
  }

  @override
  Future<int> getTotalCartItems(String userId) async {
    try {
      return await client
          .rpc('get_cart_item_count', params: {'user_uuid': userId});
    } catch (e) {
      return 0;
    }
  }
}
