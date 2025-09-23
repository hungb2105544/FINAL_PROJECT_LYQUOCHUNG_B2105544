// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_variant_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductVariantModelAdapter extends TypeAdapter<ProductVariantModel> {
  @override
  final int typeId = 12;

  @override
  ProductVariantModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProductVariantModel(
      id: fields[0] as int,
      color: fields[1] as String,
      sku: fields[2] as String,
      additionalPrice: fields[3] as double,
      isActive: fields[4] as bool,
      sizes: (fields[5] as List?)?.cast<Sizes>(),
      images: (fields[6] as List?)?.cast<ProductVariantImageModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, ProductVariantModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.color)
      ..writeByte(2)
      ..write(obj.sku)
      ..writeByte(3)
      ..write(obj.additionalPrice)
      ..writeByte(4)
      ..write(obj.isActive)
      ..writeByte(5)
      ..write(obj.sizes)
      ..writeByte(6)
      ..write(obj.images);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductVariantModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProductVariantImageModelAdapter
    extends TypeAdapter<ProductVariantImageModel> {
  @override
  final int typeId = 10;

  @override
  ProductVariantImageModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProductVariantImageModel(
      id: fields[0] as int,
      imageUrl: fields[1] as String,
      sortOrder: fields[2] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, ProductVariantImageModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.imageUrl)
      ..writeByte(2)
      ..write(obj.sortOrder);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductVariantImageModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SimplifiedVariantModelAdapter
    extends TypeAdapter<SimplifiedVariantModel> {
  @override
  final int typeId = 14;

  @override
  SimplifiedVariantModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SimplifiedVariantModel(
      color: fields[0] as String,
      imageUrl: fields[1] as String?,
      variantId: fields[2] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, SimplifiedVariantModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.color)
      ..writeByte(1)
      ..write(obj.imageUrl)
      ..writeByte(2)
      ..write(obj.variantId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SimplifiedVariantModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
