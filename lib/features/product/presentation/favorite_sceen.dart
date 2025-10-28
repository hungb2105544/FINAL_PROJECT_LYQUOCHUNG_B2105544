import 'package:ecommerce_app/common_widgets/product_card.dart';
import 'package:ecommerce_app/features/product/bloc/favorite_bloc/favorite_bloc.dart';
import 'package:ecommerce_app/features/product/bloc/favorite_bloc/favorite_event.dart';
import 'package:ecommerce_app/features/product/bloc/favorite_bloc/favorite_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

class FavoriteSceen extends StatefulWidget {
  const FavoriteSceen({super.key});

  @override
  State<FavoriteSceen> createState() => _FavoriteSceenState();
}

class _FavoriteSceenState extends State<FavoriteSceen> {
  @override
  void initState() {
    super.initState();
    // Tải danh sách yêu thích khi màn hình được mở
    context.read<FavoriteBloc>().add(LoadFavorites());
  }

  Future<void> _onRefresh() async {
    context.read<FavoriteBloc>().add(LoadFavorites());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sản phẩm yêu thích'),
      ),
      body: BlocBuilder<FavoriteBloc, FavoriteState>(
        builder: (context, state) {
          if (state.isLoading && state.favoriteProducts.isEmpty) {
            return Center(
              child: Lottie.asset(
                "assets/lottie/loading_viemode.json",
                height: 100,
                width: 100,
              ),
            );
          }

          if (state.error != null && state.favoriteProducts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Lỗi: ${state.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _onRefresh,
                    child: const Text('Thử lại'),
                  )
                ],
              ),
            );
          }

          if (state.favoriteProducts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border,
                      size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có sản phẩm yêu thích nào',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.55,
              ),
              itemCount: state.favoriteProducts.length,
              itemBuilder: (context, index) {
                final product = state.favoriteProducts[index];
                return ProductCard(product: product);
              },
            ),
          );
        },
      ),
    );
  }
}
