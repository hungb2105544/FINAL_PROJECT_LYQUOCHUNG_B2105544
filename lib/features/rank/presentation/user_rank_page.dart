// import 'package:ecommerce_app/core/data/datasources/supabase_client.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:lottie/lottie.dart';
// import 'package:step_progress_indicator/step_progress_indicator.dart';
// import 'package:ecommerce_app/features/rank/bloc/rank_bloc.dart';
// import 'package:ecommerce_app/features/rank/bloc/rank_event.dart';
// import 'package:ecommerce_app/features/rank/bloc/rank_state.dart';

// class UserRankPage extends StatefulWidget {
//   const UserRankPage({
//     Key? key,
//   }) : super(key: key);

//   @override
//   State<UserRankPage> createState() => _UserRankPageState();
// }

// class _UserRankPageState extends State<UserRankPage> {
//   @override
//   void initState() {
//     super.initState();
//     final userId = SupabaseConfig.client.auth.currentUser!.id;
//     context.read<UserRankBloc>().add(LoadUserRankWithProgression(userId));
//   }

//   @override
//   Widget build(BuildContext context) {
//     final userId = SupabaseConfig.client.auth.currentUser!.id;
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Thứ Hạng Của Tôi'),
//         centerTitle: true,
//         elevation: 0,
//       ),
//       body: BlocBuilder<UserRankBloc, UserRankState>(
//         builder: (context, state) {
//           if (state is UserRankLoading) {
//             return Center(
//                 child: Lottie.asset(
//               "assets/lottie/loading_viemode.json",
//               height: 100,
//               width: 100,
//               fit: BoxFit.cover,
//             ));
//           }

//           if (state is UserRankError) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.error_outline,
//                     size: 64,
//                     color: Colors.red[300],
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     'Có lỗi xảy ra',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.grey[800],
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     state.message,
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey[600],
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 24),
//                   ElevatedButton.icon(
//                     onPressed: () {
//                       context.read<UserRankBloc>().add(
//                             LoadUserRankWithProgression(userId),
//                           );
//                     },
//                     icon: const Icon(Icons.refresh),
//                     label: const Text('Thử lại'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.deepPurple,
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 24,
//                         vertical: 12,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }

//           if (state is UserRankWithProgressionLoaded) {
//             final progression = state.userRankProgression;
//             final userRank = progression.userRank;
//             final currentRank = progression.currentRank;
//             final nextRank = progression.nextRank;

//             final progress = nextRank != null
//                 ? ((userRank.currentPoints - currentRank.minPoints) /
//                         (nextRank.minPoints - currentRank.minPoints) *
//                         100)
//                     .clamp(0, 100)
//                     .toInt()
//                 : 100;

//             final pointsToNext = nextRank != null
//                 ? nextRank.minPoints - userRank.currentPoints
//                 : 0;

//             final rankColor = _parseColor(currentRank.colorCode);
//             final discount = _getDiscount(currentRank);
//             final freeShippingThreshold =
//                 _getFreeShippingThreshold(currentRank);

