import 'package:ecommerce_app/common_widgets/product_card.dart';
import 'package:ecommerce_app/features/product/bloc/poduct_bloc.dart';
import 'package:ecommerce_app/features/product/bloc/product_event.dart';
import 'package:ecommerce_app/features/product/bloc/product_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

class ProductWithTypePage extends StatefulWidget {
  const ProductWithTypePage({super.key, required this.typeId, this.typeName});
  final String typeId;
  final String? typeName;
  @override
  State<ProductWithTypePage> createState() => _ProductWithTypePageState();
}

class _ProductWithTypePageState extends State<ProductWithTypePage> {
  @override
  void initState() {
    super.initState();
    // Gửi event để tải sản phẩm theo loại khi trang được khởi tạo
    final typeId = int.tryParse(widget.typeId);
    if (typeId != null) {
      context.read<ProductBloc>().add(GetProductsByTypeEvent(typeId: typeId));
    }
  }

  Future<void> _handleRefresh() async {
    final typeId = int.tryParse(widget.typeId);
    if (typeId != null) {
      final bloc = context.read<ProductBloc>();
      bloc.add(GetProductsByTypeEvent(typeId: typeId));
      await bloc.stream
          .firstWhere(
            (state) => !state.isLoading,
            orElse: () => bloc.state,
          )
          .timeout(const Duration(seconds: 10), onTimeout: () => bloc.state);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.typeName ?? 'Sản phẩm'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: BlocBuilder<ProductBloc, ProductState>(
          builder: (context, state) {
            // Trạng thái đang tải
            if (state.isLoading && state.products.isEmpty) {
              return Center(
                child: Lottie.asset(
                  "assets/lottie/loading_viemode.json",
                  height: 100,
                  width: 100,
                ),
              );
            }

            // Trạng thái lỗi
            if (state.hasError && state.products.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                    const SizedBox(height: 16),
                    Text(
                      "Không thể tải sản phẩm",
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.errorMessage ?? "Vui lòng thử lại sau",
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _handleRefresh,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Thử lại'),
                    ),
                  ],
                ),
              );
            }

            // Không có sản phẩm
            if (state.products.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inventory_2_outlined,
                        size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      "Chưa có sản phẩm nào",
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }

            // Hiển thị danh sách sản phẩm
            return GridView.builder(
              padding: const EdgeInsets.all(12.0),
              itemCount: state.products.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 20,
                childAspectRatio: 0.55,
              ),
              itemBuilder: (context, index) {
                final product = state.products[index];
                return GestureDetector(
                  onTap: () => print("Click Product ${product.name}"),
                  child: ProductCard(product: product),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
