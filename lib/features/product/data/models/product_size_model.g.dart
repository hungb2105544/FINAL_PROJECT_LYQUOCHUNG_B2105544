// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_size_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductSizeModelAdapter extends TypeAdapter<ProductSizeModel> {
  @override
  final int typeId = 8;

  @override
  ProductSizeModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProductSizeModel(
      id: fields[0] as int,
      productId: fields[1] as int,
      sizeId: fields[2] as int?,
      size: fields[3] as SizeModel?,
      createdAt: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ProductSizeModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.productId)
      ..writeByte(2)
      ..write(obj.sizeId)
      ..writeByte(3)
      ..write(obj.size)
      ..writeByte(4)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductSizeModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SizeModelAdapter extends TypeAdapter<SizeModel> {
  @override
  final int typeId = 7;

  @override
  SizeModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SizeModel(
      id: fields[0] as int,
      sizeName: fields[1] as String,
      sortOrder: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, SizeModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.sizeName)
      ..writeByte(2)
      ..write(obj.sortOrder);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SizeModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
