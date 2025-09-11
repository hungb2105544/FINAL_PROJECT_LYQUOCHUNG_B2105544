// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sizes.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SizesAdapter extends TypeAdapter<Sizes> {
  @override
  final int typeId = 11;

  @override
  Sizes read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Sizes(
      id: fields[0] as int,
      sizeName: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Sizes obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.sizeName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SizesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
