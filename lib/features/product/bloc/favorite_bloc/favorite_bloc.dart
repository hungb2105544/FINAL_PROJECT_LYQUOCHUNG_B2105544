import 'package:ecommerce_app/features/product/bloc/favorite_bloc/favorite_event.dart';
import 'package:ecommerce_app/features/product/bloc/favorite_bloc/favorite_state.dart';
import 'package:ecommerce_app/features/product/domain/repositories/favorite_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FavoriteBloc extends Bloc<FavoriteEvent, FavoriteState> {
  final FavoriteRepository _favoriteRepository;

  FavoriteBloc(this._favoriteRepository) : super(const FavoriteState()) {
    on<LoadFavorites>(_onLoadFavorites);
    on<ToggleFavorite>(_onToggleFavorite);
  }

  Future<void> _onLoadFavorites(
    LoadFavorites event,
    Emitter<FavoriteState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final products = await _favoriteRepository.getFavoriteProducts();
      final ids = await _favoriteRepository.getFavoriteProductIds();
      emit(state.copyWith(
        isLoading: false,
        favoriteProducts: products,
        favoriteProductIds: ids,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onToggleFavorite(
    ToggleFavorite event,
    Emitter<FavoriteState> emit,
  ) async {
    final isCurrentlyFavorite =
        state.favoriteProductIds.contains(event.productId);
    final Set<int> newIds = Set.from(state.favoriteProductIds);

    if (isCurrentlyFavorite) {
      newIds.remove(event.productId);
    } else {
      newIds.add(event.productId);
    }

    // Cập nhật UI ngay lập tức để có trải nghiệm tốt hơn
    emit(state.copyWith(favoriteProductIds: newIds));

    try {
      if (isCurrentlyFavorite) {
        await _favoriteRepository.removeFavorite(event.productId);
      } else {
        await _favoriteRepository.addFavorite(event.productId);
      }
      // Tải lại danh sách sản phẩm yêu thích đầy đủ sau khi thao tác thành công
      add(LoadFavorites());
    } catch (e) {
      // Nếu lỗi, quay lại trạng thái cũ
      emit(state.copyWith(
          favoriteProductIds: state.favoriteProductIds, error: e.toString()));
    }
  }
}
