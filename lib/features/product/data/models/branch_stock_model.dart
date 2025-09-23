// Model cho stock response
class BranchStockModel {
  final int branchId;
  final String branchName;
  final int productId;
  final int? variantId;
  final int availableStock;
  final double distanceKm;

  BranchStockModel({
    required this.branchId,
    required this.branchName,
    required this.productId,
    this.variantId,
    required this.availableStock,
    required this.distanceKm,
  });

  factory BranchStockModel.fromJson(Map<String, dynamic> json) {
    return BranchStockModel(
      branchId: json['branch_id'],
      branchName: json['branch_name'],
      productId: json['product_id'],
      variantId: json['variant_id'],
      availableStock: json['available_stock'],
      distanceKm: (json['distance_km'] as num).toDouble(),
    );
  }
}
