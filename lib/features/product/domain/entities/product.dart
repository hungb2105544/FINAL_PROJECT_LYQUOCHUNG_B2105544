import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final int id;
  final int? brandId;
  final int? typeId;
  final String name;
  final String? description;
  final List<String>? imageUrls;
  final String? sku;
  final double? weight;
  final Map<String, dynamic>? dimensions;
  final String? material;
  final String? color;
  final String? originCountry;
  final int warrantyMonths;
  final String? careInstructions;
  final Map<String, dynamic>? features;
  final List<String>? tags;
  final double averageRating;
  final int totalRatings;
  final Map<String, dynamic> ratingDistribution;
  final int viewCount;
  final bool isFeatured;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Product({
    required this.id,
    this.brandId,
    this.typeId,
    required this.name,
    this.description,
    this.imageUrls,
    this.sku,
    this.weight,
    this.dimensions,
    this.material,
    this.color,
    this.originCountry,
    this.warrantyMonths = 0,
    this.careInstructions,
    this.features,
    this.tags,
    this.averageRating = 0.0,
    this.totalRatings = 0,
    this.ratingDistribution = const {"1": 0, "2": 0, "3": 0, "4": 0, "5": 0},
    this.viewCount = 0,
    this.isFeatured = false,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert từ JSON (Supabase/Postgres row) sang Product
  factory Product.fromJson(Map<String, dynamic> json) {
    try {
      return Product(
        id: _parseIntSafely(json['id']) ?? 0,
        brandId: _parseIntSafely(json['brand_id']),
        typeId: _parseIntSafely(json['type_id']),
        name: _parseStringSafely(json['name']) ?? '',
        description: _parseStringSafely(json['description']),
        imageUrls: _parseStringListSafely(json['image_urls']),
        sku: _parseStringSafely(json['sku']),
        weight: _parseDoubleSafely(json['weight']),
        dimensions: _parseMapSafely(json['dimensions']),
        material: _parseStringSafely(json['material']),
        color: _parseStringSafely(json['color']),
        originCountry: _parseStringSafely(json['origin_country']),
        warrantyMonths: _parseIntSafely(json['warranty_months']) ?? 0,
        careInstructions: _parseStringSafely(json['care_instructions']),
        features: _parseMapSafely(json['features']),
        tags: _parseStringListSafely(json['tags']),
        averageRating: _parseDoubleSafely(json['average_rating']) ?? 0.0,
        totalRatings: _parseIntSafely(json['total_ratings']) ?? 0,
        ratingDistribution: _parseMapSafely(json['rating_distribution']) ??
            const {"1": 0, "2": 0, "3": 0, "4": 0, "5": 0},
        viewCount: _parseIntSafely(json['view_count']) ?? 0,
        isFeatured: _parseBoolSafely(json['is_featured']) ?? false,
        isActive: _parseBoolSafely(json['is_active']) ?? true,
        createdAt: _parseDateTimeSafely(json['created_at']) ?? DateTime.now(),
        updatedAt: _parseDateTimeSafely(json['updated_at']) ?? DateTime.now(),
      );
    } catch (e) {
      throw FormatException('Error parsing Product from JSON: $e');
    }
  }

  /// Convert Product sang JSON (để insert/update Supabase)
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
    };
  }

  /// Convert Product sang JSON cho insert (không bao gồm id)
  Map<String, dynamic> toInsertJson() {
    final json = toJson();
    json.remove('id'); // Remove id for insert operations
    return json;
  }

  /// Convert Product sang JSON cho update (chỉ fields được thay đổi)
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

    // Always update the updated_at field
    updates['updated_at'] = DateTime.now().toIso8601String();

    return updates;
  }

  /// Create a copy of Product with updated fields
  Product copyWith({
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
    return Product(
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

  // Utility getters
  String get primaryImageUrl =>
      imageUrls?.isNotEmpty == true ? imageUrls!.first : '';

  bool get hasImages => imageUrls?.isNotEmpty == true;

  bool get isInStock => isActive;

  String get formattedRating => averageRating.toStringAsFixed(1);

  bool get hasRatings => totalRatings > 0;

  String get warrantyText => warrantyMonths > 0
      ? '$warrantyMonths ${warrantyMonths == 1 ? 'month' : 'months'} warranty'
      : 'No warranty';

  // Validation methods
  bool get isValid {
    return name.isNotEmpty &&
        id > 0 &&
        averageRating >= 0 &&
        averageRating <= 5 &&
        totalRatings >= 0 &&
        warrantyMonths >= 0;
  }

  List<String> validate() {
    final List<String> errors = [];

    if (name.isEmpty) errors.add('Product name is required');
    if (id <= 0) errors.add('Product ID must be positive');
    if (averageRating < 0 || averageRating > 5) {
      errors.add('Average rating must be between 0 and 5');
    }
    if (totalRatings < 0) errors.add('Total ratings cannot be negative');
    if (warrantyMonths < 0) errors.add('Warranty months cannot be negative');
    if (weight != null && weight! < 0) errors.add('Weight cannot be negative');

    return errors;
  }

  @override
  List<Object?> get props => [
        id,
        brandId,
        typeId,
        name,
        description,
        imageUrls,
        sku,
        weight,
        dimensions,
        material,
        color,
        originCountry,
        warrantyMonths,
        careInstructions,
        features,
        tags,
        averageRating,
        totalRatings,
        ratingDistribution,
        viewCount,
        isFeatured,
        isActive,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'Product(id: $id, name: $name, averageRating: $averageRating, isActive: $isActive)';
  }

  // Safe parsing helper methods
  static int? _parseIntSafely(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value);
    }
    if (value is double) return value.toInt();
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
    return value.toString();
  }

  static bool? _parseBoolSafely(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true';
    }
    if (value is int) return value != 0;
    return null;
  }

  static List<String>? _parseStringListSafely(dynamic value) {
    if (value == null) return null;
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return null;
  }

  static Map<String, dynamic>? _parseMapSafely(dynamic value) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }

  static DateTime? _parseDateTimeSafely(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}

