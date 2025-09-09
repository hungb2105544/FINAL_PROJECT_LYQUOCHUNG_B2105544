import 'package:ecommerce_app/features/product/data/models/product_model.dart';
import 'package:equatable/equatable.dart';

class ProductState extends Equatable {
  final List<ProductModel> products;
  final bool isLoading;
  final String? errorMessage;
  const ProductState({
    this.products = const [],
    this.isLoading = false,
    this.errorMessage, // Provide default empty list
  });

  @override
  List<Object?> get props => [products, isLoading, errorMessage];

  ProductState copyWith({
    List<ProductModel>? products,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ProductState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
