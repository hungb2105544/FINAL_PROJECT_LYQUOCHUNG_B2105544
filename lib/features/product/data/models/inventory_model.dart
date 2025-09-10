class InventoryModel {
  final int id;
  final int branchId;
  final int quantity;
  final int reservedQuantity;
  final BranchModel? branch;

  InventoryModel({
    required this.id,
    required this.branchId,
    required this.quantity,
    required this.reservedQuantity,
    this.branch,
  });

  factory InventoryModel.fromJson(Map<String, dynamic> json) {
    return InventoryModel(
      id: json['id'],
      branchId: json['branch_id'],
      quantity: json['quantity'],
      reservedQuantity: json['reserved_quantity'],
      branch: json['branches'] != null
          ? BranchModel.fromJson(json['branches'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'branch_id': branchId,
        'quantity': quantity,
        'reserved_quantity': reservedQuantity,
        if (branch != null) 'branches': branch!.toJson(),
      };
}

class BranchModel {
  final int id;
  final String name;
  final String phone;

  BranchModel({required this.id, required this.name, required this.phone});

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
      };
}
