import 'package:hive_flutter/hive_flutter.dart';
part 'product_rating_model.g.dart';

@HiveType(typeId: 6)
class ProductRatingModel {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final int rating;
  @HiveField(2)
  final String? title;
  @HiveField(3)
  final String? comment;
  @HiveField(4)
  final List<String>? images;
  @HiveField(5)
  final List<String>? pros;
  @HiveField(6)
  final List<String>? cons;
  @HiveField(7)
  final String? userId;
  @HiveField(8)
  final String createdAt;

  ProductRatingModel({
    required this.id,
    required this.rating,
    this.title,
    this.comment,
    this.images,
    this.pros,
    this.cons,
    this.userId,
    required this.createdAt,
  });

  factory ProductRatingModel.fromJson(Map<String, dynamic> json) {
    return ProductRatingModel(
      id: json['id'],
      rating: json['rating'],
      title: json['title'],
      comment: json['comment'],
      images: (json['images'] as List?)?.map((e) => e.toString()).toList(),
      pros: (json['pros'] as List?)?.map((e) => e.toString()).toList(),
      cons: (json['cons'] as List?)?.map((e) => e.toString()).toList(),
      userId: json['user_id'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'rating': rating,
        'title': title,
        'comment': comment,
        'images': images,
        'pros': pros,
        'cons': cons,
        'user_id': userId,
        'created_at': createdAt,
      };
}
