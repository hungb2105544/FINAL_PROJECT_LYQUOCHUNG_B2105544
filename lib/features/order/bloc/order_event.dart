import 'package:ecommerce_app/features/order/data/model/order_item_model.dart';
import 'package:ecommerce_app/features/order/data/model/order_model.dart';
import 'package:equatable/equatable.dart';

abstract class OrderPaymentEvent extends Equatable {
  const OrderPaymentEvent();

  @override
  List<Object?> get props => [];
}

class GetOrderById extends OrderPaymentEvent {
  final String orderId;

  const GetOrderById({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

/// Tạo đơn hàng mới
class CreateOrderEvent extends OrderPaymentEvent {
  final OrderModel order;
  final List<OrderItemModel> orderItems;

  const CreateOrderEvent({
    required this.order,
    required this.orderItems,
  });

  @override
  List<Object?> get props => [order, orderItems];
}

/// Kiểm tra trạng thái thanh toán
class CheckPaymentStatusEvent extends OrderPaymentEvent {
  final OrderModel order;
  final String userId;

  const CheckPaymentStatusEvent({
    required this.order,
    required this.userId,
  });

  @override
  List<Object?> get props => [order, userId];
}

/// Hủy đơn hàng
class CancelOrderEvent extends OrderPaymentEvent {
  final OrderModel order;
  final String userId;

  const CancelOrderEvent({
    required this.order,
    required this.userId,
  });

  @override
  List<Object?> get props => [order, userId];
}

/// Lấy danh sách đơn hàng theo user
class GetOrdersByUserEvent extends OrderPaymentEvent {
  final String userId;

  const GetOrdersByUserEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Lấy lịch sử trạng thái đơn hàng
class GetOrderHistoryEvent extends OrderPaymentEvent {
  final int orderId;

  const GetOrderHistoryEvent(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

/// Auto check tất cả pending payments
class AutoCheckPendingPaymentsEvent extends OrderPaymentEvent {
  const AutoCheckPendingPaymentsEvent();
}
