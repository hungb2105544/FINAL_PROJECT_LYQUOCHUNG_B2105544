import 'dart:convert';

import 'package:ecommerce_app/features/product/data/models/index.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/product.dart';
part 'product_model.g.dart';

@HiveType(typeId: 13)
class ProductModel extends Product {
  const ProductModel({
    required super.id,
    super.brandId,
    super.typeId,
    required super.name,
    super.description,
    super.imageUrls,
    super.sku,
    super.weight,
    super.dimensions,
    super.material,
    super.color,
    super.originCountry,
    super.warrantyMonths = 0,
    super.careInstructions,
    super.features,
    super.tags,
    super.averageRating = 0.0,
    super.totalRatings = 0,
    super.ratingDistribution = const {"1": 0, "2": 0, "3": 0, "4": 0, "5": 0},
    super.viewCount = 0,
    super.isFeatured = false,
    super.isActive = true,
    this.brand,
    this.type,
    this.discounts,
    this.inventory,
    this.ratings,
    this.variants,
    this.priceHistoryModel,
    this.productSize,
    required super.createdAt,
    required super.updatedAt,
  });
  @HiveField(24)
  final BrandModel? brand;
  @HiveField(25)
  final ProductTypeModel? type;
  @HiveField(26)
  final List<ProductVariantModel>? variants;
  @HiveField(27)
  final List<ProductDiscountModel>? discounts;
  @HiveField(28)
  final List<ProductRatingModel>? ratings;
  @HiveField(29)
  final List<InventoryModel>? inventory;
  @HiveField(30)
  final List<ProductPriceHistoryModel>? priceHistoryModel;
  @HiveField(31)
  final List<ProductSizeModel>? productSize;

