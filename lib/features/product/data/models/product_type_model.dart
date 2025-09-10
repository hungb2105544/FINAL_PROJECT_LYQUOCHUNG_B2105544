class ProductTypeModel {
  final int id;
  final String typeName;
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
