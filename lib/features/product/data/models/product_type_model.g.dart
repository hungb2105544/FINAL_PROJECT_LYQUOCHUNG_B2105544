// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_type_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductTypeModelAdapter extends TypeAdapter<ProductTypeModel> {
  @override
  final int typeId = 9;

  @override
  ProductTypeModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProductTypeModel(
      id: fields[0] as int,
      typeName: fields[1] as String,
      image_url: fields[4] as String?,
      description: fields[2] as String?,
      parent_id: fields[3] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, ProductTypeModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.typeName)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.parent_id)
      ..writeByte(4)
      ..write(obj.image_url);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductTypeModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
