import 'package:hive_flutter/hive_flutter.dart';
part 'product_price_history.g.dart';

@HiveType(typeId: 5)
class ProductPriceHistoryModel {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final int? productId;
  @HiveField(2)
  final double price;
  @HiveField(3)
  final DateTime effectiveDate;
  @HiveField(4)
  final DateTime? endDate;
  @HiveField(5)
  final bool isActive;
  @HiveField(6)
  final String? createdBy;
  @HiveField(7)
  final DateTime createdAt;

  const ProductPriceHistoryModel({
    required this.id,
    this.productId,
    required this.price,
    required this.effectiveDate,
    this.endDate,
    this.isActive = true,
    this.createdBy,
    required this.createdAt,
  });

  /// Parse from JSON
  factory ProductPriceHistoryModel.fromJson(Map<String, dynamic> json) {
    return ProductPriceHistoryModel(
      id: _parseIntSafely(json['id']) ?? 0,
      productId: _parseIntSafely(json['product_id']),
      price: _parseDoubleSafely(json['price']) ?? 0.0,
      effectiveDate:
          _parseDateTimeSafely(json['effective_date']) ?? DateTime.now(),
      endDate: _parseDateTimeSafely(json['end_date']),
      isActive: _parseBoolSafely(json['is_active']) ?? true,
      createdBy: _parseStringSafely(json['created_by']),
      createdAt: _parseDateTimeSafely(json['created_at']) ?? DateTime.now(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'price': price,
      'effective_date': effectiveDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'is_active': isActive,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// JSON for Insert (exclude id, created_at auto fields)
  Map<String, dynamic> toInsertJson() {
    final json = {
      'product_id': productId,
      'price': price,
      'effective_date': effectiveDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'is_active': isActive,
      'created_by': createdBy,
    };
    json.removeWhere((key, value) => value == null);
    return json;
  }

  /// Copy with new fields
  ProductPriceHistoryModel copyWith({
    int? id,
    int? productId,
    double? price,
    DateTime? effectiveDate,
    DateTime? endDate,
    bool? isActive,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return ProductPriceHistoryModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      price: price ?? this.price,
      effectiveDate: effectiveDate ?? this.effectiveDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // ==========================
  // Safe parsing helpers
  // ==========================
  static int? _parseIntSafely(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static double? _parseDoubleSafely(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static String? _parseStringSafely(dynamic value) {
    if (value == null) return null;
    if (value is String && value.trim().isEmpty) return null;
    return value.toString().trim();
  }

  static bool? _parseBoolSafely(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) {
      final lower = value.toLowerCase();
      if (lower == 'true' || lower == '1' || lower == 'yes') return true;
      if (lower == 'false' || lower == '0' || lower == 'no') return false;
    }
    return null;
  }

  static DateTime? _parseDateTimeSafely(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        final timestamp = int.tryParse(value);
        if (timestamp != null) {
          return DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
        }
      }
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value * 1000);
    }
    return null;
  }
}
