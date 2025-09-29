import 'package:ecommerce_app/features/order/bloc/order_event.dart';
import 'package:ecommerce_app/features/order/bloc/order_state.dart';
import 'package:ecommerce_app/features/order/domain/repositories/order_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrderPaymentBloc extends Bloc<OrderPaymentEvent, OrderPaymentState> {
  final OrderRepository orderRepository;

  OrderPaymentBloc({required this.orderRepository})
      : super(OrderPaymentInitial()) {
    on<CreateOrderEvent>(_onCreateOrder);
    on<CheckPaymentStatusEvent>(_onCheckPaymentStatus);
    on<CancelOrderEvent>(_onCancelOrder);
    on<GetOrdersByUserEvent>(_onGetOrdersByUser);
    on<GetOrderHistoryEvent>(_onGetOrderHistory);
    on<AutoCheckPendingPaymentsEvent>(_onAutoCheckPendingPayments);
  }

  /// Xử lý tạo đơn hàng
  Future<void> _onCreateOrder(
    CreateOrderEvent event,
    Emitter<OrderPaymentState> emit,
  ) async {
    emit(OrderPaymentLoading());

    try {
      final createdOrder =
          await orderRepository.makeOrder(event.order, event.orderItems);
      emit(OrderCreatedSuccess(createdOrder));
    } catch (e) {
      print("Lỗi gặp phải khi đặt hàng ${e}");
      emit(OrderPaymentError('Tạo đơn hàng thất bại: ${e.toString()}'));
    }
  }

  /// Xử lý kiểm tra thanh toán
  Future<void> _onCheckPaymentStatus(
    CheckPaymentStatusEvent event,
    Emitter<OrderPaymentState> emit,
  ) async {
    emit(OrderPaymentLoading());

    try {
      final isConfirmed = await orderRepository.checkPaymentStatus(
        event.order,
        event.userId,
      );

      if (isConfirmed) {
        emit(PaymentConfirmed(
          order: event.order,
          message:
              'Thanh toán đã được xác nhận! Đơn hàng #${event.order.orderNumber}',
        ));
      } else {
        emit(PaymentPending(
          order: event.order,
          message:
              'Chưa tìm thấy giao dịch. Vui lòng chuyển khoản theo nội dung: ${event.order.orderNumber}',
        ));
      }
    } catch (e) {
      emit(OrderPaymentError('Kiểm tra thanh toán thất bại: ${e.toString()}'));
    }
  }

  Future<void> _onCancelOrder(
    CancelOrderEvent event,
    Emitter<OrderPaymentState> emit,
  ) async {
    emit(OrderPaymentLoading());

    try {
      await orderRepository.cancelOrder(event.order, event.userId);
      emit(OrderCancelled('Đơn hàng #${event.order.orderNumber} đã được hủy'));
    } catch (e) {
      emit(OrderPaymentError('Hủy đơn hàng thất bại: ${e.toString()}'));
    }
  }

  /// Xử lý lấy danh sách đơn hàng
  Future<void> _onGetOrdersByUser(
    GetOrdersByUserEvent event,
    Emitter<OrderPaymentState> emit,
  ) async {
    emit(OrderPaymentLoading());

    try {
      final orders = await orderRepository.getOrderByUserID(event.userId);
      emit(OrdersLoaded(orders));
    } catch (e) {
      emit(OrderPaymentError(
          'Lấy danh sách đơn hàng thất bại: ${e.toString()}'));
    }
  }

  /// Xử lý lấy lịch sử đơn hàng
  Future<void> _onGetOrderHistory(
    GetOrderHistoryEvent event,
    Emitter<OrderPaymentState> emit,
  ) async {
    emit(OrderPaymentLoading());

    try {
      final history = await orderRepository.getOrderHistory(event.orderId);
      emit(OrderHistoryLoaded(history));
    } catch (e) {
      emit(OrderPaymentError('Lấy lịch sử đơn hàng thất bại: ${e.toString()}'));
    }
  }

  /// Xử lý auto check pending payments
  Future<void> _onAutoCheckPendingPayments(
    AutoCheckPendingPaymentsEvent event,
    Emitter<OrderPaymentState> emit,
  ) async {
    emit(OrderPaymentLoading());

    try {
      final updatedCount = await orderRepository.autoCheckPendingPayments();
      emit(AutoCheckCompleted(
        updatedCount: updatedCount,
        message: updatedCount > 0
            ? 'Đã xác nhận $updatedCount đơn hàng'
            : 'Không có đơn hàng nào được xác nhận',
      ));
    } catch (e) {
      emit(OrderPaymentError('Auto check thất bại: ${e.toString()}'));
    }
  }
}
