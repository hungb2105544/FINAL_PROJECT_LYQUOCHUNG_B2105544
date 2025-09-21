// import 'package:ecommerce_app/core/data/datasources/supabase_client.dart';
// import 'package:ecommerce_app/features/voucher/bloc/voucher_bloc.dart';
// import 'package:ecommerce_app/features/voucher/bloc/voucher_event.dart';
// import 'package:ecommerce_app/features/voucher/bloc/voucher_sate.dart';
// import 'package:ecommerce_app/features/voucher/data/model/voucher_model.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// class VoucherPage extends StatefulWidget {
//   const VoucherPage({super.key});

//   @override
//   State<VoucherPage> createState() => _VoucherPageState();
// }

// class _VoucherPageState extends State<VoucherPage> {
//   String? userId;

//   @override
//   void initState() {
//     super.initState();
//     _initializeUser();
//   }

//   void _initializeUser() {
//     final currentUser = SupabaseConfig.client.auth.currentUser;
//     if (currentUser != null) {
//       userId = currentUser.id;
//       context.read<VoucherBloc>().add(FetchVouchersEvent(userId!));
//     } else {
//       // Handle unauthenticated user
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Vui lòng đăng nhập để sử dụng tính năng này'),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (userId == null) {
//       return Scaffold(
//         appBar: AppBar(title: const Text("Danh sách Voucher")),
//         body: const Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.login, size: 64, color: Colors.grey),
//               SizedBox(height: 16),
//               Text(
//                 'Vui lòng đăng nhập để xem voucher',
//                 style: TextStyle(fontSize: 16, color: Colors.grey),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(title: const Text("Danh sách Voucher")),
//       body: BlocConsumer<VoucherBloc, VoucherState>(
//         listener: (context, state) {
//           if (state is VoucherError) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text(state.message),
//                 backgroundColor: Colors.red,
//               ),
//             );
//           }
//         },
//         builder: (context, state) {
//           if (state is VoucherLoading) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (state is VoucherLoaded) {
//             final vouchers = state.vouchers;
//             if (vouchers.isEmpty) {
//               return const Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.card_giftcard, size: 64, color: Colors.grey),
//                     SizedBox(height: 16),
//                     Text("Không có voucher nào"),
//                   ],
//                 ),
//               );
//             }
//             return RefreshIndicator(
//               onRefresh: () async {
//                 context.read<VoucherBloc>().add(FetchVouchersEvent(userId!));
//               },
//               child: ListView.separated(
//                 padding: const EdgeInsets.all(16.0),
//                 itemCount: vouchers.length,
//                 separatorBuilder: (_, __) => const SizedBox(height: 16.0),
//                 itemBuilder: (context, index) {
//                   final voucher = vouchers[index];
//                   return VoucherCard(
//                     voucher: voucher,
//                     userId: userId!,
//                   );
//                 },
//               ),
//             );
//           } else if (state is NoVoucherFound) {
//             return const Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.search_off, size: 64, color: Colors.grey),
//                   SizedBox(height: 16),
//                   Text("Không tìm thấy voucher nào"),
//                 ],
//               ),
//             );
//           } else if (state is VoucherError) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.error_outline, size: 64, color: Colors.red),
//                   SizedBox(height: 16),
//                   Text(
//                     "Lỗi: ${state.message}",
//                     textAlign: TextAlign.center,
//                     style: TextStyle(color: Colors.red),
//                   ),
//                   SizedBox(height: 16),
//                   ElevatedButton(
//                     onPressed: () {
//                       context
//                           .read<VoucherBloc>()
//                           .add(FetchVouchersEvent(userId!));
//                     },
//                     child: Text("Thử lại"),
//                   ),
//                 ],
//               ),
//             );
//           }
//           return const Center(child: Text("Không có dữ liệu"));
//         },
//       ),
//     );
//   }
// }

// class VoucherCard extends StatelessWidget {
//   const VoucherCard({super.key, required this.voucher, required this.userId});
//   final VoucherModel voucher;
//   final String userId;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 130,
//       padding: const EdgeInsets.all(8.0),
//       child: Row(
//         children: [
//           Container(
//             width: 100,
//             decoration: BoxDecoration(
//               color: Colors.orange,
//               borderRadius: BorderRadius.circular(8.0),
//             ),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(8.0),
//               child: Image.asset(
//                 voucher.type == 'free_shipping'
//                     ? 'assets/images/freeship.png'
//                     : 'assets/images/discount.png',
//                 fit: BoxFit.cover,
//                 errorBuilder: (context, error, stackTrace) {
//                   return Icon(
//                     _getVoucherIcon(voucher.type),
//                     color: Colors.white,
//                     size: 32,
//                   );
//                 },
//               ),
//             ),
//           ),
//           const SizedBox(width: 12.0),
//           Expanded(
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         voucher.name,
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       const SizedBox(height: 6.0),
//                       Text(
//                         voucher.code,
//                         style: const TextStyle(fontSize: 14),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       const SizedBox(height: 6.0),
//                       Text(
//                         "Valid until: ${_formatDate(voucher.validTo)}",
//                         style: const TextStyle(
//                           fontSize: 12,
//                           color: Colors.grey,
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(width: 8.0),
//                 ConstrainedBox(
//                   constraints: const BoxConstraints(
//                     minWidth: 80,
//                     maxWidth: 100,
//                     minHeight: 36,
//                   ),
//                   child: ElevatedButton(
//                     onPressed: voucher.isSaved
//                         ? null
//                         : () {
//                             context.read<VoucherBloc>().add(
//                                   SaveVoucherEvent(userId, voucher.id),
//                                 );
//                           },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor:
//                           voucher.isSaved ? Colors.grey : Colors.blue,
//                     ),
//                     child: Text(
//                       voucher.isSaved ? "Đã lưu" : "Lưu mã",
//                       style: const TextStyle(fontSize: 13),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Color _getVoucherColor(String type) {
//     switch (type) {
//       case 'free_shipping':
//         return Colors.blue;
//       case 'percentage':
//         return Colors.orange;
//       case 'fixed_amount':
//         return Colors.green;
//       default:
//         return Colors.grey;
//     }
//   }

