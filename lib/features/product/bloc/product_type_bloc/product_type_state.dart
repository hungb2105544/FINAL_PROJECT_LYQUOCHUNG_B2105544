import 'package:ecommerce_app/features/product/data/models/product_type_model.dart';
import 'package:equatable/equatable.dart';

sealed class ProductTypeState extends Equatable {
  const ProductTypeState();

  @override
  List<Object> get props => [];
}

final class ProductTypeInitial extends ProductTypeState {
  const ProductTypeInitial();
}

final class ProductTypeLoading extends ProductTypeState {
  const ProductTypeLoading();
}

final class ProductTypeLoaded extends ProductTypeState {
  final List<ProductTypeModel> productTypes;

  const ProductTypeLoaded(this.productTypes);

  @override
  List<Object> get props => [productTypes];

  // Thêm copyWith để dễ dàng cập nhật state
  ProductTypeLoaded copyWith({List<ProductTypeModel>? productTypes}) {
    return ProductTypeLoaded(productTypes ?? this.productTypes);
  }
}

final class ProductTypeFailure extends ProductTypeState {
  final String message;

  const ProductTypeFailure(this.message);

  @override
  List<Object> get props => [message];
}
