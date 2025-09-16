// import 'dart:convert';
// import 'package:ecommerce_app/features/address/data/model/province_model.dart';
// import 'package:ecommerce_app/features/address/data/model/ward_model.dart';
// import 'package:http/http.dart' as http;

// class VietnamApiService {
//   static const String baseUrl = "https://provinces.open-api.vn/api/v1";

//   /// Lấy danh sách tất cả tỉnh/thành phố
//   static Future<List<Province>> getProvinces({int depth = 1}) async {
//     final response = await http.get(Uri.parse("$baseUrl/p/?depth=$depth"));
//     if (response.statusCode == 200) {
//       final List data = jsonDecode(response.body);
//       return data.map((e) => Province.fromJson(e)).toList();
//     } else {
//       throw Exception("Failed to load provinces");
//     }
//   }

//   /// Lấy chi tiết 1 tỉnh theo code
//   static Future<Province> getProvince(int code, {int depth = 1}) async {
//     final response = await http.get(Uri.parse("$baseUrl/p/$code?depth=$depth"));
//     if (response.statusCode == 200) {
//       return Province.fromJson(jsonDecode(response.body));
//     } else {
//       throw Exception("Failed to load province");
//     }
//   }

//   static Future<Ward> getWard(int code) async {
//     final response =
//         await http.get(Uri.parse("https://provinces.open-api.vn/api/w/$code"));
//     if (response.statusCode == 200) {
//       return Ward.fromJson(jsonDecode(response.body));
//     } else {
//       throw Exception("Failed to load ward. Status: ${response.statusCode}");
//     }
//   }

//   /// Tìm kiếm tỉnh/thành
//   static Future<List<dynamic>> searchProvinces(String query) async {
//     final response = await http.get(Uri.parse("$baseUrl/p/search/?q=$query"));
//     if (response.statusCode == 200) {
//       return jsonDecode(response.body);
//     } else {
//       throw Exception("Search failed");
//     }
//   }
// }
import 'dart:convert';
import 'package:ecommerce_app/features/address/data/model/district_model.dart';
import 'package:ecommerce_app/features/address/data/model/province_model.dart';
import 'package:ecommerce_app/features/address/data/model/ward_model.dart';
import 'package:http/http.dart' as http;

class VietnamApiService {
  static const String baseUrl = "https://provinces.open-api.vn/api/v1";

  /// ===================== PROVINCE =====================

  /// Lấy danh sách tất cả tỉnh/thành phố
  static Future<List<Province>> getProvinces({int depth = 1}) async {
    final response = await http.get(Uri.parse("$baseUrl/p/?depth=$depth"));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Province.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load provinces");
    }
  }

  /// Lấy chi tiết 1 tỉnh theo code
  static Future<Province> getProvince(int code, {int depth = 1}) async {
    final response = await http.get(Uri.parse("$baseUrl/p/$code?depth=$depth"));
    if (response.statusCode == 200) {
      return Province.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to load province");
    }
  }

  /// Tìm kiếm tỉnh
  static Future<List<dynamic>> searchProvinces(String query) async {
    final response = await http.get(Uri.parse("$baseUrl/p/search/?q=$query"));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Search provinces failed");
    }
  }

  /// ===================== DISTRICT =====================

  /// Lấy danh sách tất cả district
  static Future<List<District>> getDistricts() async {
    final response = await http.get(Uri.parse("$baseUrl/d/"));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => District.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load districts");
    }
  }

  /// Lấy chi tiết district theo code
  static Future<District> getDistrict(int code, {int depth = 1}) async {
    final response = await http.get(Uri.parse("$baseUrl/d/$code?depth=$depth"));
    if (response.statusCode == 200) {
      return District.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to load district");
    }
  }

  /// Search district theo tên
  static Future<List<dynamic>> searchDistricts(String query,
      {int? provinceCode}) async {
    final uri = Uri.parse("$baseUrl/d/search/").replace(queryParameters: {
      "q": query,
      if (provinceCode != null) "p": provinceCode.toString(),
    });

    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Search districts failed");
    }
  }

  /// ===================== WARD =====================

  /// Lấy danh sách tất cả ward
  static Future<List<Ward>> getWards(int code, int depth) async {
    final response = await http.get(Uri.parse("$baseUrl/w/"));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Ward.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load wards");
    }
  }

  /// Lấy chi tiết ward theo code
  static Future<Ward> getWard(int code) async {
    final response = await http.get(Uri.parse("$baseUrl/w/$code"));
    if (response.statusCode == 200) {
      return Ward.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to load ward");
    }
  }

  /// Search ward theo tên
  static Future<List<dynamic>> searchWards(String query,
      {int? districtCode, int? provinceCode}) async {
    final uri = Uri.parse("$baseUrl/w/search/").replace(queryParameters: {
      "q": query,
      if (districtCode != null) "d": districtCode.toString(),
      if (provinceCode != null) "p": provinceCode.toString(),
    });

    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Search wards failed");
    }
  }

  /// ===================== VERSION =====================

  /// Lấy version của dataset
  static Future<String> getVersion() async {
    final response = await http.get(Uri.parse("$baseUrl/version"));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["data_version"];
    } else {
      throw Exception("Failed to load version");
    }
  }
}
