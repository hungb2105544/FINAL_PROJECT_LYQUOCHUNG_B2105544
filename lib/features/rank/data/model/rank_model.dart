class RankLevelModel {
  final int id;
  final String name;
  final int minPoints;
  final int? maxPoints;
  final Map<String, dynamic>? benefits;
  final String? colorCode;
  final int sortOrder;

  RankLevelModel({
    required this.id,
    required this.name,
    required this.minPoints,
    this.maxPoints,
    this.benefits,
    this.colorCode,
    this.sortOrder = 0,
  });

  factory RankLevelModel.fromJson(Map<String, dynamic> json) {
    return RankLevelModel(
      id: json['id'] as int,
      name: json['name'] as String,
      minPoints: json['min_points'] as int,
      maxPoints: json['max_points'] as int?,
      benefits: json['benefits'] != null
          ? Map<String, dynamic>.from(json['benefits'])
          : null,
      colorCode: json['color_code'] as String?,
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }

  /// Model -> JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'min_points': minPoints,
      'max_points': maxPoints,
      'benefits': benefits,
      'color_code': colorCode,
      'sort_order': sortOrder,
    };
  }

  RankLevelModel copyWith({
    int? id,
    String? name,
    int? minPoints,
    int? maxPoints,
    Map<String, dynamic>? benefits,
    String? colorCode,
    int? sortOrder,
  }) {
    return RankLevelModel(
      id: id ?? this.id,
      name: name ?? this.name,
      minPoints: minPoints ?? this.minPoints,
      maxPoints: maxPoints ?? this.maxPoints,
      benefits: benefits ?? this.benefits,
      colorCode: colorCode ?? this.colorCode,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  String toString() {
    return 'RankLevelModel(id: $id, name: $name, minPoints: $minPoints, maxPoints: $maxPoints, '
        'benefits: $benefits, colorCode: $colorCode, sortOrder: $sortOrder)';
  }
}
