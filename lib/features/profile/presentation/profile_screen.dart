import 'package:ecommerce_app/core/data/datasources/supabase_client.dart';
import 'package:ecommerce_app/features/address/presentation/address_screen.dart';
import 'package:ecommerce_app/features/address/presentation/address_user_screen.dart';
import 'package:ecommerce_app/features/auth/presentation/login_page.dart';
import 'package:ecommerce_app/features/order/presentation/order_page.dart';
import 'package:ecommerce_app/features/profile/bloc/profile_bloc.dart';
import 'package:ecommerce_app/features/profile/bloc/profile_event.dart';
import 'package:ecommerce_app/features/profile/bloc/profile_state.dart';
import 'package:ecommerce_app/features/profile/presentation/user_info_form_screen.dart';
import 'package:ecommerce_app/features/voucher/presentation/user_voucher_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  void _loadUserProfile() {
    final user = SupabaseConfig.client.auth.currentUser;
    if (user != null) {
      context.read<ProfileBloc>().add(LoadProfile(userId: user.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildProfileHeader(context, state),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        ProfileCard(
                          color: Colors.blue,
                          icon: Icons.person,
                          title: "Thông tin người dùng",
                          onTap: () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) =>
                                    const UserInfoFormScreen(),
                              ),
                            ).then((_) {
                              // Refresh profile sau khi quay về từ form
                              _loadUserProfile();
                            });
                          },
                        ),
                        ProfileCard(
                          color: Colors.green,
                          icon: Icons.shopping_bag,
                          title: "Đơn hàng của tôi",
                          onTap: () {
                            final userId =
                                SupabaseConfig.client.auth.currentUser!.id;
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => OrderPage(
                                  userId: userId,
                                ),
                              ),
                            );
                          },
                        ),
                        ProfileCard(
                          color: Colors.orange,
                          icon: Icons.location_city_rounded,
                          title: "Địa chỉ",
                          onTap: () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => AddressUserScreen(),
                              ),
                            );
                          },
                        ),
                        ProfileCard(
                          color: Colors.redAccent,
                          icon: Icons.local_activity,
                          title: "Voucher",
                          onTap: () => Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => UserVoucherPage(),
                            ),
                          ),
                        ),
                        ProfileCard(
                          color: Colors.deepPurpleAccent,
                          icon: Icons.info,
                          title: "Chính sách người dùng",
                          onTap: () => print("Đi tới chính sách người dùng"),
                        ),
                        ProfileCard(
                          color: Colors.red,
                          icon: Icons.logout,
                          title: "Đăng xuất",
                          onTap: () => _showLogoutDialog(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, ProfileState state) {
    String displayName = 'Người dùng';
    String? avatarUrl;

    if (state is ProfileLoaded) {
      displayName = state.userProfile.fullName ?? 'Người dùng';
      avatarUrl = state.userProfile.avatarUrl;
    } else if (state is ProfileLoading) {
      return _buildLoadingHeader(context);
    } else {
      // Fallback to user metadata nếu chưa load profile
      final client = SupabaseConfig.client;
      final user = client.auth.currentUser;
      if (user != null) {
        displayName = user.userMetadata?['full_name'] ??
            user.userMetadata?['name'] ??
            'Người dùng';
      }
    }

    return TweenAnimationBuilder<Offset>(
      tween: Tween<Offset>(
        begin: const Offset(0, -1),
        end: Offset.zero,
      ),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      builder: (context, offset, child) {
        return Transform.translate(
          offset: Offset(0, offset.dy * 100),
          child: child,
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(32),
            bottomRight: Radius.circular(32),
          ),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: Colors.white,
              backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                  ? NetworkImage(avatarUrl)
                  : const AssetImage("assets/images/white_background.png")
                      as ImageProvider,
              onBackgroundImageError: avatarUrl != null ? (_, __) {} : null,
              child: avatarUrl == null || avatarUrl.isEmpty
                  ? const Icon(Icons.person, size: 48, color: Colors.grey)
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              displayName,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 48,
            backgroundColor: Colors.white24,
            child: CircularProgressIndicator(color: Colors.white),
          ),
          const SizedBox(height: 16),
          Container(
            height: 24,
            width: 150,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Đăng xuất'),
          content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                await SupabaseConfig.client.auth.signOut();
                Navigator.of(context).pop();
                // Navigate to login screen
                Navigator.pushReplacement(context,
                    CupertinoPageRoute(builder: (context) => LoginPage()));
              },
              child: const Text('Đăng xuất'),
            ),
          ],
        );
      },
    );
  }
}

class ProfileCard extends StatelessWidget {
  const ProfileCard({
    super.key,
    required this.color,
    required this.icon,
    required this.title,
    this.onTap,
  });

  final Color color;
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Row(
            children: [
              const SizedBox(width: 16),
              CircleAvatar(
                radius: 18,
                backgroundColor: color,
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: Colors.grey,
              ),
              const SizedBox(width: 12),
            ],
          ),
        ),
      ),
    );
  }
}
