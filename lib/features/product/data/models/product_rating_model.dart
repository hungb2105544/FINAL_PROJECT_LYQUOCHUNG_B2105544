class ProductRatingModel {
  final int id;
  final int rating;
  final String? title;
  final String? comment;
  final List<String>? images;
  final List<String>? pros;
  final List<String>? cons;
  final String? userId;
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