// Extension methods for additional functionality
extension ProductExtensions on Product {
  /// Get product age in days
  int get ageInDays {
    return DateTime.now().difference(createdAt).inDays;
  }

  /// Check if product is newly added (less than 7 days)
  bool get isNew {
    return ageInDays < 7;
  }

  /// Get popularity score based on views and ratings
  double get popularityScore {
    final viewScore = viewCount * 0.1;
    final ratingScore = averageRating * totalRatings * 0.5;
    return viewScore + ratingScore;
  }

  /// Check if product has high rating (>= 4.0)
  bool get hasHighRating {
    return averageRating >= 4.0 && totalRatings > 0;
  }

  /// Get main category from features if available
  String? get mainCategory {
    return features?['category'] as String?;
  }

  /// Check if product matches search query
  bool matchesSearch(String query) {
    final searchQuery = query.toLowerCase();
    return name.toLowerCase().contains(searchQuery) ||
        (description?.toLowerCase().contains(searchQuery) ?? false) ||
        (tags?.any((tag) => tag.toLowerCase().contains(searchQuery)) ??
            false) ||
        (sku?.toLowerCase().contains(searchQuery) ?? false);
  }

  /// Get formatted dimension string
  String get formattedDimensions {
    if (dimensions == null || dimensions!.isEmpty) return 'N/A';

    final length = dimensions!['length'];
    final width = dimensions!['width'];
    final height = dimensions!['height'];

    if (length != null && width != null && height != null) {
      return '${length}cm × ${width}cm × ${height}cm';
    }

    return dimensions.toString();
  }
}

// Factory methods for common use cases
extension ProductFactory on Product {
  /// Create an empty product for form initialization
  static Product empty() {
    return Product(
      id: 0,
      name: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Create a product template with common defaults
  static Product template({
    required String name,
    String? description,
    int? brandId,
    int? typeId,
  }) {
    final now = DateTime.now();
    return Product(
      id: 0, // Will be set by database
      name: name,
      description: description,
      brandId: brandId,
      typeId: typeId,
      createdAt: now,
      updatedAt: now,
      isActive: true,
      isFeatured: false,
    );
  }
}
