import 'package:hive_flutter/hive_flutter.dart';
part 'product_size_model.g.dart';

@HiveType(typeId: 8)
class ProductSizeModel {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final int productId;
  @HiveField(2)
  final int? sizeId;
  @HiveField(3)
  final SizeModel? size;
  @HiveField(4)
  final DateTime createdAt;

  ProductSizeModel({
    required this.id,
    required this.productId,
    this.sizeId,
    this.size,
    required this.createdAt,
  });

  static int? _parseIntSafely(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static DateTime? _parseDateTimeSafely(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  factory ProductSizeModel.fromJson(Map<String, dynamic> json) {
    return ProductSizeModel(
      id: _parseIntSafely(json['id']) ?? 0,
      productId: _parseIntSafely(json['product_id']) ?? 0,
      sizeId: _parseIntSafely(json['size_id']),
      size: json['sizes'] != null ? SizeModel.fromJson(json['sizes']) : null,
      createdAt: _parseDateTimeSafely(json['created_at']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'size_id': sizeId,
      if (size != null) 'sizes': size!.toJson(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}

@HiveType(typeId: 7)
class SizeModel {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String sizeName;
  @HiveField(2)
  final int sortOrder;

  SizeModel({
    required this.id,
    required this.sizeName,
    this.sortOrder = 0,
  });

  static int? _parseIntSafely(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  factory SizeModel.fromJson(Map<String, dynamic> json) {
    return SizeModel(
      id: _parseIntSafely(json['id']) ?? 0,
      sizeName: json['size_name'] ?? '',
      sortOrder: _parseIntSafely(json['sort_order']) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'size_name': sizeName,
      'sort_order': sortOrder,
    };
  }
}
