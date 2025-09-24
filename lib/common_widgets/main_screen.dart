import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:ecommerce_app/core/data/datasources/supabase_client.dart';
import 'package:ecommerce_app/features/cart/bloc/cart_bloc.dart';
import 'package:ecommerce_app/features/cart/bloc/cart_event.dart';
import 'package:ecommerce_app/features/cart/bloc/cart_state.dart';
import 'package:ecommerce_app/features/cart/presentation/cart_page.dart';
import 'package:ecommerce_app/features/product/presentation/home_page.dart';
import 'package:ecommerce_app/features/product/presentation/search_product_page.dart';
import 'package:ecommerce_app/features/profile/presentation/profile_screen.dart';
import 'package:ecommerce_app/features/voucher/presentation/voucher_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:badges/badges.dart' as badges;

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;
  final PageController pageController = PageController();
  bool _isInitialized = false;

  final List<IconData> _navIcons = [
    Icons.home_outlined,
    FontAwesomeIcons.magnifyingGlass,
    Icons.local_activity_outlined,
    Icons.person_outline,
  ];

  final List<IconData> _navIconsSelected = [
    Icons.home_rounded,
    FontAwesomeIcons.magnifyingGlass,
    Icons.local_activity,
    Icons.person,
  ];

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await Future.delayed(const Duration(milliseconds: 50));
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    setState(() {
      _isInitialized = true;
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Container(color: Colors.white);
    }

    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/splash_logo.png',
          height: 46,
        ),
        actions: [
          BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              int itemCount = 0;
              if (state is CartLoaded) {
                itemCount = state.totalItems;
              } else if (state is CartOperationSuccess) {
                final String userId =
                    SupabaseConfig.client.auth.currentUser?.id ?? '';
                if (userId.isNotEmpty) {
                  context.read<CartBloc>().add(GetTotalCartItems(userId));
                }
              }
              return badges.Badge(
                badgeStyle: const badges.BadgeStyle(
                  badgeColor: Colors.red,
                  padding: EdgeInsets.all(6),
                ),
                position: badges.BadgePosition.topEnd(top: -2, end: -4),
                badgeContent: Text(
                  itemCount > 99 ? '99+' : itemCount.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 8),
                ),
                showBadge: itemCount > 0, // Chỉ hiện badge khi có sản phẩm
                child: IconButton(
                  icon: const Icon(
                    FontAwesomeIcons.cartShopping,
                    size: 18,
                  ),
                  onPressed: () {
                    final String userId =
                        SupabaseConfig.client.auth.currentUser?.id ?? '';
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BlocProvider.value(
                          value: context.read<CartBloc>(),
                          child: CartPage(userId: userId),
                        ),
                      ),
                    ).then((_) {
                      // Reload cart data khi quay lại từ CartPage
                      if (userId.isNotEmpty) {
                        context.read<CartBloc>().add(GetTotalCartItems(userId));
                      }
                    });
                  },
                ),
              );
            },
          ),
          const SizedBox(width: 16),
        ],
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.magnifyingGlass, size: 20),
          onPressed: () => print("Click Search"),
        ),
        centerTitle: true,
        elevation: 1,
      ),
      body: PageView(
        controller: pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          HomePage(),
          ProductSearchPage(),
          VoucherPage(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  CurvedNavigationBar _buildBottomNavigationBar() {
    return CurvedNavigationBar(
      index: currentIndex,
      height: 60,
      color: const Color(0xFF182145),
      buttonBackgroundColor: const Color(0xFFeb7816),
      backgroundColor: Colors.transparent,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 300),
      onTap: (index) {
        setState(() {
          currentIndex = index;
        });
        pageController.jumpToPage(index);
      },
      items: List.generate(_navIcons.length, (index) {
        return Icon(
          currentIndex == index ? _navIconsSelected[index] : _navIcons[index],
          size: 24,
          color: Colors.white,
        );
      }),
    );
  }
}
