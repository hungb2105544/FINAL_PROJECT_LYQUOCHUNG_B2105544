// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_discount.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductDiscountModelAdapter extends TypeAdapter<ProductDiscountModel> {
  @override
  final int typeId = 4;

  @override
  ProductDiscountModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProductDiscountModel(
      id: fields[0] as int,
      discountPercentage: fields[1] as int?,
      discountAmount: fields[2] as num?,
      startDate: fields[3] as String,
      endDate: fields[4] as String,
      isActive: fields[5] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, ProductDiscountModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.discountPercentage)
      ..writeByte(2)
      ..write(obj.discountAmount)
      ..writeByte(3)
      ..write(obj.startDate)
      ..writeByte(4)
      ..write(obj.endDate)
      ..writeByte(5)
      ..write(obj.isActive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductDiscountModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
