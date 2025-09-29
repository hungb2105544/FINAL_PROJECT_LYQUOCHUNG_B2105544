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
      final Map<String, dynamic> data = {
        'order_number': order.orderNumber,
        'user_id': order.userId,
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
          await supabase.from('orders').insert(data).select().single();
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
        'changed_by': order.userId,
        'changed_at': DateTime.now().toIso8601String(),
      });
      return createdOrder;
    } catch (e) {
      print("Lỗi ở repository: $e");
      rethrow;
    }
  }

  @override
  Future<void> cancelOrder(OrderModel order, String changedBy) async {
    try {
      print("Order ID from Repository: ${order.id}");

      if (order.id == null || order.id == 0) {
        throw Exception('Order ID is invalid');
      }

      if (order.status == 'delivered' || order.status == 'cancelled') {
        throw Exception('Cannot cancel order with status: ${order.status}');
      }

      final currentOrder =
          await supabase.from('orders').select().eq('id', order.id).single();

      if (currentOrder == null) {
        throw Exception('Order not found');
      }

      print("Current order status: ${currentOrder['status']}");

      await supabase.from('orders').update({
        'status': 'cancelled',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', order.id);

      await supabase.from('order_status_history').insert({
        'order_id': order.id,
        'old_status': currentOrder['status'],
        'new_status': 'cancelled',
        'comment': 'Order cancelled by user',
        'changed_by': changedBy,
        'changed_at': DateTime.now().toIso8601String(),
      });

      print("Order cancelled successfully");
    } catch (e) {
      print("Error cancelling order: $e");
      rethrow;
    }
  }

  @override
  Future<List<OrderModel>> getOrderByUserID(String userId) async {
    final res = await supabase.from('orders').select().eq('user_id', userId);
    return (res as List).map((e) => OrderModel.fromJson(e)).toList();
  }

  @override
  Future<bool> checkPaymentStatus(OrderModel order, String changedBy) async {
    if (order.paymentStatus == 'paid') {
      return true;
    }

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
        .toUpperCase()
        .contains(order.orderNumber.toUpperCase());

    if (!contentMatch) return false;
    final txAmount = double.tryParse(tx.amountIn) ?? 0;
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

    await supabase.from('order_status_history').insert(
          OrderStatusHistoryModel(
            orderId: order.id,
            oldStatus: order.paymentStatus,
            newStatus: 'paid',
            comment: 'Payment confirmed via Sepay transaction ${matchedTx.id}. '
                'Amount: ${matchedTx.amountIn} VND. '
                'Reference: ${matchedTx.referenceNumber}',
            changedBy: changedBy,
          ).toJson(),
        );
  }

  @override
  Future<List<OrderStatusHistoryModel>> getOrderHistory(int orderId) async {
    final res = await supabase
        .from('order_status_history')
        .select()
        .eq('order_id', orderId)
        .order('changed_at', ascending: true);

    return (res as List)
        .map((e) => OrderStatusHistoryModel.fromJson(e))
        .toList();
  }

  Future<int> autoCheckPendingPayments() async {
    final pendingOrders = await supabase
        .from('orders')
        .select()
        .eq('payment_status', 'pending')
        .eq('status', 'pending');

    int updatedCount = 0;

    for (var orderJson in pendingOrders) {
      final order = OrderModel.fromJson(orderJson);
      final isConfirmed = await checkPaymentStatus(order, 'system');
      if (isConfirmed) updatedCount++;
    }

    return updatedCount;
  }
}
