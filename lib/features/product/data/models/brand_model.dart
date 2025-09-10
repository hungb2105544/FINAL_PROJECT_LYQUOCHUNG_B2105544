class BrandModel {
  final int id;
  final String brandName;
  final String? imageUrl;
  final String? description;

  BrandModel(
      {required this.id,
      required this.brandName,
      this.imageUrl,
      this.description});

  factory BrandModel.fromJson(Map<String, dynamic> json) {
    return BrandModel(
      id: json['id'],
      brandName: json['brand_name'],
      imageUrl: json['image_url'],
      description: json['description'],
    );
  }
  Map<String, dynamic> toJson() => {
        'id': id,
        'brand_name': brandName,
        'image_url': imageUrl,
        'description': description,
      };
}
