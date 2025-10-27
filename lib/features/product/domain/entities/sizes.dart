import 'package:hive/hive.dart';
part 'sizes.g.dart';

@HiveType(typeId: 11)
class Sizes {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String sizeName;

  Sizes({required this.id, required this.sizeName});

  factory Sizes.fromJson(Map<String, dynamic> json) {
    return Sizes(
      id: json['id'],
      sizeName: json['size_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'size_name': sizeName,
      };
}
