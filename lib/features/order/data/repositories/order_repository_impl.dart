import 'package:ecommerce_app/core/data/datasources/supabase_client.dart';
import 'package:ecommerce_app/features/order/data/model/order_item_model.dart';
import 'package:ecommerce_app/features/order/data/model/order_model.dart';
import 'package:ecommerce_app/features/order/data/model/order_status_history_model.dart';
import 'package:ecommerce_app/features/order/data/model/transaction_model.dart';
import 'package:ecommerce_app/features/order/domain/repositories/order_repository.dart';
import 'package:ecommerce_app/service/transaction_service.dart';

class OrderRepositoryImpl implements OrderRepository {
  final supabase = SupabaseConfig.client;
  final TransactionService transactionService;

  OrderRepositoryImpl({required this.transactionService});

  @override
  Future<OrderModel> makeOrder(
      OrderModel order, List<OrderItemModel> listOrderItem) async {
    try {
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('User is not authenticated');
      }
      final String userid = currentUser.id;

      final Map<String, dynamic> data = {
        'order_number': order.orderNumber,
        'user_id': userid,
        'user_address_id': order.userAddressId,
        'subtotal': order.subtotal,
        'discount_amount': order.discountAmount,
        'shipping_fee': order.shippingFee,
        'tax_amount': order.taxAmount,
        'total': order.total,
        'voucher_id': order.voucherId,
        'points_earned': order.pointsEarned,
        'points_used': order.pointsUsed,
        'status': order.status,
        'payment_status': order.paymentStatus,
        'payment_method': order.paymentMethod,
        'payment_reference': order.paymentReference,
        'notes': order.notes,
        'estimated_delivery_date': order.estimatedDeliveryDate,
        'delivered_at': order.deliveredAt,
        'created_at': order.createdAt,
        'updated_at': order.updatedAt,
      };

      final orderRes =
          await supabase.from('orders').insert(data).select().maybeSingle();
      if (orderRes == null) {
        throw Exception('Failed to create order');
      }

      final createdOrder = OrderModel.fromJson(orderRes);
      final orderId = createdOrder.id;
      for (var item in listOrderItem) {
        final Map<String, dynamic> orderItemData = {
          'order_id': orderId,
          'product_id': item.productId,
          'variant_id': item.variantId,
          'quantity': item.quantity,
          'unit_price': item.unitPrice,
          'discount_amount': item.discountAmount,
          'line_total': item.lineTotal,
          'can_review': true,
        };
        await supabase.from('order_items').insert(orderItemData);
      }

      await supabase.from('order_status_history').insert({
        'order_id': orderId,
        'old_status': null,
        'new_status': 'pending',
        'comment': 'Order created',
        'changed_by': userid,
        'changed_at': DateTime.now().toIso8601String(),
      });

      if (order.voucherId != null) {
        await _markVoucherAsUsed(userid, order.voucherId!);
      }

      await _removeOrderedItemsFromCart(userid, listOrderItem);

      return createdOrder;
    } catch (e, st) {
      print("Lỗi ở repository makeOrder: $e\n$st");
      rethrow;
    }
  }

  /// Đánh dấu voucher đã sử dụng
  Future<void> _markVoucherAsUsed(String userId, int voucherId) async {
    try {
      final userVoucherRes = await supabase
          .from('user_vouchers')
          .select()
          .eq('user_id', userId)
          .eq('voucher_id', voucherId)
          .eq('is_used', false)
          .maybeSingle();

      if (userVoucherRes != null) {
        await supabase.from('user_vouchers').update({
          'is_used': true,
          'used_at': DateTime.now().toIso8601String(),
        }).eq('id', userVoucherRes['id']);

        // Gọi RPC nếu có (nên có kiểm tra lỗi trong RPC)
        try {
          await supabase.rpc('increment_voucher_usage', params: {
            'voucher_id': voucherId,
          });
        } catch (rpcErr) {
          print('Warning: increment_voucher_usage RPC failed: $rpcErr');
        }

        print("Voucher $voucherId đã được đánh dấu sử dụng");
      }
    } catch (e) {
      print("Lỗi khi cập nhật voucher: $e");
      // Không rethrow để không làm gián đoạn flow đặt hàng
    }
  }

  /// Xóa các sản phẩm đã đặt khỏi giỏ hàng
  Future<void> _removeOrderedItemsFromCart(
      String userId, List<OrderItemModel> orderItems) async {
    try {
      final cartRes = await supabase
          .from('carts')
          .select('id')
          .eq('user_id', userId)
          .eq('status', 'active')
          .maybeSingle();

      if (cartRes == null) return;

      final cartId = cartRes['id'];

      for (var orderItem in orderItems) {
        var query = supabase
            .from('cart_items')
            .delete()
            .eq('cart_id', cartId)
            .eq('product_id', orderItem.productId!.toInt());

        if (orderItem.variantId != null) {
          query = query.eq('variant_id', orderItem.variantId!);
        } else {
          query = query.isFilter('variant_id', null);
        }

        await query;
      }

      print("Đã xóa ${orderItems.length} sản phẩm khỏi giỏ hàng");
    } catch (e) {
      print("Lỗi khi xóa sản phẩm khỏi giỏ hàng: $e");
      // Không throw error
    }
  }

  @override
  Future<void> cancelOrder(OrderModel order, String changedBy) async {
    try {
      print("Order ID from Repository: ${order.id}");

      if (order.id <= 0) {
        throw Exception('Order ID is invalid');
      }

      if (order.status == 'delivered' || order.status == 'cancelled') {
        throw Exception('Cannot cancel order with status: ${order.status}');
      }

      final currentOrderRes = await supabase
          .from('orders')
          .select()
          .eq('id', order.id)
          .maybeSingle();

      if (currentOrderRes == null) {
        throw Exception('Order not found');
      }

      final currentStatus = currentOrderRes['status'] as String? ?? 'unknown';
      print("Current order status: $currentStatus");

      // Cập nhật trạng thái đơn hàng
      await supabase.from('orders').update({
        'status': 'cancelled',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', order.id);

      // Thêm lịch sử
      await supabase.from('order_status_history').insert({
        'order_id': order.id,
        'old_status': currentStatus,
        'new_status': 'cancelled',
        'comment': 'Order cancelled by $changedBy',
        'changed_by': changedBy,
        'changed_at': DateTime.now().toIso8601String(),
      });

      if (order.paymentMethod == 'bank_transfer') {
        await _restoreVoucherAndCart(order);
      }

      print("Order cancelled successfully");
    } catch (e, st) {
      print("Error cancelling order: $e\n$st");
      rethrow;
    }
  }

  /// Khôi phục voucher và giỏ hàng khi hủy đơn thanh toán online
  Future<void> _restoreVoucherAndCart(OrderModel order) async {
    try {
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        print('No authenticated user, cannot restore voucher/cart');
        return;
      }
      final String userid = currentUser.id;

      // 1. Khôi phục voucher nếu có
      if (order.voucherId != null) {
        final userVoucherRes = await supabase
            .from('user_vouchers')
            .select()
            .eq('user_id', userid)
            .eq('voucher_id', order.voucherId!)
            .eq('is_used', true)
            .maybeSingle();

        if (userVoucherRes != null) {
          await supabase.from('user_vouchers').update({
            'is_used': false,
            'used_at': null,
          }).eq('id', userVoucherRes['id']);

          try {
            await supabase.rpc('decrement_voucher_usage', params: {
              'voucher_id': order.voucherId!,
            });
          } catch (rpcErr) {
            print('Warning: decrement_voucher_usage RPC failed: $rpcErr');
          }

          print("Voucher ${order.voucherId} đã được khôi phục");
        }
      }

      // 2. Khôi phục sản phẩm vào giỏ hàng
      final orderItemsRes =
          await supabase.from('order_items').select().eq('order_id', order.id);

      if (orderItemsRes == null || (orderItemsRes as List).isEmpty) {
        return;
      }

      // Lấy hoặc tạo cart
      var cartRes = await supabase
          .from('carts')
          .select('id')
          .eq('user_id', userid)
          .eq('status', 'active')
          .maybeSingle();

      int cartId;
      if (cartRes == null) {
        final newCart = await supabase
            .from('carts')
            .insert({
              'user_id': userid,
              'status': 'active',
            })
            .select('id')
            .maybeSingle();

        if (newCart == null) {
          throw Exception('Failed to create new cart');
        }
        cartId = newCart['id'];
      } else {
        cartId = cartRes['id'];
      }

      for (var item in (orderItemsRes as List)) {
        final variantId = item['variant_id'];

        var existingQuery = supabase
            .from('cart_items')
            .select()
            .eq('cart_id', cartId)
            .eq('product_id', item['product_id']);

        if (variantId != null) {
          existingQuery = existingQuery.eq('variant_id', variantId);
        } else {
          existingQuery = existingQuery.isFilter('variant_id', null);
        }

        final existingItem = await existingQuery.maybeSingle();

        if (existingItem != null) {
          await supabase.from('cart_items').update({
            'quantity':
                (existingItem['quantity'] as int) + (item['quantity'] as int),
            'added_at': DateTime.now().toIso8601String(),
          }).eq('id', existingItem['id']);
        } else {
          await supabase.from('cart_items').insert({
            'cart_id': cartId,
            'product_id': item['product_id'],
            'variant_id': variantId,
            'quantity': item['quantity'],
            'price': item['unit_price'],
            'added_at': DateTime.now().toIso8601String(),
          });
        }
      }

      print(
          "Đã khôi phục ${(orderItemsRes as List).length} sản phẩm vào giỏ hàng");
    } catch (e) {
      print("Lỗi khi khôi phục voucher và giỏ hàng: $e");
      // Không throw để không làm gián đoạn flow hủy đơn
    }
  }

  @override
  Future<bool> checkPaymentStatus(OrderModel order, String changedBy) async {
    if (order.paymentStatus == 'paid') {
      return true;
    }

    // Lấy transactions từ service; đảm bảo service trả List<TransactionModel>
    final transactions = await transactionService
        .getAllTransactionWithAmounIn(order.total.toStringAsFixed(0));

    final matchedTx = transactions.firstWhere(
      (tx) => _isTransactionMatched(tx, order),
      orElse: () => TransactionModel.empty(),
    );

    if (matchedTx.isNotEmpty) {
      await _updatePaymentStatus(order, matchedTx, changedBy);
      return true;
    }

    return false;
  }

  bool _isTransactionMatched(TransactionModel tx, OrderModel order) {
    final contentMatch = tx.transactionContent
            ?.toUpperCase()
            .contains(order.orderNumber.toUpperCase()) ??
        false;

    if (!contentMatch) return false;
    final txAmount = double.tryParse(tx.amountIn ?? '') ?? 0;
    final orderTotal = order.total;
    const epsilon = 0.01;

    final amountMatch = (txAmount - orderTotal).abs() < epsilon;

    return amountMatch;
  }

  Future<void> _updatePaymentStatus(
    OrderModel order,
    TransactionModel matchedTx,
    String changedBy,
  ) async {
    await supabase.from('orders').update({
      'payment_status': 'paid',
      'payment_reference': matchedTx.referenceNumber,
      'payment_method': 'bank_transfer',
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', order.id);

    final history = OrderStatusHistoryModel(
      orderId: order.id,
      oldStatus: order.paymentStatus,
      newStatus: 'paid',
      comment:
          'Payment confirmed via Sepay transaction ${matchedTx.id}. Amount: ${matchedTx.amountIn} VND. Reference: ${matchedTx.referenceNumber}',
      changedBy: changedBy,
      changedAt: DateTime.now(),
    );

    await supabase.from('order_status_history').insert(history.toJson());
  }

  @override
  Future<List<OrderStatusHistoryModel>> getOrderHistory(int orderId) async {
    final res = await supabase
        .from('order_status_history')
        .select()
        .eq('order_id', orderId)
        .order('changed_at', ascending: true);

    if (res == null) return [];

    return (res as List)
        .map((e) => OrderStatusHistoryModel.fromJson(e))
        .toList();
  }

  @override
  Future<List<OrderModel>> getOrderByUserID(String userId) async {
    try {
      final res = await supabase.from('orders').select('''
      *,
      order_items (
        *,
        products (*),
        product_variants (*)
      ),
      order_status_history (*),
      user_addresses (
        *,
        addresses (*)
      ),
      vouchers (*)
    ''').eq('user_id', userId);

      if (res == null) return [];

      return (res as List).map((e) => OrderModel.fromJson(e)).toList();
    } catch (e, stacktrace) {
      print('❌ Lỗi khi lấy đơn hàng cho user $userId: $e');
      print(stacktrace);
      return [];
    }
  }

  Future<int> autoCheckPendingPayments() async {
    final pendingOrders = await supabase
        .from('orders')
        .select()
        .eq('payment_status', 'pending')
        .eq('status', 'pending');

    if (pendingOrders == null) return 0;

    int updatedCount = 0;

    for (var orderJson in pendingOrders as List) {
      final order = OrderModel.fromJson(orderJson);
      final isConfirmed = await checkPaymentStatus(order, 'system');
      if (isConfirmed) updatedCount++;
    }

    return updatedCount;
  }
}