//             return RefreshIndicator(
//               onRefresh: () async {
//                 context.read<UserRankBloc>().add(
//                       LoadUserRankWithProgression(userId),
//                     );
//               },
//               color: Colors.deepPurple,
//               child: SingleChildScrollView(
//                 physics: const AlwaysScrollableScrollPhysics(),
//                 child: Column(
//                   children: [
//                     // Header Card với Rank Badge
//                     Container(
//                       width: double.infinity,
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                           colors: [
//                             rankColor,
//                             rankColor.withOpacity(0.7),
//                           ],
//                         ),
//                       ),
//                       child: Column(
//                         children: [
//                           const SizedBox(height: 24),
//                           // Rank Badge
//                           Container(
//                             width: 120,
//                             height: 120,
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               color: Colors.white,
//                               border: Border.all(
//                                 color: rankColor,
//                                 width: 4,
//                               ),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: rankColor.withOpacity(0.4),
//                                   blurRadius: 20,
//                                   offset: const Offset(0, 10),
//                                 ),
//                               ],
//                             ),
//                             child: Center(
//                               child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Text(
//                                     _getRankIcon(currentRank.name),
//                                     style: const TextStyle(fontSize: 48),
//                                   ),
//                                   const SizedBox(height: 4),
//                                   Text(
//                                     currentRank.name,
//                                     style: TextStyle(
//                                       fontSize: 14,
//                                       fontWeight: FontWeight.bold,
//                                       color: rankColor,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 16),
//                           Text(
//                             userRank.currentPoints.toString(),
//                             style: const TextStyle(
//                               fontSize: 42,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white,
//                               shadows: [
//                                 Shadow(
//                                   color: Colors.black26,
//                                   offset: Offset(0, 2),
//                                   blurRadius: 4,
//                                 ),
//                               ],
//                             ),
//                           ),
//                           const Text(
//                             'Điểm tích lũy',
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: Colors.white,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                           const SizedBox(height: 32),
//                         ],
//                       ),
//                     ),

//                     // Content Section
//                     Padding(
//                       padding: const EdgeInsets.all(16),
//                       child: Column(
//                         children: [
//                           // Progress Card
//                           Container(
//                             width: double.infinity,
//                             padding: const EdgeInsets.all(20),
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(16),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.black.withOpacity(0.08),
//                                   blurRadius: 15,
//                                   offset: const Offset(0, 5),
//                                 ),
//                               ],
//                             ),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           'Hạng hiện tại',
//                                           style: TextStyle(
//                                             fontSize: 12,
//                                             color: Colors.grey[600],
//                                             fontWeight: FontWeight.w500,
//                                           ),
//                                         ),
//                                         const SizedBox(height: 4),
//                                         Row(
//                                           children: [
//                                             Text(
//                                               _getRankIcon(currentRank.name),
//                                               style:
//                                                   const TextStyle(fontSize: 20),
//                                             ),
//                                             const SizedBox(width: 6),
//                                             Text(
//                                               currentRank.name,
//                                               style: TextStyle(
//                                                 fontSize: 18,
//                                                 fontWeight: FontWeight.bold,
//                                                 color: rankColor,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ],
//                                     ),
//                                     if (nextRank != null)
//                                       Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.end,
//                                         children: [
//                                           Text(
//                                             'Hạng tiếp theo',
//                                             style: TextStyle(
//                                               fontSize: 12,
//                                               color: Colors.grey[600],
//                                               fontWeight: FontWeight.w500,
//                                             ),
//                                           ),
//                                           const SizedBox(height: 4),
//                                           Row(
//                                             children: [
//                                               Text(
//                                                 nextRank.name,
//                                                 style: TextStyle(
//                                                   fontSize: 18,
//                                                   fontWeight: FontWeight.bold,
//                                                   color: _parseColor(
//                                                       nextRank.colorCode),
//                                                 ),
//                                               ),
//                                               const SizedBox(width: 6),
//                                               Text(
//                                                 _getRankIcon(nextRank.name),
//                                                 style: const TextStyle(
//                                                     fontSize: 20),
//                                               ),
//                                             ],
//                                           ),
//                                         ],
//                                       ),
//                                   ],
//                                 ),
//                                 if (nextRank != null) ...[
//                                   const SizedBox(height: 24),
//                                   // Step Progress Indicator
//                                   StepProgressIndicator(
//                                     totalSteps: 100,
//                                     currentStep: progress,
//                                     size: 14,
//                                     padding: 0,
//                                     selectedGradientColor: LinearGradient(
//                                       begin: Alignment.centerLeft,
//                                       end: Alignment.centerRight,
//                                       colors: [
//                                         rankColor,
//                                         _parseColor(nextRank.colorCode),
//                                       ],
//                                     ),
//                                     unselectedColor: Colors.grey[200]!,
//                                     roundedEdges: const Radius.circular(10),
//                                   ),
//                                   const SizedBox(height: 12),
//                                   Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Text(
//                                         '$progress% hoàn thành',
//                                         style: TextStyle(
//                                           fontSize: 13,
//                                           fontWeight: FontWeight.bold,
//                                           color: rankColor,
//                                         ),
//                                       ),
//                                       Container(
//                                         padding: const EdgeInsets.symmetric(
//                                           horizontal: 10,
//                                           vertical: 4,
//                                         ),
//                                         decoration: BoxDecoration(
//                                           color: rankColor.withOpacity(0.1),
//                                           borderRadius:
//                                               BorderRadius.circular(12),
//                                         ),
//                                         child: Text(
//                                           'Còn ${_formatNumber(pointsToNext)} điểm',
//                                           style: TextStyle(
//                                             fontSize: 12,
//                                             fontWeight: FontWeight.bold,
//                                             color: rankColor,
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ] else ...[
//                                   const SizedBox(height: 16),
//                                   Container(
//                                     padding: const EdgeInsets.all(12),
//                                     decoration: BoxDecoration(
//                                       color: rankColor.withOpacity(0.1),
//                                       borderRadius: BorderRadius.circular(12),
//                                     ),
//                                     child: Row(
//                                       children: [
//                                         Icon(
//                                           Icons.workspace_premium_rounded,
//                                           color: rankColor,
//                                           size: 24,
//                                         ),
//                                         const SizedBox(width: 12),
//                                         Expanded(
//                                           child: Text(
//                                             'Chúc mừng! Bạn đã đạt hạng cao nhất',
//                                             style: TextStyle(
//                                               fontSize: 13,
//                                               fontWeight: FontWeight.w600,
//                                               color: rankColor,
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ],
//                             ),
//                           ),
//                           const SizedBox(height: 16),