//   IconData _getVoucherIcon(String type) {
//     switch (type) {
//       case 'free_shipping':
//         return Icons.local_shipping;
//       case 'percentage':
//         return Icons.percent;
//       case 'fixed_amount':
//         return Icons.money;
//       default:
//         return Icons.card_giftcard;
//     }
//   }

//   String _formatVoucherValue(VoucherModel voucher) {
//     switch (voucher.type) {
//       case 'percentage':
//         return 'Giảm ${voucher.value}%';
//       case 'fixed_amount':
//         return 'Giảm ${_formatCurrency(voucher.value)}';
//       case 'free_shipping':
//         return 'Miễn phí vận chuyển';
//       default:
//         return 'Voucher ${voucher.value}';
//     }
//   }

//   String _formatCurrency(int amount) {
//     return '${amount.toString().replaceAllMapped(
//           RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
//           (Match m) => '${m[1]},',
//         )}đ';
//   }

//   String _formatDate(DateTime date) {
//     return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
//   }
// }
import 'package:ecommerce_app/core/data/datasources/supabase_client.dart';
import 'package:ecommerce_app/features/voucher/bloc/voucher_bloc.dart';
import 'package:ecommerce_app/features/voucher/bloc/voucher_event.dart';
import 'package:ecommerce_app/features/voucher/bloc/voucher_sate.dart';
import 'package:ecommerce_app/features/voucher/data/model/voucher_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VoucherPage extends StatefulWidget {
  const VoucherPage({super.key});

  @override
  State<VoucherPage> createState() => _VoucherPageState();
}

class _VoucherPageState extends State<VoucherPage> {
  String? userId;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  void _initializeUser() {
    final currentUser = SupabaseConfig.client.auth.currentUser;
    if (currentUser != null) {
      userId = currentUser.id;
      context.read<VoucherBloc>().add(FetchVouchersEvent(userId!));
    } else {
      // Đảm bảo context đã build xong mới show SnackBar
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng đăng nhập để sử dụng tính năng này'),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Danh sách Voucher")),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.login, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Vui lòng đăng nhập để xem voucher',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Danh sách Voucher")),
      body: BlocConsumer<VoucherBloc, VoucherState>(
        listener: (context, state) {
          if (state is VoucherError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is VoucherLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is VoucherLoaded) {
            final vouchers = state.vouchers;
            if (vouchers.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.card_giftcard, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text("Không có voucher nào"),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<VoucherBloc>().add(FetchVouchersEvent(userId!));
              },
              child: ListView.separated(
                padding: const EdgeInsets.all(16.0),
                itemCount: vouchers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16.0),
                itemBuilder: (context, index) {
                  final voucher = vouchers[index];
                  return VoucherCard(
                    voucher: voucher,
                    userId: userId!,
                  );
                },
              ),
            );
          }
          return const Center(child: Text("Không có dữ liệu"));
        },
      ),
    );
  }
}

class VoucherCard extends StatelessWidget {
  const VoucherCard({super.key, required this.voucher, required this.userId});
  final VoucherModel voucher;
  final String userId;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Container(
            width: 100,
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.asset(
                voucher.type == 'free_shipping'
                    ? 'assets/images/freeship.png'
                    : 'assets/images/discount.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    _getVoucherIcon(voucher.type),
                    color: Colors.white,
                    size: 32,
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        voucher.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6.0),
                      Text(
                        voucher.code,
                        style: const TextStyle(fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6.0),
                      Text(
                        "Valid until: ${_formatDate(voucher.validTo)}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8.0),
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: 80,
                    maxWidth: 100,
                    minHeight: 36,
                  ),
                  child: ElevatedButton(
                    onPressed: voucher.isSaved
                        ? null
                        : () {
                            context.read<VoucherBloc>().add(
                                  SaveVoucherEvent(userId, voucher.id),
                                );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          voucher.isSaved ? Colors.grey : Colors.blue,
                    ),
                    child: Text(
                      voucher.isSaved ? "Đã lưu" : "Lưu mã",
                      style: const TextStyle(fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getVoucherIcon(String type) {
    switch (type) {
      case 'free_shipping':
        return Icons.local_shipping;
      case 'percentage':
        return Icons.percent;
      case 'fixed_amount':
        return Icons.money;
      default:
        return Icons.card_giftcard;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
