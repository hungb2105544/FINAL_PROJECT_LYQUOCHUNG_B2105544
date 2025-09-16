import 'package:ecommerce_app/features/address/data/model/district_model.dart';

class Province {
  final int code;
  final String name;
  final String divisionType;
  final String codename;
  final int phoneCode;
  final List<District> districts;

  Province({
    required this.code,
    required this.name,
    required this.divisionType,
    required this.codename,
    required this.phoneCode,
    required this.districts,
  });

  factory Province.fromJson(Map<String, dynamic> json) {
    return Province(
      code: json['code'],
      name: json['name'],
      divisionType: json['division_type'],
      codename: json['codename'],
      phoneCode: json['phone_code'],
      districts: (json['districts'] as List? ?? [])
          .map((d) => District.fromJson(d))
          .toList(),
    );
  }
}
