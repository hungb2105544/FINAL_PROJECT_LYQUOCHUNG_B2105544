import 'package:ecommerce_app/features/address/data/model/ward_model.dart';

class District {
  final int code;
  final String name;
  final String divisionType;
  final String codename;
  final int provinceCode;
  final List<Ward> wards;

  District({
    required this.code,
    required this.name,
    required this.divisionType,
    required this.codename,
    required this.provinceCode,
    required this.wards,
  });

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      code: json['code'],
      name: json['name'],
      divisionType: json['division_type'],
      codename: json['codename'],
      provinceCode: json['province_code'],
      wards:
          (json['wards'] as List? ?? []).map((w) => Ward.fromJson(w)).toList(),
    );
  }
  @override
  String toString() => name;
}
