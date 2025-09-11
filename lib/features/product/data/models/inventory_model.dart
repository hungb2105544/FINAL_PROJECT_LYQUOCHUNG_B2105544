import 'package:hive_flutter/hive_flutter.dart';
part 'inventory_model.g.dart';

@HiveType(typeId: 3)
class InventoryModel {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final int branchId;
  @HiveField(2)
  final int quantity;
  @HiveField(3)
  final int reservedQuantity;
  @HiveField(4)
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

@HiveType(typeId: 2)
class BranchModel {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String name;
  @HiveField(2)
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
