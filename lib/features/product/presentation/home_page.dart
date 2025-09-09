import 'package:carousel_slider/carousel_slider.dart';
import 'package:ecommerce_app/common_widgets/caterogy_cart.dart';
import 'package:ecommerce_app/common_widgets/product_card.dart';
import 'package:ecommerce_app/features/product/bloc/poduct_bloc.dart';
import 'package:ecommerce_app/features/product/bloc/product_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final List<String> adImages = [
      "assets/images/Ad1.png",
      "assets/images/Ad2.png",
      "assets/images/Ad3.png",
    ];
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/splash_logo.png',
          height: 46,
        ),
        actions: [
          IconButton(
            icon: const Icon(FontAwesomeIcons.magnifyingGlass, size: 25),
            onPressed: () => print("Click Search"),
          ),
          const SizedBox(width: 12),
        ],
        leading: IconButton(
          icon: const Icon(Icons.menu, size: 28),
          onPressed: () => print("Click Menu"),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Quảng cáo
                Container(
                    child: CarouselSlider(
                  options: CarouselOptions(
                    height: screenHeight * 0.25,
                    autoPlay: true,
                    enlargeCenterPage: true,
                    viewportFraction: 0.9,
                    aspectRatio: 16 / 9,
                    initialPage: 0,
                  ),
                  items: adImages.map((imagePath) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        imagePath,
                        width: screenWidth * 0.9,
                        fit: BoxFit.cover,
                      ),
                    );
                  }).toList(),
                )),
                const SizedBox(height: 20),

                // Tiêu đề Danh mục
                _buildSectionTitle(context, "Danh mục sản phẩm"),

                // Danh mục sản phẩm
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    itemCount: 6,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => print("Click Category $index"),
                        child: CategoryCard(
                          categoryName: "Quần short",
                          imagePath: index.isEven
                              ? "assets/images/category_image.png"
                              : "assets/images/category_image2.png",
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // Tiêu đề Sản phẩm
                _buildSectionTitle(context, "Danh sách sản phẩm"),

                const SizedBox(height: 12),

                // Grid sản phẩm
                BlocBuilder<ProductBloc, ProductState>(
                  builder: (context, state) {
                    if (state.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state.errorMessage != null) {
                      return Center(child: Text(state.errorMessage!));
                    }

                    if (state.products.isEmpty) {
                      return const Center(child: Text("Không có sản phẩm nào"));
                    }

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.products.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 20,
                        childAspectRatio: 0.55,
                      ),
                      itemBuilder: (context, index) {
                        final product = state.products[index];
                        return GestureDetector(
                          onTap: () => print("Click Product ${product.name}"),
                          child: ProductCard(
                              product: product), // truyền dữ liệu thật
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Tiêu đề section tái sử dụng
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
        child: Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
