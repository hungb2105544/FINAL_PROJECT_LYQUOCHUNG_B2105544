// product_state.dart
import 'package:ecommerce_app/features/product/data/models/product_model.dart';
import 'package:equatable/equatable.dart';

enum DataSource {
  none, // No data
  cache, // Data from cache
  server, // Data from server
}

class ProductState extends Equatable {
  final List<ProductModel> products;
  final bool isLoading;
  final bool isRefreshing;
  final bool hasReachedMax;
  final String? errorMessage;
  final DataSource dataSource;
  final DateTime? lastUpdated;
  final int currentPage;

  const ProductState({
    this.products = const [],
    this.isLoading = false,
    this.isRefreshing = false,
    this.hasReachedMax = false,
    this.errorMessage,
    this.dataSource = DataSource.none,
    this.lastUpdated,
    this.currentPage = 1,
  });

  @override
  List<Object?> get props => [
        products,
        isLoading,
        isRefreshing,
        hasReachedMax,
        errorMessage,
        dataSource,
        lastUpdated,
        currentPage,
      ];

  ProductState copyWith({
    List<ProductModel>? products,
    bool? isLoading,
    bool? isRefreshing,
    bool? hasReachedMax,
    String? errorMessage,
    DataSource? dataSource,
    DateTime? lastUpdated,
    int? currentPage,
  }) {
    return ProductState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      errorMessage: errorMessage,
      dataSource: dataSource ?? this.dataSource,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  /// Helper methods for UI
  bool get hasProducts => products.isNotEmpty;
  bool get isEmpty => products.isEmpty && !isLoading;
  bool get isFromCache => dataSource == DataSource.cache;
  bool get isFromServer => dataSource == DataSource.server;
  bool get hasError => errorMessage != null;

  /// Check if data is stale (older than 30 minutes)
  bool get isDataStale {
    if (lastUpdated == null) return true;
    return DateTime.now().difference(lastUpdated!).inMinutes > 30;
  }

  /// Get display message based on data source
  String get dataSourceMessage {
    switch (dataSource) {
      case DataSource.cache:
        return isRefreshing ? "Đang cập nhật dữ liệu mới..." : "Dữ liệu đã lưu";
      case DataSource.server:
        return "Dữ liệu mới nhất";
      case DataSource.none:
        return "Chưa có dữ liệu";
    }
  }
}
