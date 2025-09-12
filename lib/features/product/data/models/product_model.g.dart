// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductModelAdapter extends TypeAdapter<ProductModel> {
  @override
  final int typeId = 13;

  @override
  ProductModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProductModel(
      id: fields[0] as int,
      brandId: fields[1] as int?,
      typeId: fields[2] as int?,
      name: fields[3] as String,
      description: fields[4] as String?,
      imageUrls: (fields[5] as List?)?.cast<String>(),
      sku: fields[6] as String?,
      weight: fields[7] as double?,
      dimensions: (fields[8] as Map?)?.cast<String, dynamic>(),
      material: fields[9] as String?,
      color: fields[10] as String?,
      originCountry: fields[11] as String?,
      warrantyMonths: fields[12] as int,
      careInstructions: fields[13] as String?,
      features: (fields[14] as Map?)?.cast<String, dynamic>(),
      tags: (fields[15] as List?)?.cast<String>(),
      averageRating: fields[16] as double,
      totalRatings: fields[17] as int,
      ratingDistribution: (fields[18] as Map).cast<String, dynamic>(),
      viewCount: fields[19] as int,
      isFeatured: fields[20] as bool,
      isActive: fields[21] as bool,
      brand: fields[24] as BrandModel?,
      type: fields[25] as ProductTypeModel?,
      discounts: (fields[27] as List?)?.cast<ProductDiscountModel>(),
      inventory: (fields[29] as List?)?.cast<InventoryModel>(),
      ratings: (fields[28] as List?)?.cast<ProductRatingModel>(),
      variants: (fields[26] as List?)?.cast<ProductVariantModel>(),
      priceHistoryModel:
          (fields[30] as List?)?.cast<ProductPriceHistoryModel>(),
      productSize: (fields[31] as List?)?.cast<ProductSizeModel>(),
      simplifiedVariants: (fields[32] as List?)?.cast<SimplifiedVariantModel>(),
      createdAt: fields[22] as DateTime,
      updatedAt: fields[23] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ProductModel obj) {
    writer
      ..writeByte(33)
      ..writeByte(24)
      ..write(obj.brand)
      ..writeByte(25)
      ..write(obj.type)
      ..writeByte(26)
      ..write(obj.variants)
      ..writeByte(27)
      ..write(obj.discounts)
      ..writeByte(28)
      ..write(obj.ratings)
      ..writeByte(29)
      ..write(obj.inventory)
      ..writeByte(30)
      ..write(obj.priceHistoryModel)
      ..writeByte(31)
      ..write(obj.productSize)
      ..writeByte(32)
      ..write(obj.simplifiedVariants)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.brandId)
      ..writeByte(2)
      ..write(obj.typeId)
      ..writeByte(3)
      ..write(obj.name)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.imageUrls)
      ..writeByte(6)
      ..write(obj.sku)
      ..writeByte(7)
      ..write(obj.weight)
      ..writeByte(8)
      ..write(obj.dimensions)
      ..writeByte(9)
      ..write(obj.material)
      ..writeByte(10)
      ..write(obj.color)
      ..writeByte(11)
      ..write(obj.originCountry)
      ..writeByte(12)
      ..write(obj.warrantyMonths)
      ..writeByte(13)
      ..write(obj.careInstructions)
      ..writeByte(14)
      ..write(obj.features)
      ..writeByte(15)
      ..write(obj.tags)
      ..writeByte(16)
      ..write(obj.averageRating)
      ..writeByte(17)
      ..write(obj.totalRatings)
      ..writeByte(18)
      ..write(obj.ratingDistribution)
      ..writeByte(19)
      ..write(obj.viewCount)
      ..writeByte(20)
      ..write(obj.isFeatured)
      ..writeByte(21)
      ..write(obj.isActive)
      ..writeByte(22)
      ..write(obj.createdAt)
      ..writeByte(23)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
