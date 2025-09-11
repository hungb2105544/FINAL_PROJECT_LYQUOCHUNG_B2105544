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

  ProductTypeModel(
      {required this.id, required this.typeName, this.description});

  factory ProductTypeModel.fromJson(Map<String, dynamic> json) {
    return ProductTypeModel(
      id: json['id'],
      typeName: json['type_name'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type_name': typeName,
        'description': description,
      };
}
