class Ward {
  final int code;
  final String name;
  final String divisionType;
  final String codename;
  final int districtCode;

  Ward({
    required this.code,
    required this.name,
    required this.divisionType,
    required this.codename,
    required this.districtCode,
  });

  factory Ward.fromJson(Map<String, dynamic> json) {
    return Ward(
      code: json['code'],
      name: json['name'],
      divisionType: json['division_type'],
      codename: json['codename'],
      districtCode: json['district_code'],
    );
  }
  @override
  String toString() => name;
}
