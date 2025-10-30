// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_rating_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductRatingModelAdapter extends TypeAdapter<ProductRatingModel> {
  @override
  final int typeId = 6;

  @override
  ProductRatingModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProductRatingModel(
      id: fields[0] as int,
      rating: fields[1] as int,
      title: fields[2] as String?,
      comment: fields[3] as String?,
      images: (fields[4] as List?)?.cast<String>(),
      pros: (fields[5] as List?)?.cast<String>(),
      cons: (fields[6] as List?)?.cast<String>(),
      userId: fields[7] as String?,
      createdAt: fields[8] as String,
      productId: fields[9] as int?,
      orderItemId: fields[10] as int?,
      isVerifiedPurchase: fields[11] as bool?,
      isAnonymous: fields[12] as bool?,
      isApproved: fields[13] as bool?,
      helpfulCount: fields[14] as int?,
      updatedAt: fields[15] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ProductRatingModel obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.rating)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.comment)
      ..writeByte(4)
      ..write(obj.images)
      ..writeByte(5)
      ..write(obj.pros)
      ..writeByte(6)
      ..write(obj.cons)
      ..writeByte(7)
      ..write(obj.userId)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.productId)
      ..writeByte(10)
      ..write(obj.orderItemId)
      ..writeByte(11)
      ..write(obj.isVerifiedPurchase)
      ..writeByte(12)
      ..write(obj.isAnonymous)
      ..writeByte(13)
      ..write(obj.isApproved)
      ..writeByte(14)
      ..write(obj.helpfulCount)
      ..writeByte(15)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductRatingModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
