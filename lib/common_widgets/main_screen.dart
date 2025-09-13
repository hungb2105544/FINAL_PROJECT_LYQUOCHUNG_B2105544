import 'package:ecommerce_app/favorite_sceen.dart';
import 'package:ecommerce_app/features/product/presentation/home_page.dart';
import 'package:ecommerce_app/features/profile/presentation/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:water_drop_nav_bar/water_drop_nav_bar.dart';
import 'package:badges/badges.dart' as badges;

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

/*
Xử lí lấy về thông giỏ hàng của người dùng ở đây
   + Số lượng sản phẩm 
   + Sản phẩm gì
   + Ấn vào Icon giỏ hàng => Chuyển đến trang giỏ hàng 
 */

/*
Xử lí chức năng tìm kiếm sản phẩm
  + Search -> trả về trang tìm kiếm sản phẩm 
  + Phải có lọc theo Thương hiệu, giá
 */

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;
  final pageController = PageController();
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/splash_logo.png',
          height: 46,
        ),
        actions: [
          badges.Badge(
            // style của badge
            badgeStyle: const badges.BadgeStyle(
              badgeColor: Colors.red,
              padding: EdgeInsets.all(6),
            ),
            // vị trí badge
            position: badges.BadgePosition.topEnd(top: -2, end: -4),
            // nội dung hiển thị trong badge
            badgeContent: const Text(
              '1',
              style: TextStyle(color: Colors.white, fontSize: 8),
            ),
            child: IconButton(
              icon: Icon(
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
          icon: const Icon(FontAwesomeIcons.magnifyingGlass, size: 25),
          onPressed: () => print("Click Search"),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: WaterDropNavBar(
        bottomPadding: 15,
        iconSize: 25,
        waterDropColor: const Color(0xFFeb7816),
        backgroundColor: const Color(0xFF182145),
        onItemSelected: (int index) {
          setState(() {
            currentIndex = index;
          });
          pageController.animateToPage(currentIndex,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutQuad);
        },
        selectedIndex: currentIndex,
        barItems: <BarItem>[
          BarItem(
            filledIcon: Icons.home_rounded,
            outlinedIcon: Icons.home_outlined,
          ),
          BarItem(
              filledIcon: Icons.favorite, outlinedIcon: Icons.favorite_border),
          BarItem(
              filledIcon: Icons.local_activity,
              outlinedIcon: Icons.local_activity_outlined),
          BarItem(
            filledIcon: Icons.person,
            outlinedIcon: Icons.person_outline,
          ),
        ],
      ),
      body: PageView(
        controller: pageController,
        physics: NeverScrollableScrollPhysics(),
        children: [
          HomePage(),
          FavoriteSceen(),
          FavoriteSceen(),
          ProfileScreen()
        ],
      ),
    );
  }
}
