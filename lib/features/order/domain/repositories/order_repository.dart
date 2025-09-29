import 'package:ecommerce_app/features/order/data/model/order_item_model.dart';
import 'package:ecommerce_app/features/order/data/model/order_model.dart';
import 'package:ecommerce_app/features/order/data/model/order_status_history_model.dart';

abstract class OrderRepository {
  Future<OrderModel> makeOrder(
      OrderModel order, List<OrderItemModel> listOrderItem);

  Future<void> cancelOrder(OrderModel order, String changedBy);
  Future<List<OrderModel>> getOrderByUserID(String userId);
  Future<bool> checkPaymentStatus(OrderModel order, String changedBy);
  Future<List<OrderStatusHistoryModel>> getOrderHistory(int orderId);
  Future<int> autoCheckPendingPayments();
}