//                           // Stats Cards
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: _buildStatCard(
//                                   icon: Icons.military_tech_rounded,
//                                   title: 'Tổng điểm',
//                                   value: _formatNumber(userRank.lifetimePoints),
//                                   color: Colors.amber[700]!,
//                                 ),
//                               ),
//                               const SizedBox(width: 12),
//                               Expanded(
//                                 child: _buildStatCard(
//                                   icon: Icons.trending_up_rounded,
//                                   title: 'Hạng ${currentRank.sortOrder}/5',
//                                   value: currentRank.name,
//                                   color: rankColor,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 16),

//                           // Benefits Section
//                           Container(
//                             width: double.infinity,
//                             padding: const EdgeInsets.all(20),
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(16),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.black.withOpacity(0.08),
//                                   blurRadius: 15,
//                                   offset: const Offset(0, 5),
//                                 ),
//                               ],
//                             ),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Row(
//                                   children: [
//                                     Icon(
//                                       Icons.card_giftcard_rounded,
//                                       color: rankColor,
//                                       size: 24,
//                                     ),
//                                     const SizedBox(width: 8),
//                                     Text(
//                                       'Quyền lợi của bạn',
//                                       style: TextStyle(
//                                         fontSize: 18,
//                                         fontWeight: FontWeight.bold,
//                                         color: Colors.grey[800],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(height: 16),
//                                 if (discount > 0)
//                                   _buildBenefitItem(
//                                     icon: Icons.discount_rounded,
//                                     title: 'Giảm giá',
//                                     value: '$discount% mọi đơn hàng',
//                                     color: Colors.orange,
//                                   ),
//                                 if (freeShippingThreshold > 0)
//                                   _buildBenefitItem(
//                                     icon: Icons.local_shipping_rounded,
//                                     title: 'Miễn phí vận chuyển',
//                                     value:
//                                         'Đơn từ ${_formatCurrency(freeShippingThreshold)}',
//                                     color: Colors.blue,
//                                   )
//                                 else if (freeShippingThreshold == 0)
//                                   _buildBenefitItem(
//                                     icon: Icons.local_shipping_rounded,
//                                     title: 'Miễn phí vận chuyển',
//                                     value: 'Mọi đơn hàng',
//                                     color: Colors.blue,
//                                   ),
//                                 if (_hasBenefit(currentRank, 'special_offers'))
//                                   _buildBenefitItem(
//                                     icon: Icons.stars_rounded,
//                                     title: 'Ưu đãi đặc biệt',
//                                     value: 'Truy cập sớm các chương trình',
//                                     color: Colors.purple,
//                                   ),
//                                 if (_hasBenefit(currentRank, 'birthday_gift'))
//                                   _buildBenefitItem(
//                                     icon: Icons.cake_rounded,
//                                     title: 'Quà sinh nhật',
//                                     value: 'Nhận quà đặc biệt',
//                                     color: Colors.pink,
//                                   ),
//                                 if (_hasBenefit(
//                                     currentRank, 'priority_support'))
//                                   _buildBenefitItem(
//                                     icon: Icons.support_agent_rounded,
//                                     title: 'Hỗ trợ ưu tiên',
//                                     value: 'CSKH 24/7 ưu tiên',
//                                     color: Colors.teal,
//                                   ),
//                                 if (_hasBenefit(
//                                     currentRank, 'exclusive_products'))
//                                   _buildBenefitItem(
//                                     icon: Icons.diamond_rounded,
//                                     title: 'Sản phẩm độc quyền',
//                                     value: 'Truy cập sản phẩm VIP',
//                                     color: Colors.cyan,
//                                   ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           }

//           return const Center(
//             child: Text('Không có dữ liệu'),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildStatCard({
//     required IconData icon,
//     required String title,
//     required String value,
//     required Color color,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.08),
//             blurRadius: 15,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.1),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               icon,
//               size: 28,
//               color: color,
//             ),
//           ),
//           const SizedBox(height: 12),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.grey[800],
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 4),
//           Text(
//             title,
//             style: TextStyle(
//               fontSize: 12,
//               color: Colors.grey[600],
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBenefitItem({
//     required IconData icon,
//     required String title,
//     required String value,
//     required Color color,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Icon(
//               icon,
//               color: color,
//               size: 20,
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: TextStyle(
//                     fontSize: 13,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.grey[800],
//                   ),
//                 ),
//                 Text(
//                   value,
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   String _getRankIcon(String rankName) {
//     switch (rankName) {
//       case 'Kim cương':
//         return '💎';
//       case 'Bạch kim':
//         return '⭐';
//       case 'Vàng':
//         return '🥇';
//       case 'Bạc':
//         return '🥈';
//       case 'Đồng':
//         return '🥉';
//       default:
//         return '🏅';
//     }
//   }

//   Color _parseColor(String? colorCode) {
//     if (colorCode == null) return Colors.grey;
//     try {
//       return Color(int.parse(colorCode.replaceFirst('#', '0xFF')));
//     } catch (e) {
//       return Colors.grey;
//     }
//   }

//   int _getDiscount(dynamic currentRank) {
//     try {
//       final benefits = currentRank.benefits;
//       if (benefits is Map) {
//         return benefits['discount'] ?? 0;
//       }
//       return 0;
//     } catch (e) {
//       return 0;
//     }
//   }

//   int _getFreeShippingThreshold(dynamic currentRank) {
//     try {
//       final benefits = currentRank.benefits;
//       if (benefits is Map) {
//         return benefits['free_shipping_threshold'] ?? 0;
//       }
//       return 0;
//     } catch (e) {
//       return 0;
//     }
//   }

//   bool _hasBenefit(dynamic currentRank, String benefitKey) {
//     try {
//       final benefits = currentRank.benefits;
//       if (benefits is Map) {
//         return benefits[benefitKey] == true;
//       }
//       return false;
//     } catch (e) {
//       return false;
//     }
//   }

//   String _formatNumber(int number) {
//     if (number >= 1000000) {
//       return '${(number / 1000000).toStringAsFixed(1)}M';
//     } else if (number >= 1000) {
//       return '${(number / 1000).toStringAsFixed(1)}K';
//     }
//     return number.toString();
//   }

//   String _formatCurrency(int amount) {
//     return '${amount.toString().replaceAllMapped(
//           RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
//           (Match m) => '${m[1]}.',
//         )}đ';
//   }
// }
import 'package:ecommerce_app/core/data/datasources/supabase_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:ecommerce_app/features/rank/bloc/rank_bloc.dart';
import 'package:ecommerce_app/features/rank/bloc/rank_event.dart';
import 'package:ecommerce_app/features/rank/bloc/rank_state.dart';

class UserRankPage extends StatefulWidget {
  const UserRankPage({
    Key? key,
  }) : super(key: key);

  @override
  State<UserRankPage> createState() => _UserRankPageState();
}

class _UserRankPageState extends State<UserRankPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    final userId = SupabaseConfig.client.auth.currentUser!.id;
    context.read<UserRankBloc>().add(LoadUserRankWithProgression(userId));

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = SupabaseConfig.client.auth.currentUser!.id;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Thứ Hạng Của Tôi',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: BlocBuilder<UserRankBloc, UserRankState>(
        builder: (context, state) {
          if (state is UserRankLoading) {
            return Center(
              child: Lottie.asset(
                "assets/lottie/loading_viemode.json",
                height: 120,
                width: 120,
                fit: BoxFit.cover,
              ),
            );
          }

          if (state is UserRankError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.error_outline_rounded,
                      size: 64,
                      color: Colors.red[400],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Có lỗi xảy ra',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      state.message,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<UserRankBloc>().add(
                            LoadUserRankWithProgression(userId),
                          );
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Thử lại'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is UserRankWithProgressionLoaded) {
            final progression = state.userRankProgression;
            final userRank = progression.userRank;
            final currentRank = progression.currentRank;
            final nextRank = progression.nextRank;

            final progress = nextRank != null
                ? ((userRank.currentPoints - currentRank.minPoints) /
                        (nextRank.minPoints - currentRank.minPoints) *
                        100)
                    .clamp(0, 100)
                    .toInt()
                : 100;

            final pointsToNext = nextRank != null
                ? nextRank.minPoints - userRank.currentPoints
                : 0;

            final rankColor = _parseColor(currentRank.colorCode);
            final isDiamond = currentRank.name == 'Kim cương';
            final discount = _getDiscount(currentRank);
            final freeShippingThreshold =
                _getFreeShippingThreshold(currentRank);

            return RefreshIndicator(
              onRefresh: () async {
                context.read<UserRankBloc>().add(
                      LoadUserRankWithProgression(userId),
                    );
              },
              color: Colors.deepPurple,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // Premium Header with Gradient
                    Container(
                      alignment: Alignment.center,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: isDiamond
                            ? LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  const Color(0xFF00D4FF),
                                  const Color(0xFF7B2FF7),
                                  const Color(0xFFB9F2FF),
                                ],
                                stops: const [0.0, 0.5, 1.0],
                              )
                            : LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  rankColor,
                                  rankColor.withOpacity(0.7),
                                ],
                              ),
                        boxShadow: [
                          BoxShadow(
                            color: rankColor.withOpacity(0.3),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Background Pattern
                          if (isDiamond)
                            Positioned.fill(
                              child: Opacity(
                                opacity: 0.1,
                                child: CustomPaint(
                                  painter: DiamondPatternPainter(),
                                ),
                              ),
                            ),
                          Column(
                            children: [
                              const SizedBox(height: 32),
                              // Rank Badge with Animation
                              ScaleTransition(
                                scale: _scaleAnimation,
                                child: Container(
                                  width: 140,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 6,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 30,
                                        offset: const Offset(0, 15),
                                      ),
                                      if (isDiamond)
                                        BoxShadow(
                                          color: const Color(0xFF00D4FF)
                                              .withOpacity(0.5),
                                          blurRadius: 40,
                                          spreadRadius: 5,
                                        ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          _getRankIcon(currentRank.name),
                                          style: TextStyle(
                                            fontSize: isDiamond ? 56 : 52,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          currentRank.name,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w900,
                                            color: rankColor,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Points Display
                              Text(
                                _formatNumber(userRank.currentPoints),
                                style: const TextStyle(
                                  fontSize: 52,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -1,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black38,
                                      offset: Offset(0, 3),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'ĐIỂM TÍCH LŨY',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Content Section with Modern Cards
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Progress Card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'HẠNG HIỆN TẠI',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey[500],
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 1.2,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Text(
                                                _getRankIcon(currentRank.name),
                                                style: const TextStyle(
                                                    fontSize: 24),
                                              ),
                                              const SizedBox(width: 8),
                                              Flexible(
                                                child: Text(
                                                  currentRank.name,
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w900,
                                                    color: rankColor,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (nextRank != null)
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              'HẠNG TIẾP THEO',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey[500],
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 1.2,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    nextRank.name,
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      color: _parseColor(
                                                          nextRank.colorCode),
                                                    ),
                                                    textAlign: TextAlign.right,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  _getRankIcon(nextRank.name),
                                                  style: const TextStyle(
                                                      fontSize: 24),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                                if (nextRank != null) ...[
                                  const SizedBox(height: 28),
                                  // Enhanced Progress Bar
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: rankColor.withOpacity(0.2),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: StepProgressIndicator(
                                      totalSteps: 100,
                                      currentStep: progress,
                                      size: 16,
                                      padding: 0,
                                      selectedGradientColor: LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: [
                                          rankColor,
                                          _parseColor(nextRank.colorCode),
                                        ],
                                      ),
                                      unselectedColor: Colors.grey[200]!,
                                      roundedEdges: const Radius.circular(12),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '$progress% HOÀN THÀNH',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: rankColor,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              rankColor.withOpacity(0.15),
                                              rankColor.withOpacity(0.05),
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        child: Text(
                                          'Còn ${_formatNumber(pointsToNext)} điểm',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: rankColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ] else ...[
                                  const SizedBox(height: 20),
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: isDiamond
                                            ? [
                                                const Color(0xFF00D4FF)
                                                    .withOpacity(0.2),
                                                const Color(0xFF7B2FF7)
                                                    .withOpacity(0.2),
                                              ]
                                            : [
                                                rankColor.withOpacity(0.15),
                                                rankColor.withOpacity(0.05),
                                              ],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: rankColor.withOpacity(0.3),
                                        width: 2,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: rankColor.withOpacity(0.2),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.workspace_premium_rounded,
                                            color: rankColor,
                                            size: 28,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'CHÚC MỪNG!',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w900,
                                                  color: Colors.black,
                                                  letterSpacing: 1.5,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Bạn đã đạt hạng cao nhất',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Enhanced Stats Cards
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  icon: Icons.military_tech_rounded,
                                  title: 'Tổng điểm',
                                  value: _formatNumber(userRank.lifetimePoints),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.amber[600]!,
                                      Colors.orange[400]!,
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildStatCard(
                                  icon: Icons.trending_up_rounded,
                                  title: 'Hạng ${currentRank.sortOrder}/5',
                                  value: currentRank.name,
                                  gradient: isDiamond
                                      ? const LinearGradient(
                                          colors: [
                                            Color(0xFF00D4FF),
                                            Color(0xFF7B2FF7),
                                          ],
                                        )
                                      : LinearGradient(
                                          colors: [
                                            rankColor,
                                            rankColor.withOpacity(0.7),
                                          ],
                                        ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Premium Benefits Section
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: isDiamond
                                              ? [
                                                  const Color(0xFF00D4FF)
                                                      .withOpacity(0.2),
                                                  const Color(0xFF7B2FF7)
                                                      .withOpacity(0.2),
                                                ]
                                              : [
                                                  rankColor.withOpacity(0.2),
                                                  rankColor.withOpacity(0.1),
                                                ],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.card_giftcard_rounded,
                                        color: rankColor,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Quyền lợi của bạn',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                if (discount > 0)
                                  _buildBenefitItem(
                                    icon: Icons.discount_rounded,
                                    title: 'Giảm giá',
                                    value: '$discount% mọi đơn hàng',
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFFF6B6B),
                                        Color(0xFFFF8E53)
                                      ],
                                    ),
                                  ),
                                if (freeShippingThreshold > 0)
                                  _buildBenefitItem(
                                    icon: Icons.local_shipping_rounded,
                                    title: 'Miễn phí vận chuyển',
                                    value:
                                        'Đơn từ ${_formatCurrency(freeShippingThreshold)}',
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF4E54C8),
                                        Color(0xFF8F94FB)
                                      ],
                                    ),
                                  )
                                else if (freeShippingThreshold == 0)
                                  _buildBenefitItem(
                                    icon: Icons.local_shipping_rounded,
                                    title: 'Miễn phí vận chuyển',
                                    value: 'Mọi đơn hàng',
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF4E54C8),
                                        Color(0xFF8F94FB)
                                      ],
                                    ),
                                  ),
                                if (_hasBenefit(currentRank, 'special_offers'))
                                  _buildBenefitItem(
                                    icon: Icons.stars_rounded,
                                    title: 'Ưu đãi đặc biệt',
                                    value: 'Truy cập sớm các chương trình',
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF9D50BB),
                                        Color(0xFF6E48AA)
                                      ],
                                    ),
                                  ),
                                if (_hasBenefit(currentRank, 'birthday_gift'))
                                  _buildBenefitItem(
                                    icon: Icons.cake_rounded,
                                    title: 'Quà sinh nhật',
                                    value: 'Nhận quà đặc biệt',
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFFF6FB5),
                                        Color(0xFFFF8DC7)
                                      ],
                                    ),
                                  ),
                                if (_hasBenefit(
                                    currentRank, 'priority_support'))
                                  _buildBenefitItem(
                                    icon: Icons.support_agent_rounded,
                                    title: 'Hỗ trợ ưu tiên',
                                    value: 'CSKH 24/7 ưu tiên',
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF11998E),
                                        Color(0xFF38EF7D)
                                      ],
                                    ),
                                  ),
                                if (_hasBenefit(
                                    currentRank, 'exclusive_products'))
                                  _buildBenefitItem(
                                    icon: Icons.diamond_rounded,
                                    title: 'Sản phẩm độc quyền',
                                    value: 'Truy cập sản phẩm VIP',
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF00D4FF),
                                        Color(0xFF7B2FF7)
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return const Center(
            child: Text('Không có dữ liệu'),
          );
        },
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Gradient gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.grey[800],
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem({
    required IconData icon,
    required String title,
    required String value,
    required Gradient gradient,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
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

  String _getRankIcon(String rankName) {
    switch (rankName) {
      case 'Kim cương':
        return '💎';
      case 'Bạch kim':
        return '⭐';
      case 'Vàng':
        return '🥇';
      case 'Bạc':
        return '🥈';
      case 'Đồng':
        return '🥉';
      default:
        return '🏅';
    }
  }

  Color _parseColor(String? colorCode) {
    if (colorCode == null) return Colors.grey;
    try {
      return Color(int.parse(colorCode.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.grey;
    }
  }

  int _getDiscount(dynamic currentRank) {
    try {
      final benefits = currentRank.benefits;
      if (benefits is Map) {
        return benefits['discount'] ?? 0;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  int _getFreeShippingThreshold(dynamic currentRank) {
    try {
      final benefits = currentRank.benefits;
      if (benefits is Map) {
        return benefits['free_shipping_threshold'] ?? 0;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  bool _hasBenefit(dynamic currentRank, String benefitKey) {
    try {
      final benefits = currentRank.benefits;
      if (benefits is Map) {
        return benefits[benefitKey] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  String _formatCurrency(int amount) {
    return '${amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}đ';
  }
}

// Custom Painter for Diamond Pattern Background
class DiamondPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    const spacing = 40.0;
    const diamondSize = 20.0;

    for (double y = -diamondSize; y < size.height + diamondSize; y += spacing) {
      for (double x = -diamondSize;
          x < size.width + diamondSize;
          x += spacing) {
        final path = Path()
          ..moveTo(x, y - diamondSize / 2)
          ..lineTo(x + diamondSize / 2, y)
          ..lineTo(x, y + diamondSize / 2)
          ..lineTo(x - diamondSize / 2, y)
          ..close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
