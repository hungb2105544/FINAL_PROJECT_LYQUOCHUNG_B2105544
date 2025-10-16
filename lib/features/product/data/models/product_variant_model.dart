import 'package:ecommerce_app/features/product/domain/entities/sizes.dart';
import 'package:hive_flutter/hive_flutter.dart';
part 'product_variant_model.g.dart';

@HiveType(typeId: 12)
class ProductVariantModel {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String color;
  @HiveField(2)
  final String sku;
  @HiveField(3)
  final double additionalPrice;
  @HiveField(4)
  final bool isActive;
  @HiveField(5)
  final List<Sizes>? sizes;
  @HiveField(6)
  final List<ProductVariantImageModel>? images;

  ProductVariantModel({
    required this.id,
    required this.color,
    required this.sku,
    required this.additionalPrice,
    required this.isActive,
    this.sizes,
    this.images,
  });

  factory ProductVariantModel.fromJson(Map<String, dynamic> json) =>
      ProductVariantModel(
        id: (json['id'] as num?)?.toInt() ?? 0,
        color: json['color'] as String? ?? '',
        sku: json['sku'] as String? ?? '',
        additionalPrice: (json['additional_price'] as num?)?.toDouble() ?? 0.0,
        isActive: json['is_active'] as bool? ?? false,
        sizes: (json['product_sizes'] as List<dynamic>?)
            ?.map((s) => Sizes.fromJson(s))
            .toList(),
        images: (json['product_variant_images'] as List<dynamic>?)
            ?.map((i) => ProductVariantImageModel.fromJson(i))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'color': color,
        'sku': sku,
        'additional_price': additionalPrice,
        'is_active': isActive,
        if (sizes != null)
          'product_sizes': sizes!.map((s) => s.toJson()).toList(),
        if (images != null)
          'product_variant_images': images!.map((i) => i.toJson()).toList(),
      };
}

@HiveType(typeId: 10)
class ProductVariantImageModel {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String imageUrl;
  @HiveField(2)
  final int? sortOrder;

  ProductVariantImageModel(
      {required this.id, required this.imageUrl, this.sortOrder});

  factory ProductVariantImageModel.fromJson(Map<String, dynamic> json) {
    return ProductVariantImageModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      imageUrl: json['image_url'] as String? ?? '',
      sortOrder: (json['sort_order'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'image_url': imageUrl,
        'sort_order': sortOrder,
      };
}

@HiveType(typeId: 14)
class SimplifiedVariantModel extends HiveObject {
  @HiveField(0)
  final String color;

  @HiveField(1)
  final String? imageUrl;
  @HiveField(2) // THÊM MỚI
  final int? variantId;
  SimplifiedVariantModel({
    required this.color,
    this.imageUrl,
    this.variantId,
  });

  factory SimplifiedVariantModel.fromJson(Map<String, dynamic> json) {
    return SimplifiedVariantModel(
      color: json['color'] as String? ?? '',
      imageUrl: json['image_url'],
      variantId: (json['variant_id'] as num?)?.toInt() ??
          (json['id'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'color': color,
      'image_url': imageUrl,
      'variant_id': variantId,
    };
  }

  @override
  String toString() =>
      'SimplifiedVariantModel(color: $color, imageUrl: $imageUrl)';
}
