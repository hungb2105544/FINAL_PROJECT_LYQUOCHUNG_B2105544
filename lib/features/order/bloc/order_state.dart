import 'package:ecommerce_app/features/order/data/model/order_model.dart';
import 'package:ecommerce_app/features/order/data/model/order_status_history_model.dart';
import 'package:equatable/equatable.dart';

abstract class OrderPaymentState extends Equatable {
  const OrderPaymentState();

  @override
  List<Object?> get props => [];
}

class OrderPaymentInitial extends OrderPaymentState {}

class OrderPaymentLoading extends OrderPaymentState {}

/// Đơn hàng được tạo thành công
class OrderCreatedSuccess extends OrderPaymentState {
  final OrderModel order;

  const OrderCreatedSuccess(this.order);

  @override
  List<Object?> get props => [order];
}

/// Thanh toán đã được xác nhận
class PaymentConfirmed extends OrderPaymentState {
  final OrderModel order;
  final String message;

  const PaymentConfirmed({
    required this.order,
    required this.message,
  });

  @override
  List<Object?> get props => [order, message];
}

/// Thanh toán chưa được xác nhận
class PaymentPending extends OrderPaymentState {
  final OrderModel order;
  final String message;

  const PaymentPending({
    required this.order,
    required this.message,
  });

  @override
  List<Object?> get props => [order, message];
}

/// Đơn hàng đã hủy
class OrderCancelled extends OrderPaymentState {
  final String message;

  const OrderCancelled(this.message);

  @override
  List<Object?> get props => [message];
}

/// Danh sách đơn hàng
class OrdersLoaded extends OrderPaymentState {
  final List<OrderModel> orders;

  const OrdersLoaded(this.orders);

  @override
  List<Object?> get props => [orders];
}

/// Lịch sử đơn hàng
class OrderHistoryLoaded extends OrderPaymentState {
  final List<OrderStatusHistoryModel> history;

  const OrderHistoryLoaded(this.history);

  @override
  List<Object?> get props => [history];
}

/// Auto check hoàn thành
class AutoCheckCompleted extends OrderPaymentState {
  final int updatedCount;
  final String message;

  const AutoCheckCompleted({
    required this.updatedCount,
    required this.message,
  });

  @override
  List<Object?> get props => [updatedCount, message];
}

/// Lỗi
class OrderPaymentError extends OrderPaymentState {
  final String message;

  const OrderPaymentError(this.message);

  @override
  List<Object?> get props => [message];
}

class OrderLoaded extends OrderPaymentState {
  final OrderModel order;

  const OrderLoaded(this.order);

  @override
  List<Object?> get props => [order];
}
