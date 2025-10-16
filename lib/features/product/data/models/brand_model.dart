import 'package:hive/hive.dart';
part 'brand_model.g.dart';

@HiveType(typeId: 1)
class BrandModel {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String brandName;
  @HiveField(2)
  final String? imageUrl;
  @HiveField(3)
  final String? description;

  BrandModel(
      {required this.id,
      required this.brandName,
      this.imageUrl,
      this.description});

  factory BrandModel.fromJson(Map<String, dynamic> json) {
    return BrandModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      brandName: json['brand_name'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      description: json['description'] as String?,
    );
  }
  Map<String, dynamic> toJson() => {
        'id': id,
        'brand_name': brandName,
        'image_url': imageUrl,
        'description': description,
      };
}
