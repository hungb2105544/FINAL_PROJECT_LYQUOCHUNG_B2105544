import 'package:ecommerce_app/features/product/data/models/product_model.dart';
import 'package:equatable/equatable.dart';

class FavoriteState extends Equatable {
  final bool isLoading;
  final List<ProductModel> favoriteProducts;
  final Set<int> favoriteProductIds;
  final String? error;

  const FavoriteState({
    this.isLoading = false,
    this.favoriteProducts = const [],
    this.favoriteProductIds = const {},
    this.error,
  });

  FavoriteState copyWith({
    bool? isLoading,
    List<ProductModel>? favoriteProducts,
    Set<int>? favoriteProductIds,
    String? error,
  }) =>
      FavoriteState(
        isLoading: isLoading ?? this.isLoading,
        favoriteProducts: favoriteProducts ?? this.favoriteProducts,
        favoriteProductIds: favoriteProductIds ?? this.favoriteProductIds,
        error: error ?? this.error,
      );

  @override
  List<Object?> get props =>
      [isLoading, favoriteProducts, favoriteProductIds, error];
}
