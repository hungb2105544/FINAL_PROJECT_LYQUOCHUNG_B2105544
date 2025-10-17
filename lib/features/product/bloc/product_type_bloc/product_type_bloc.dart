import 'package:ecommerce_app/features/product/bloc/product_type_bloc/product_type_event.dart';
import 'package:ecommerce_app/features/product/bloc/product_type_bloc/product_type_state.dart';
import 'package:ecommerce_app/features/product/domain/repositories/product_type_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductTypeBloc extends Bloc<ProductTypeEvent, ProductTypeState> {
  final ProductTypeRepository _productTypeRepository;

  ProductTypeBloc({required ProductTypeRepository productTypeRepository})
      : _productTypeRepository = productTypeRepository,
        super(const ProductTypeInitial()) {
    on<FetchProductTypes>(_onFetchProductTypes);
    on<RefreshProductTypes>(_onFetchProductTypes);
  }

  Future<void> _onFetchProductTypes(
    ProductTypeEvent event,
    Emitter<ProductTypeState> emit,
  ) async {
    // Không emit loading nếu đang refresh và đã có data
    final shouldShowLoading =
        event is! RefreshProductTypes || state is! ProductTypeLoaded;

    if (shouldShowLoading) {
      emit(const ProductTypeLoading());
    }

    try {
      final productTypes = await _productTypeRepository.getAllProductType();
      emit(ProductTypeLoaded(productTypes));
    } catch (e) {
      emit(ProductTypeFailure(e.toString()));
    }
  }
}
