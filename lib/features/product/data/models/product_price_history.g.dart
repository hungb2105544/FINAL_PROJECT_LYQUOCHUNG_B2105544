// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_price_history.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductPriceHistoryModelAdapter
    extends TypeAdapter<ProductPriceHistoryModel> {
  @override
  final int typeId = 5;

  @override
  ProductPriceHistoryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProductPriceHistoryModel(
      id: fields[0] as int,
      productId: fields[1] as int?,
      price: fields[2] as double,
      effectiveDate: fields[3] as DateTime,
      endDate: fields[4] as DateTime?,
      isActive: fields[5] as bool,
      createdBy: fields[6] as String?,
      createdAt: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ProductPriceHistoryModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.productId)
      ..writeByte(2)
      ..write(obj.price)
      ..writeByte(3)
      ..write(obj.effectiveDate)
      ..writeByte(4)
      ..write(obj.endDate)
      ..writeByte(5)
      ..write(obj.isActive)
      ..writeByte(6)
      ..write(obj.createdBy)
      ..writeByte(7)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductPriceHistoryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
