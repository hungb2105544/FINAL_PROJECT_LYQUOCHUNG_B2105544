import 'package:ecommerce_app/features/cart/bloc/cart_bloc.dart';
import 'package:ecommerce_app/features/cart/bloc/cart_event.dart';
import 'package:ecommerce_app/features/cart/bloc/cart_state.dart';
import 'package:ecommerce_app/features/cart/data/repositories/cart_repositories.impl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class CartPage extends StatelessWidget {
  final String userId;

  const CartPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CartBloc(
        cartRepository: CartRepositoryImpl(),
      )..add(LoadCart(userId)),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: _buildAppBar(context),
        body: BlocBuilder<CartBloc, CartState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              );
            }

            if (state.error != null) {
              return _buildErrorState(context, state.error!);
            }

            if (state is CartLoaded) {
              return state.items.isEmpty
                  ? _buildEmptyCart(context)
                  : _buildCartContent(context, state);
            }

            return _buildEmptyCart(context);
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      title: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          int itemCount = 0;
          if (state is CartLoaded) {
            itemCount = state.items.fold(0, (sum, item) => sum + item.quantity);
          }
          return Text(
            'Giỏ hàng ($itemCount)',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          );
        },
      ),
      actions: [
        BlocBuilder<CartBloc, CartState>(
          builder: (context, state) {
            if (state is CartLoaded && state.items.isNotEmpty) {
              return IconButton(
                icon: const Icon(Icons.delete_sweep_outlined),
                onPressed: () => _showClearCartDialog(context),
                tooltip: 'Xóa tất cả',
              );
            }
            return const SizedBox();
          },
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Có lỗi xảy ra',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<CartBloc>().add(LoadCart(userId));
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.blue[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                size: 60,
                color: Colors.blue[300],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Giỏ hàng trống',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Hãy thêm sản phẩm vào giỏ hàng để bắt đầu mua sắm',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.shopping_bag_outlined),
              label: const Text('Tiếp tục mua sắm'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartContent(BuildContext context, CartLoaded state) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
    );

    // Calculate total (giả sử có giá trong database)
    double total = 0;
    for (var item in state.items) {
      // Tạm thời dùng giá giả, thực tế cần lấy từ product
      total += (item.price * item.quantity); // 100k per item
    }

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.items.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = state.items[index];
              return _buildCartItem(context, item, currencyFormatter);
            },
          ),
        ),
        _buildCheckoutSection(context, state, total, currencyFormatter),
      ],
    );
  }

  Widget _buildCartItem(BuildContext context, item, NumberFormat formatter) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image Placeholder
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.image,
                color: Colors.grey[400],
                size: 32,
              ),
            ),

            const SizedBox(width: 16),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sản phẩm ${item.productId}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  if (item.variantId != null)
                    Text(
                      'Phân loại: Variant ${item.variantId}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),

                  const SizedBox(height: 8),

                  // Price
                  Text(
                    formatter.format(item.price), // Giá giả
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Quantity Controls & Delete
            Column(
              children: [
                // Delete Button
                GestureDetector(
                  onTap: () => _showDeleteItemDialog(context, item),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.delete_outline,
                      color: Colors.red[400],
                      size: 20,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Quantity Controls
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildQuantityButton(
                        context,
                        Icons.remove,
                        () {
                          if (item.quantity > 1) {
                            context.read<CartBloc>().add(
                                  UpdateCartItemQuantity(
                                    item.id.toString(),
                                    item.quantity - 1,
                                    userId,
                                  ),
                                );
                          }
                        },
                        enabled: item.quantity > 1,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Text(
                          '${item.quantity}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      _buildQuantityButton(
                        context,
                        Icons.add,
                        () {
                          context.read<CartBloc>().add(
                                UpdateCartItemQuantity(
                                  item.id.toString(),
                                  item.quantity + 1,
                                  userId,
                                ),
                              );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityButton(
    BuildContext context,
    IconData icon,
    VoidCallback onPressed, {
    bool enabled = true,
  }) {
    return GestureDetector(
      onTap: enabled ? onPressed : null,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: enabled ? Colors.blue[50] : Colors.grey[100],
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? Colors.blue : Colors.grey,
        ),
      ),
    );
  }

  Widget _buildCheckoutSection(
    BuildContext context,
    CartLoaded state,
    double total,
    NumberFormat formatter,
  ) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: SafeArea(
        child: Column(
          children: [
            // Order Summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tổng cộng (${state.items.fold(0, (sum, item) => sum + item.quantity)} sản phẩm)',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                Text(
                  formatter.format(total),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.red,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Checkout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _proceedToCheckout(context, state);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Tiến hành thanh toán',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text('Xóa giỏ hàng'),
        content: const Text(
            'Bạn có chắc chắn muốn xóa tất cả sản phẩm trong giỏ hàng?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<CartBloc>().add(ClearCart(userId));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _showDeleteItemDialog(BuildContext context, item) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text('Xóa sản phẩm'),
        content:
            Text('Bạn có muốn xóa sản phẩm ${item.productId} khỏi giỏ hàng?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<CartBloc>().add(
                    RemoveFromCart(item.id.toString(), userId),
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _proceedToCheckout(BuildContext context, CartLoaded state) {
    // Navigate to checkout page
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tiến hành thanh toán ${state.items.length} sản phẩm'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
