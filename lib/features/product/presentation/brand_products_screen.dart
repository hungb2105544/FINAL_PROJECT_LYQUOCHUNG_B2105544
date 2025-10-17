import 'package:ecommerce_app/common_widgets/product_card.dart';
import 'package:ecommerce_app/features/product/bloc/poduct_bloc.dart';
import 'package:ecommerce_app/features/product/bloc/product_event.dart';
import 'package:ecommerce_app/features/product/bloc/product_state.dart';
import 'package:ecommerce_app/features/product/data/models/brand_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BrandProductsScreen extends StatefulWidget {
  final BrandModel brand;

  const BrandProductsScreen({Key? key, required this.brand}) : super(key: key);

  @override
  State<BrandProductsScreen> createState() => _BrandProductsScreenState();
}

class _BrandProductsScreenState extends State<BrandProductsScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    context.read<ProductBloc>().add(
          GetProductsByBrandEvent(brandId: widget.brand.id),
        );
  }

  Future<void> _onRefresh() async {
    _loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.brand.brandName),
        centerTitle: true,
      ),
      body: BlocConsumer<ProductBloc, ProductState>(
        listener: (context, state) {
          if (state.hasError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? "Đã xảy ra lỗi!")),
            );
          }
        },
        builder: (context, state) {
          // Hiển thị chỉ báo làm mới (loading indicator) cho lần tải đầu tiên
          if (state.isLoading && state.products.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // Hiển thị khi không có sản phẩm (có thể xem như trường hợp lỗi hoặc brand chưa có sản phẩm)
          if (state.products.isEmpty &&
              !state.isLoading &&
              !state.isRefreshing) {
            return RefreshIndicator(
              key: _refreshKey,
              onRefresh: _onRefresh,
              child: ListView(
                children: [
                  _BrandHeaderSection(brand: widget.brand),
                  _BrandDescriptionSection(brand: widget.brand),
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(32.0),
                    child: Text(
                        '❌ Hiện tại chưa có sản phẩm nào của ${widget.brand.brandName}'),
                  ),
                ],
              ),
            );
          }

          // Hiển thị giao diện chính
          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: <Widget>[
                // 1. SECTION: LOGO VÀ TÊN BRAND (Không thay đổi khi cuộn)
                SliverToBoxAdapter(
                  child: _BrandHeaderSection(brand: widget.brand),
                ),

                // 2. SECTION: MÔ TẢ BRAND
                SliverToBoxAdapter(
                  child: _BrandDescriptionSection(brand: widget.brand),
                ),

                // 3. SECTION: THÔNG BÁO NGUỒN DỮ LIỆU
                SliverAppBar(
                  automaticallyImplyLeading: false,
                  pinned: true,
                  toolbarHeight: 32, // Tăng nhẹ chiều cao để hiển thị tiêu đề
                  backgroundColor: state.isFromCache
                      ? Colors.orange.shade100
                      : Colors.blue.shade100,
                  title: Text(
                    'Sản phẩm (${state.products.length}) - ${state.dataSourceMessage}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: state.isFromCache
                          ? Colors.deepOrange
                          : Colors.blue.shade900,
                    ),
                  ),
                ),

                // 4. SECTION: LIST DANH SÁCH SẢN PHẨM (Sử dụng ProductCard)
                SliverPadding(
                  padding: const EdgeInsets.all(8.0),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                      childAspectRatio: 0.6,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = state.products[index];
                        return ProductCard(product: product);
                      },
                      childCount: state.products.length,
                    ),
                  ),
                ),

                // 5. LOADING/FOOTER
                SliverToBoxAdapter(
                  child: Visibility(
                    visible: state.isRefreshing && state.products.isNotEmpty,
                    child: const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// =========================================================================
// WIDGET MỚI: SECTION LOGO VÀ TÊN BRAND
// =========================================================================
class _BrandHeaderSection extends StatelessWidget {
  final BrandModel brand;
  const _BrandHeaderSection({required this.brand});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.white,
      child: Row(
        children: [
          // Logo Brand
          ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: brand.imageUrl != null && brand.imageUrl!.isNotEmpty
                ? Image.network(
                    brand.imageUrl!,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 70,
                      height: 70,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.business,
                          size: 40, color: Colors.grey),
                    ),
                  )
                : Container(
                    width: 70,
                    height: 70,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.business,
                        size: 40, color: Colors.grey),
                  ),
          ),
          const SizedBox(width: 16),

          // Tên Brand
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  brand.brandName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Thương hiệu chính hãng',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =========================================================================
// WIDGET MỚI: SECTION MÔ TẢ BRAND
// =========================================================================
class _BrandDescriptionSection extends StatelessWidget {
  final BrandModel brand;
  const _BrandDescriptionSection({required this.brand});

  @override
  Widget build(BuildContext context) {
    if (brand.description == null || brand.description!.isEmpty) {
      return const SizedBox(height: 10); // Không hiển thị nếu không có mô tả
    }

    return Container(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1),
          const SizedBox(height: 10),
          const Text(
            'Mô tả thương hiệu',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            brand.description!,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
            maxLines: 4, // Giới hạn số dòng để tránh quá dài
            overflow: TextOverflow.ellipsis,
          ),

          // Nút xem thêm (tùy chọn, cần implement)
          TextButton(
            onPressed: () {
              // TODO: Implement navigation to a full description page or expansion
              print('View full description of ${brand.brandName}');
            },
            child: const Text(
              'Xem thêm',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