  /// Convert từ JSON (API Response/Database row) sang ProductModel
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    try {
      return ProductModel(
        id: _parseIntSafely(json['id']) ?? 0,
        brandId: _parseIntSafely(json['brand_id']),
        typeId: _parseIntSafely(json['type_id']),
        name: _parseStringSafely(json['name']) ?? '',
        description: _parseStringSafely(json['description']),
        imageUrls: _parseStringListSafely(json['image_urls']),
        sku: _parseStringSafely(json['sku']),
        weight: _parseDoubleSafely(json['weight']),
        dimensions: _parseMapSafely(json['dimensions']) ??
            _parseDimensionsFromFields(json),
        material: _parseStringSafely(json['material']),
        color: _parseStringSafely(json['color']),
        originCountry: _parseStringSafely(json['origin_country']),
        warrantyMonths: _parseIntSafely(json['warranty_months']) ?? 0,
        careInstructions: _parseStringSafely(json['care_instructions']) ?? '',
        features: _parseMapSafely(json['features']),
        tags: _parseStringListSafely(json['tags']) ??
            _parseTagsFromString(json['tags']),
        averageRating: _parseDoubleSafely(json['average_rating']) ?? 0.0,
        totalRatings: _parseIntSafely(json['total_ratings']) ?? 0,
        ratingDistribution: _parseMapSafely(json['rating_distribution']) ??
            _parseRatingDistribution(json) ??
            const {"1": 0, "2": 0, "3": 0, "4": 0, "5": 0},
        viewCount: _parseIntSafely(json['view_count']) ?? 0,
        isFeatured: _parseBoolSafely(json['is_featured']) ?? false,
        isActive: _parseBoolSafely(json['is_active']) ?? true,
        brand:
            json['brands'] != null ? BrandModel.fromJson(json['brands']) : null,
        type: json['product_types'] != null
            ? ProductTypeModel.fromJson(json['product_types'])
            : null,
        variants: (json['product_variants'] as List?)
            ?.map((v) => ProductVariantModel.fromJson(v))
            .toList(),
        discounts: (json['product_discounts'] as List?)
            ?.map((d) => ProductDiscountModel.fromJson(d))
            .toList(),
        ratings: (json['product_ratings'] as List?)
            ?.map((r) => ProductRatingModel.fromJson(r))
            .toList(),
        inventory: (json['inventory'] as List?)
            ?.map((i) => InventoryModel.fromJson(i))
            .toList(),
        priceHistoryModel: (json['product_price_history'] as List?)
            ?.map((i) => ProductPriceHistoryModel.fromJson(i))
            .toList(),
        productSize: (json['product_sizes'] as List?) // THÊM ĐOẠN NÀY
            ?.map((ps) => ProductSizeModel.fromJson(ps))
            .toList(),
        createdAt: _parseDateTimeSafely(json['created_at']) ?? DateTime.now(),
        updatedAt: _parseDateTimeSafely(json['updated_at']) ?? DateTime.now(),
      );
    } catch (e, stackTrace) {
      throw FormatException(
          'Error parsing ProductModel from JSON: $e\nStackTrace: $stackTrace');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brand_id': brandId,
      'type_id': typeId,
      'name': name,
      'description': description,
      'image_urls': imageUrls,
      'sku': sku,
      'weight': weight,
      'dimensions': dimensions,
      'material': material,
      'color': color,
      'origin_country': originCountry,
      'warranty_months': warrantyMonths,
      'care_instructions': careInstructions,
      'features': features,
      'tags': tags,
      'average_rating': averageRating,
      'total_ratings': totalRatings,
      'rating_distribution': ratingDistribution,
      'view_count': viewCount,
      'is_featured': isFeatured,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (brand != null) 'brands': brand!.toJson(),
      if (type != null) 'product_types': type!.toJson(),
      if (variants != null)
        'product_variants': variants!.map((v) => v.toJson()).toList(),
      if (discounts != null)
        'product_discounts': discounts!.map((d) => d.toJson()).toList(),
      if (ratings != null)
        'product_ratings': ratings!.map((r) => r.toJson()).toList(),
      if (inventory != null)
        'inventory': inventory!.map((i) => i.toJson()).toList(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    final json = toJson();
    json.remove('id');
    json.remove('average_rating');
    json.remove('total_ratings');
    json.remove('rating_distribution');
    json.remove('view_count');
    json.remove('created_at');
    json.remove('updated_at');
    return json;
  }

  Map<String, dynamic> toUpdateJson({
    String? name,
    String? description,
    List<String>? imageUrls,
    String? sku,
    double? weight,
    Map<String, dynamic>? dimensions,
    String? material,
    String? color,
    String? originCountry,
    int? warrantyMonths,
    String? careInstructions,
    Map<String, dynamic>? features,
    List<String>? tags,
    bool? isFeatured,
    bool? isActive,
  }) {
    final Map<String, dynamic> updates = {};

    if (name != null) updates['name'] = name;
    if (description != null) updates['description'] = description;
    if (imageUrls != null) updates['image_urls'] = imageUrls;
    if (sku != null) updates['sku'] = sku;
    if (weight != null) updates['weight'] = weight;
    if (dimensions != null) updates['dimensions'] = dimensions;
    if (material != null) updates['material'] = material;
    if (color != null) updates['color'] = color;
    if (originCountry != null) updates['origin_country'] = originCountry;
    if (warrantyMonths != null) updates['warranty_months'] = warrantyMonths;
    if (careInstructions != null)
      updates['care_instructions'] = careInstructions;
    if (features != null) updates['features'] = features;
    if (tags != null) updates['tags'] = tags;
    if (isFeatured != null) updates['is_featured'] = isFeatured;
    if (isActive != null) updates['is_active'] = isActive;
    updates['updated_at'] = DateTime.now().toIso8601String();

    return updates;
  }

  Product toEntity() {
    return Product(
      id: id,
      brandId: brandId,
      typeId: typeId,
      name: name,
      description: description,
      imageUrls: imageUrls,
      sku: sku,
      weight: weight,
      dimensions: dimensions,
      material: material,
      color: color,
      originCountry: originCountry,
      warrantyMonths: warrantyMonths,
      careInstructions: careInstructions,
      features: features,
      tags: tags,
      averageRating: averageRating,
      totalRatings: totalRatings,
      ratingDistribution: ratingDistribution,
      viewCount: viewCount,
      isFeatured: isFeatured,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      brandId: product.brandId,
      typeId: product.typeId,
      name: product.name,
      description: product.description,
      imageUrls: product.imageUrls,
      sku: product.sku,
      weight: product.weight,
      dimensions: product.dimensions,
      material: product.material,
      color: product.color,
      originCountry: product.originCountry,
      warrantyMonths: product.warrantyMonths,
      careInstructions: product.careInstructions,
      features: product.features,
      tags: product.tags,
      averageRating: product.averageRating,
      totalRatings: product.totalRatings,
      ratingDistribution: product.ratingDistribution,
      viewCount: product.viewCount,
      isFeatured: product.isFeatured,
      isActive: product.isActive,
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
    );
  }

  /// Create ProductModel với data từ nhiều sources khác nhau
  factory ProductModel.fromMultipleJson(Map<String, dynamic> json) {
    return ProductModel.fromJson(json);
  }

  /// Parse danh sách ProductModel từ JSON array
  static List<ProductModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .where((json) => json is Map<String, dynamic>)
        .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Convert danh sách ProductModel sang JSON array
  static List<Map<String, dynamic>> toJsonList(List<ProductModel> products) {
    return products.map((product) => product.toJson()).toList();
  }

  /// Create ProductModel with validation
  factory ProductModel.validated(Map<String, dynamic> json) {
    final model = ProductModel.fromJson(json);
    final errors = model.validate();
    if (errors.isNotEmpty) {
      throw ValidationException(
          'Product validation failed: ${errors.join(', ')}');
    }
    return model;
  }

  /// Copy với updated fields
  ProductModel copyWith({
    int? id,
    int? brandId,
    int? typeId,
    String? name,
    String? description,
    List<String>? imageUrls,
    String? sku,
    double? weight,
    Map<String, dynamic>? dimensions,
    String? material,
    String? color,
    String? originCountry,
    int? warrantyMonths,
    String? careInstructions,
    Map<String, dynamic>? features,
    List<String>? tags,
    double? averageRating,
    int? totalRatings,
    Map<String, dynamic>? ratingDistribution,
    int? viewCount,
    bool? isFeatured,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      brandId: brandId ?? this.brandId,
      typeId: typeId ?? this.typeId,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrls: imageUrls ?? this.imageUrls,
      sku: sku ?? this.sku,
      weight: weight ?? this.weight,
      dimensions: dimensions ?? this.dimensions,
      material: material ?? this.material,
      color: color ?? this.color,
      originCountry: originCountry ?? this.originCountry,
      warrantyMonths: warrantyMonths ?? this.warrantyMonths,
      careInstructions: careInstructions ?? this.careInstructions,
      features: features ?? this.features,
      tags: tags ?? this.tags,
      averageRating: averageRating ?? this.averageRating,
      totalRatings: totalRatings ?? this.totalRatings,
      ratingDistribution: ratingDistribution ?? this.ratingDistribution,
      viewCount: viewCount ?? this.viewCount,
      isFeatured: isFeatured ?? this.isFeatured,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static int? _parseIntSafely(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  static double? _parseDoubleSafely(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
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
    if (value is String) {
      final lower = value.toLowerCase();
      if (lower == 'true' || lower == '1' || lower == 'yes') return true;
      if (lower == 'false' || lower == '0' || lower == 'no') return false;
    }
    if (value is int) return value != 0;
    return null;
  }

  static List<String>? _parseStringListSafely(dynamic value) {
    if (value == null) return null;
    if (value is List) {
      return value
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return null;
  }

  static Map<String, dynamic>? _parseMapSafely(dynamic value) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    if (value is String) {
      try {
        return Map<String, dynamic>.from(jsonDecode(value));
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static DateTime? _parseDateTimeSafely(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        try {
          final timestamp = int.tryParse(value);
          if (timestamp != null) {
            return DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
          }
        } catch (e) {
          return null;
        }
      }
    }
    if (value is int) {
      try {
        return DateTime.fromMillisecondsSinceEpoch(value * 1000);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static List<String>? _parseSingleImageUrl(dynamic value) {
    final url = _parseStringSafely(value);
    return url != null ? [url] : null;
  }

  static Map<String, dynamic>? _parseDimensionsFromFields(
      Map<String, dynamic> json) {
    final length = _parseDoubleSafely(json['length']);
    final width = _parseDoubleSafely(json['width']);
    final height = _parseDoubleSafely(json['height']);

    if (length != null || width != null || height != null) {
      return {
        if (length != null) 'length': length,
        if (width != null) 'width': width,
        if (height != null) 'height': height,
      };
    }
    return null;
  }

  static List<String>? _parseTagsFromString(dynamic value) {
    final tagString = _parseStringSafely(value);
    if (tagString != null) {
      return tagString
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();
    }
    return null;
  }

  static Map<String, dynamic>? _parseRatingDistribution(
      Map<String, dynamic> json) {
    // Try to parse rating distribution from separate fields
    final rating1 = _parseIntSafely(json['rating_1']) ?? 0;
    final rating2 = _parseIntSafely(json['rating_2']) ?? 0;
    final rating3 = _parseIntSafely(json['rating_3']) ?? 0;
    final rating4 = _parseIntSafely(json['rating_4']) ?? 0;
    final rating5 = _parseIntSafely(json['rating_5']) ?? 0;

    if (rating1 > 0 ||
        rating2 > 0 ||
        rating3 > 0 ||
        rating4 > 0 ||
        rating5 > 0) {
      return {
        "1": rating1,
        "2": rating2,
        "3": rating3,
        "4": rating4,
        "5": rating5,
      };
    }
    return null;
  }
}

class ValidationException implements Exception {
  final String message;

  const ValidationException(this.message);

  @override
  String toString() => 'ValidationException: $message';
}

extension ProductModelExtensions on ProductModel {
  bool get isValidForApi {
    return name.isNotEmpty && id >= 0 && validate().isEmpty;
  }

  Map<String, dynamic> toCompactJson() {
    final json = toJson();
    json.removeWhere((key, value) => value == null);
    return json;
  }

  String get logSummary {
    return 'ProductModel(id: $id, name: "$name", active: $isActive)';
  }

  ProductModel mergeWith(ProductModel other) {
    return copyWith(
      id: other.id != 0 ? other.id : id,
      brandId: other.brandId ?? brandId,
      typeId: other.typeId ?? typeId,
      name: other.name.isNotEmpty ? other.name : name,
      description: other.description ?? description,
      imageUrls: other.imageUrls ?? imageUrls,
      sku: other.sku ?? sku,
      weight: other.weight ?? weight,
      dimensions: other.dimensions ?? dimensions,
      material: other.material ?? material,
      color: other.color ?? color,
      originCountry: other.originCountry ?? originCountry,
      warrantyMonths:
          other.warrantyMonths != 0 ? other.warrantyMonths : warrantyMonths,
      careInstructions: other.careInstructions ?? careInstructions,
      features: other.features ?? features,
      tags: other.tags ?? tags,
      averageRating:
          other.averageRating != 0 ? other.averageRating : averageRating,
      totalRatings: other.totalRatings != 0 ? other.totalRatings : totalRatings,
      ratingDistribution: other.ratingDistribution.isNotEmpty
          ? other.ratingDistribution
          : ratingDistribution,
      viewCount: other.viewCount != 0 ? other.viewCount : viewCount,
      isFeatured: other.isFeatured,
      isActive: other.isActive,
      updatedAt: other.updatedAt,
    );
  }
}
