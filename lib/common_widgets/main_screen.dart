// import 'package:ecommerce_app/favorite_sceen.dart';
// import 'package:ecommerce_app/features/product/presentation/home_page.dart';
// import 'package:ecommerce_app/features/profile/presentation/profile_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:water_drop_nav_bar/water_drop_nav_bar.dart';
// import 'package:badges/badges.dart' as badges;

// class MainScreen extends StatefulWidget {
//   const MainScreen({super.key});

//   @override
//   State<MainScreen> createState() => _MainScreenState();
// }

// /*
// Xử lí lấy về thông giỏ hàng của người dùng ở đây
//    + Số lượng sản phẩm
//    + Sản phẩm gì
//    + Ấn vào Icon giỏ hàng => Chuyển đến trang giỏ hàng
//  */

// /*
// Xử lí chức năng tìm kiếm sản phẩm
//   + Search -> trả về trang tìm kiếm sản phẩm
//   + Phải có lọc theo Thương hiệu, giá
//  */

// class _MainScreenState extends State<MainScreen> {
//   int currentIndex = 0;
//   final pageController = PageController();
//   @override
//   void initState() {
//     super.initState();
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Image.asset(
//           'assets/images/splash_logo.png',
//           height: 46,
//         ),
//         actions: [
//           badges.Badge(
//             // style của badge
//             badgeStyle: const badges.BadgeStyle(
//               badgeColor: Colors.red,
//               padding: EdgeInsets.all(6),
//             ),
//             // vị trí badge
//             position: badges.BadgePosition.topEnd(top: -2, end: -4),
//             // nội dung hiển thị trong badge
//             badgeContent: const Text(
//               '1',
//               style: TextStyle(color: Colors.white, fontSize: 8),
//             ),
//             child: IconButton(
//               icon: Icon(
//                 FontAwesomeIcons.cartShopping,
//                 size: 18,
//               ),
//               onPressed: () {
//                 print("Đi tới giỏ hàng");
//               },
//             ),
//           ),
//           const SizedBox(width: 16),
//         ],
//         leading: IconButton(
//           icon: const Icon(FontAwesomeIcons.magnifyingGlass, size: 25),
//           onPressed: () => print("Click Search"),
//         ),
//         centerTitle: true,
//       ),
//       bottomNavigationBar: WaterDropNavBar(
//         bottomPadding: 15,
//         iconSize: 25,
//         waterDropColor: const Color(0xFFeb7816),
//         backgroundColor: const Color(0xFF182145),
//         onItemSelected: (int index) {
//           setState(() {
//             currentIndex = index;
//           });
//           pageController.animateToPage(currentIndex,
//               duration: const Duration(milliseconds: 400),
//               curve: Curves.easeOutQuad);
//         },
//         selectedIndex: currentIndex,
//         barItems: <BarItem>[
//           BarItem(
//             filledIcon: Icons.home_rounded,
//             outlinedIcon: Icons.home_outlined,
//           ),
//           BarItem(
//               filledIcon: Icons.favorite, outlinedIcon: Icons.favorite_border),
//           BarItem(
//               filledIcon: Icons.local_activity,
//               outlinedIcon: Icons.local_activity_outlined),
//           BarItem(
//             filledIcon: Icons.person,
//             outlinedIcon: Icons.person_outline,
//           ),
//         ],
//       ),
//       body: PageView(
//         controller: pageController,
//         physics: NeverScrollableScrollPhysics(),
//         children: [
//           HomePage(),
//           FavoriteSceen(),
//           FavoriteSceen(),
//           ProfileScreen()
//         ],
//       ),
//     );
//   }
// }
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:ecommerce_app/favorite_sceen.dart';
import 'package:ecommerce_app/features/product/presentation/home_page.dart';
import 'package:ecommerce_app/features/profile/presentation/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  // Danh sách các icon cho bottom navigation
  final List<IconData> _navIcons = [
    Icons.home_outlined,
    Icons.favorite_border,
    Icons.local_activity_outlined,
    Icons.person_outline,
  ];

  // Danh sách các icon khi được chọn
  final List<IconData> _navIconsSelected = [
    Icons.home_rounded,
    Icons.favorite,
    Icons.local_activity,
    Icons.person,
  ];

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    // Đảm bảo SystemChrome được thiết lập đúng cách
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
    // Hiển thị màn hình trắng đơn giản trong khi khởi tạo
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
          badges.Badge(
            badgeStyle: const badges.BadgeStyle(
              badgeColor: Colors.red,
              padding: EdgeInsets.all(6),
            ),
            position: badges.BadgePosition.topEnd(top: -2, end: -4),
            badgeContent: const Text(
              '1',
              style: TextStyle(color: Colors.white, fontSize: 8),
            ),
            child: IconButton(
              icon: const Icon(
                FontAwesomeIcons.cartShopping,
                size: 18,
              ),
              onPressed: () {
                print("Đi tới giỏ hàng");
              },
            ),
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
          FavoriteSceen(),
          FavoriteSceen(),
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
