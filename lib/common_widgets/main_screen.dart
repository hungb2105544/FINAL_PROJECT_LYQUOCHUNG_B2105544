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

    // Load cart data ngay khi khởi tạo app
    await _loadInitialCartData();

    setState(() {
      _isInitialized = true;
    });
  }

  Future<void> _loadInitialCartData() async {
    try {
      // Kiểm tra user đã đăng nhập chưa
      final String? userId = SupabaseConfig.client.auth.currentUser?.id;

      if (userId != null && userId.isNotEmpty) {
        // Load total cart items ngay khi mở app
        if (mounted) {
          context.read<CartBloc>().add(GetTotalCartItems(userId));
        }
      } else {
        // Nếu chưa đăng nhập, có thể listen cho auth state changes
        SupabaseConfig.client.auth.onAuthStateChange.listen((data) {
          final user = data.session?.user;
          if (user != null && mounted) {
            context.read<CartBloc>().add(GetTotalCartItems(user.id));
          }
        });
      }
    } catch (e) {
      // Log error nhưng không crash app
      debugPrint('Error loading initial cart data: $e');
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo hoặc loading indicator
              Image.asset(
                'assets/images/splash_logo.png',
                height: 80,
              ),
              const SizedBox(height: 20),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  const Color(0xFFeb7816),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Đang khởi tạo...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        ),
      );
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

              // Xử lý các trạng thái khác nhau của cart
              if (state is CartLoaded) {
                itemCount = state.totalItems;
              } else if (state is CartOperationSuccess) {
                itemCount = state.totalItems ?? 0;
                // Refresh cart data sau khi có thao tác
                final String? userId =
                    SupabaseConfig.client.auth.currentUser?.id;
                if (userId != null && userId.isNotEmpty) {
                  // Delay một chút để tránh việc gọi liên tục
                  Future.delayed(const Duration(milliseconds: 100), () {
                    if (mounted) {
                      context.read<CartBloc>().add(GetTotalCartItems(userId));
                    }
                  });
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
                  onPressed: () => _navigateToCart(),
                ),
              );
            },
          ),
          const SizedBox(width: 16),
        ],
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.magnifyingGlass, size: 20),
          onPressed: () => _navigateToSearch(),
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

  void _navigateToCart() {
    final String? userId = SupabaseConfig.client.auth.currentUser?.id;

    if (userId == null || userId.isEmpty) {
      // Hiển thị dialog yêu cầu đăng nhập
      _showLoginRequiredDialog();
      return;
    }

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
      _refreshCartData();
    });
  }

  void _navigateToSearch() {
    setState(() {
      currentIndex = 1;
    });
    pageController.jumpToPage(1);
  }

  void _refreshCartData() {
    final String? userId = SupabaseConfig.client.auth.currentUser?.id;
    if (userId != null && userId.isNotEmpty && mounted) {
      context.read<CartBloc>().add(GetTotalCartItems(userId));
    }
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.login_rounded,
              color: const Color(0xFFeb7816),
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text('Yêu cầu đăng nhập'),
          ],
        ),
        content: const Text(
          'Bạn cần đăng nhập để xem giỏ hàng. Vui lòng đăng nhập để tiếp tục.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Hủy',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFeb7816),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Đăng nhập'),
          ),
        ],
      ),
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
