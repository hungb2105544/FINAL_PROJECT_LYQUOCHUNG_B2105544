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

  @HiveField(9)
  final int? productId;

  @HiveField(10)
  final int? orderItemId;

  @HiveField(11)
  final bool? isVerifiedPurchase;

  @HiveField(12)
  final bool? isAnonymous;

  @HiveField(13)
  final bool? isApproved;

  @HiveField(14)
  final int? helpfulCount;

  @HiveField(15)
  final String? updatedAt;

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
    this.productId,
    this.orderItemId,
    this.isVerifiedPurchase,
    this.isAnonymous,
    this.isApproved,
    this.helpfulCount,
    this.updatedAt,
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
      productId: json['product_id'],
      orderItemId: json['order_item_id'],
      isVerifiedPurchase: json['is_verified_purchase'],
      isAnonymous: json['is_anonymous'],
      isApproved: json['is_approved'],
      helpfulCount: json['helpful_count'],
      updatedAt: json['updated_at'],
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
        'product_id': productId,
        'order_item_id': orderItemId,
        'is_verified_purchase': isVerifiedPurchase,
        'is_anonymous': isAnonymous,
        'is_approved': isApproved,
        'helpful_count': helpfulCount,
        'updated_at': updatedAt,
      };

  ProductRatingModel copyWith({
    int? id,
    int? rating,
    String? title,
    String? comment,
    List<String>? images,
    List<String>? pros,
    List<String>? cons,
    String? userId,
    String? createdAt,
    int? productId,
    int? orderItemId,
    bool? isVerifiedPurchase,
    bool? isAnonymous,
    bool? isApproved,
    int? helpfulCount,
    String? updatedAt,
  }) {
    return ProductRatingModel(
      id: id ?? this.id,
      rating: rating ?? this.rating,
      title: title ?? this.title,
      comment: comment ?? this.comment,
      images: images ?? this.images,
      pros: pros ?? this.pros,
      cons: cons ?? this.cons,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      productId: productId ?? this.productId,
      orderItemId: orderItemId ?? this.orderItemId,
      isVerifiedPurchase: isVerifiedPurchase ?? this.isVerifiedPurchase,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      isApproved: isApproved ?? this.isApproved,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
