import 'package:hive_flutter/hive_flutter.dart';
part 'product_type_model.g.dart';

@HiveType(typeId: 9)
class ProductTypeModel {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String typeName;
  @HiveField(2)
  final String? description;
  @HiveField(3)
  final int? parent_id;
  @HiveField(4)
  final String? image_url;
  ProductTypeModel(
      {required this.id,
      required this.typeName,
      this.image_url,
      this.description,
      this.parent_id});

  factory ProductTypeModel.fromJson(Map<String, dynamic> json) {
    return ProductTypeModel(
        id: (json['id'] as num?)?.toInt() ?? 0,
        typeName: json['type_name'] as String? ?? '',
        description: json['description'] as String?,
        image_url: json['image_url'] as String?,
        parent_id: (json['parent_id'] as num?)?.toInt());
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type_name': typeName,
        'description': description,
        'image_url': image_url,
        'parent_id': parent_id
      };
}
