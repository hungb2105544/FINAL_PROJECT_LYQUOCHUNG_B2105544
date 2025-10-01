class OrderStatusHistoryModel {
  final int? id;
  final int orderId;
  final String? oldStatus;
  final String newStatus;
  final String? comment;
  final DateTime? changedAt;
  final String? changedBy;

  OrderStatusHistoryModel({
    this.id,
    required this.orderId,
    this.oldStatus,
    required this.newStatus,
    this.comment,
    this.changedAt,
    this.changedBy,
  });

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'old_status': oldStatus,
      'new_status': newStatus,
      'comment': comment,
      'changed_at': (changedAt ?? DateTime.now()).toIso8601String(),
      'changed_by': changedBy,
    };
  }

  factory OrderStatusHistoryModel.fromJson(Map<String, dynamic> json) {
    return OrderStatusHistoryModel(
      id: json['id'],
      orderId: json['order_id'],
      oldStatus: json['old_status'],
      newStatus: json['new_status'],
      comment: json['comment'],
      changedAt: DateTime.tryParse(json['changed_at'] ?? ''),
      changedBy: json['changed_by'],
    );
  }
}
