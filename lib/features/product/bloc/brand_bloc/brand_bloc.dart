import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:ecommerce_app/features/product/data/models/brand_model.dart'; // Giả sử BrandModel ở đây
import 'package:ecommerce_app/features/product/domain/repositories/brand_repository.dart'; // BrandRepository
import 'brand_event.dart'; // BrandEvent đã có
import 'brand_state.dart'; // BrandState vừa tạo

class BrandBloc extends Bloc<BrandEvent, BrandState> {
  final BrandRepository brandRepository;

  BrandBloc({required this.brandRepository}) : super(BrandInitial()) {
    on<LoadBrands>(_onLoadBrands);
  }

  Future<void> _onLoadBrands(
    LoadBrands event,
    Emitter<BrandState> emit,
  ) async {
    emit(BrandLoading());
    try {
      final brands = await brandRepository.getAllBrands();
      emit(BrandLoaded(brands: brands));
    } catch (e) {
      emit(BrandError(message: e.toString()));
    }
  }
}
