class ProductVariantModel {
  final int id;
  final String color;
  final String sku;
  final double additionalPrice;
  final bool isActive;
  final List<ProductSizeModel>? sizes;
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
        id: json['id'],
        color: json['color'],
        sku: json['sku'],
        additionalPrice: (json['additional_price'] as num).toDouble(),
        isActive: json['is_active'],
        sizes: (json['product_sizes'] as List<dynamic>?)
            ?.map((s) => ProductSizeModel.fromJson(s))
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

class ProductSizeModel {
  final int id;
  final String sizeName;

  ProductSizeModel({required this.id, required this.sizeName});

  factory ProductSizeModel.fromJson(Map<String, dynamic> json) {
    return ProductSizeModel(
      id: json['id'],
      sizeName: json['size_name'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'size_name': sizeName,
      };
}

class ProductVariantImageModel {
  final int id;
  final String imageUrl;
  final int? sortOrder;

  ProductVariantImageModel(
      {required this.id, required this.imageUrl, this.sortOrder});

  factory ProductVariantImageModel.fromJson(Map<String, dynamic> json) {
    return ProductVariantImageModel(
      id: json['id'],
      imageUrl: json['image_url'],
      sortOrder: json['sort_order'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'image_url': imageUrl,
        'sort_order': sortOrder,
      };
}
