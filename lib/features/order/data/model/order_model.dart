import 'package:ecommerce_app/features/order/data/model/order_item_model.dart';
import 'package:ecommerce_app/features/order/data/model/order_status_history_model.dart';

class OrderModel {
  final int id;
  final String orderNumber;
  final String? userId;
  final int? userAddressId;
  final double subtotal;
  final double discountAmount;
  final double shippingFee;
  final double taxAmount;
  final double total;
  final int? voucherId;
  final int pointsEarned;
  final int pointsUsed;
  final String status;
  final String paymentStatus;
  final String? paymentMethod;
  final String? paymentReference;
  final String? notes;
  final String? estimatedDeliveryDate;
  final String? deliveredAt;
  final String createdAt;
  final String updatedAt;
  final List<OrderItemModel> listOrderItem;
  final List<OrderStatusHistoryModel>? statusHistories;
  OrderModel({
    required this.id,
    required this.orderNumber,
    this.userId,
    this.userAddressId,
    required this.subtotal,
    required this.discountAmount,
    required this.shippingFee,
    required this.taxAmount,
    required this.total,
    this.voucherId,
    required this.pointsEarned,
    required this.pointsUsed,
    required this.status,
    required this.paymentStatus,
    this.paymentMethod,
    this.paymentReference,
    this.notes,
    this.estimatedDeliveryDate,
    this.deliveredAt,
    required this.createdAt,
    required this.updatedAt,
    required this.listOrderItem,
    this.statusHistories,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      orderNumber: json['order_number'],
      userId: json['user_id'],
      userAddressId: json['user_address_id'],
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      discountAmount: (json['discount_amount'] ?? 0).toDouble(),
      shippingFee: (json['shipping_fee'] ?? 0).toDouble(),
      taxAmount: (json['tax_amount'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      voucherId: json['voucher_id'],
      pointsEarned: json['points_earned'] ?? 0,
      pointsUsed: json['points_used'] ?? 0,
      status: json['status'] ?? "pending",
      paymentStatus: json['payment_status'] ?? "pending",
      paymentMethod: json['payment_method'],
      paymentReference: json['payment_reference'],
      notes: json['notes'],
      estimatedDeliveryDate: json['estimated_delivery_date'],
      deliveredAt: json['delivered_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      listOrderItem: (json['order_items'] as List<dynamic>? ?? [])
          .map((e) => OrderItemModel.fromJson(e))
          .toList(),
      statusHistories: (json['status_histories'] as List<dynamic>?)
          ?.map((e) => OrderStatusHistoryModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'user_id': userId,
      'user_address_id': userAddressId,
      'subtotal': subtotal,
      'discount_amount': discountAmount,
      'shipping_fee': shippingFee,
      'tax_amount': taxAmount,
      'total': total,
      'voucher_id': voucherId,
      'points_earned': pointsEarned,
      'points_used': pointsUsed,
      'status': status,
      'payment_status': paymentStatus,
      'payment_method': paymentMethod,
      'payment_reference': paymentReference,
      'notes': notes,
      'estimated_delivery_date': estimatedDeliveryDate,
      'delivered_at': deliveredAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'order_items': listOrderItem.map((e) => e.toJson()).toList(),
      'status_histories': statusHistories?.map((e) => e.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'OrderModel('
        'id: $id, '
        'orderNumber: $orderNumber, '
        'userId: $userId, '
        'userAddressId: $userAddressId, '
        'subtotal: $subtotal, '
        'discountAmount: $discountAmount, '
        'shippingFee: $shippingFee, '
        'taxAmount: $taxAmount, '
        'total: $total, '
        'voucherId: $voucherId, '
        'pointsEarned: $pointsEarned, '
        'pointsUsed: $pointsUsed, '
        'status: $status, '
        'paymentStatus: $paymentStatus, '
        'paymentMethod: $paymentMethod, '
        'paymentReference: $paymentReference, '
        'notes: $notes, '
        'estimatedDeliveryDate: $estimatedDeliveryDate, '
        'deliveredAt: $deliveredAt, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt, '
        'listOrderItem: $listOrderItem, '
        'statusHistories: $statusHistories'
        ')';
  }
}
