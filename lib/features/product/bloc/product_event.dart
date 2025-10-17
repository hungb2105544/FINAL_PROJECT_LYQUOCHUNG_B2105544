// product_event.dart
import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Load products directly from server (original behavior)
class GetProductIsActive extends ProductEvent {}

/// Load products from cache only
class LoadProductsFromCache extends ProductEvent {
  final int page;
  final int limit;

  LoadProductsFromCache({
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [page, limit];
}

/// Load products with cache-first strategy (recommended for app startup)
class LoadProductsWithCache extends ProductEvent {
  final int page;
  final int limit;
  final bool showCacheFirst;

  LoadProductsWithCache({
    this.page = 1,
    this.limit = 20,
    this.showCacheFirst = true,
  });

  @override
  List<Object?> get props => [page, limit, showCacheFirst];
}

/// Force refresh from server (pull-to-refresh)
class RefreshProducts extends ProductEvent {
  final int page;
  final int limit;

  RefreshProducts({
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [page, limit];
}

/// Clear products cache
class ClearProductsCache extends ProductEvent {}

/// Load more products (pagination)
class LoadMoreProducts extends ProductEvent {
  final int page;
  final int limit;

  LoadMoreProducts({
    required this.page,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [page, limit];
}

class GetProductsByTypeEvent extends ProductEvent {
  final int typeId;
  GetProductsByTypeEvent({required this.typeId});
}
