// cart_model.dart
import 'package:ecommerce_app/features/cart/data/model/cart_item_model.dart';
import 'package:equatable/equatable.dart';

class Cart extends Equatable {
  final int id;
  final String? userId;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<CartItem> items;
  final int totalItems;

  const Cart({
    required this.id,
    this.userId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.items = const [],
    this.totalItems = 0,
  });

  factory Cart.fromMap(Map<String, dynamic> map) {
    return Cart(
      id: map['id'] as int,
      userId: map['user_id'] as String?,
      status: map['status'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      items: const [], // Items sẽ được load riêng
      totalItems: map['total_items'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'total_items': totalItems,
    };
  }

  Cart copyWith({
    int? id,
    String? userId,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<CartItem>? items,
    int? totalItems,
  }) {
    return Cart(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
      totalItems: totalItems ?? this.totalItems,
    );
  }

  @override
  List<Object?> get props =>
      [id, userId, status, createdAt, updatedAt, items, totalItems];
}
