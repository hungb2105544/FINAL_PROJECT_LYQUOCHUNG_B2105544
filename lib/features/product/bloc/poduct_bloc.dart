import 'package:ecommerce_app/features/product/domain/usecase/get_products_is_active.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce_app/features/product/bloc/product_event.dart';
import 'package:ecommerce_app/features/product/bloc/product_state.dart';
import 'package:ecommerce_app/features/product/data/models/product_model.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProductsIsActive _getProductsIsActiveUseCase;

  ProductBloc({
    required GetProductsIsActive getProductsIsActiveUseCase,
  })  : _getProductsIsActiveUseCase = getProductsIsActiveUseCase,
        super(const ProductState()) {
    on<GetProductIsActive>(_getProducts);
  }

  Future<void> _getProducts(
    GetProductIsActive event,
    Emitter<ProductState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true));

      final response = await _getProductsIsActiveUseCase.call();

      if (response.isNotEmpty) {
        emit(state.copyWith(
            isLoading: false, products: response, errorMessage: null));
      } else {
        emit(state.copyWith(
          isLoading: false,
          products: [],
          errorMessage: "Lỗi khi tải dữ liệu",
        ));
      }
    } catch (error) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      ));
    }
  }
}
