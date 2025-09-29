import 'package:ecommerce_app/core/data/datasources/supabase_client.dart';
import 'package:ecommerce_app/features/voucher/bloc/voucher_bloc.dart';
import 'package:ecommerce_app/features/voucher/bloc/voucher_event.dart';
import 'package:ecommerce_app/features/voucher/bloc/voucher_sate.dart';
import 'package:ecommerce_app/features/voucher/data/model/voucher_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';

class VoucherSelectionPage extends StatefulWidget {
  const VoucherSelectionPage({super.key});

  @override
  State<VoucherSelectionPage> createState() => _VoucherSelectionPageState();
}

class _VoucherSelectionPageState extends State<VoucherSelectionPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final client = SupabaseConfig.client;
      final String userId = client.auth.currentUser!.id;
      context.read<VoucherBloc>().add(GetVoucherByUserId(userId));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chọn voucher"),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, null); // Không chọn voucher nào
            },
            child: const Text(
              "Bỏ qua",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<VoucherBloc, VoucherState>(
        builder: (context, state) {
          if (state is VoucherLoading) {
            return Center(
              child: Lottie.asset(
                'assets/lottie/loading_viemode.json',
                width: 100,
                height: 100,
              ),
            );
          } else if (state is VoucherLoaded) {
            if (state.vouchers.isEmpty) {
              return _buildEmptyState();
            }
            return _buildVoucherList(state.vouchers);
          } else if (state is NoVoucherFound) {
            return _buildEmptyState();
          } else if (state is VoucherError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 80,
                    color: Colors.red.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Lỗi: ${state.message}",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.red.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      final client = SupabaseConfig.client;
                      final String userId = client.auth.currentUser!.id;
                      context
                          .read<VoucherBloc>()
                          .add(GetVoucherByUserId(userId));
                    },
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  /// Trạng thái rỗng
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            FontAwesomeIcons.ticketSimple,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Bạn chưa có voucher nào',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy tích lũy điểm để nhận voucher hấp dẫn',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(FontAwesomeIcons.arrowLeft),
            label: const Text('Quay lại'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  /// Danh sách voucher
  Widget _buildVoucherList(List<VoucherModel> vouchers) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: vouchers.length,
      itemBuilder: (context, index) {
        final voucher = vouchers[index];

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.orange.shade50,
                Colors.red.shade50,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.orange.shade200,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.15),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: voucher.isActive
                ? () {
                    Navigator.pop(context, voucher);
                  }
                : null,
            child: Opacity(
              opacity: voucher.isActive ? 1.0 : 0.6,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header với icon voucher và loại
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            FontAwesomeIcons.ticketSimple,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                voucher.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Text(
                                    'Mã: ${voucher.code}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.orange.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Badge giảm giá
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.red, Colors.orange],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _getDiscountText(voucher),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Mô tả voucher
                    if (voucher.description != null &&
                        voucher.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          voucher.description!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                    // Thông tin sử dụng
                    if (voucher.usageLimit != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Icon(
                              FontAwesomeIcons.users,
                              size: 14,
                              color: Colors.purple.shade600,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Còn lại ${voucher.usageLimit! - voucher.usedCount} lượt sử dụng',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.purple.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Giới hạn mỗi user
                    if (voucher.usageLimitPerUser > 1)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Icon(
                              FontAwesomeIcons.user,
                              size: 14,
                              color: Colors.indigo.shade600,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Tối đa ${voucher.usageLimitPerUser} lần/người',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.indigo.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Giới hạn giảm tối đa
                    if (voucher.maxDiscountAmount != null &&
                        voucher.type == 'percentage')
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Icon(
                              FontAwesomeIcons.coins,
                              size: 14,
                              color: Colors.green.shade600,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Giảm tối đa ${_formatCurrency(voucher.maxDiscountAmount!)}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Điều kiện áp dụng
                    Row(
                      children: [
                        Icon(
                          FontAwesomeIcons.circleInfo,
                          size: 14,
                          color: Colors.blue.shade600,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _getConditionText(voucher),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Thời hạn sử dụng
                    Row(
                      children: [
                        Icon(
                          FontAwesomeIcons.clock,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _getExpiryText(voucher),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),
                    const Divider(thickness: 1, height: 1),
                    const SizedBox(height: 10),

                    // Nút chọn voucher
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (!voucher.isActive)
                          Text(
                            "Voucher không khả dụng",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        else ...[
                          Text(
                            "Chọn voucher này",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.orange.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.orange.shade700,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _getVoucherType(VoucherModel voucher) {
    if (voucher.type == 'percentage') {
      return 'Giảm theo phần trăm';
    } else if (voucher.type == 'fixed_amount') {
      return 'Giảm theo số tiền';
    } else if (voucher.type == 'free_shipping') {
      return 'Miễn phí vận chuyển';
    }
    return 'Voucher khuyến mãi';
  }

  String _getDiscountText(VoucherModel voucher) {
    if (voucher.type == 'percentage') {
      return '${voucher.value}%';
    } else if (voucher.type == 'fixed_amount') {
      return '${_formatCurrency(voucher.value.toDouble())}';
    } else if (voucher.type == 'free_shipping') {
      return 'FREE SHIP';
    }
    return 'GIẢM GIÁ';
  }

  String _getConditionText(VoucherModel voucher) {
    if (voucher.minOrderValue > 0) {
      return 'Áp dụng cho đơn hàng từ ${_formatCurrency(voucher.minOrderValue)}';
    }
    return 'Không có điều kiện tối thiểu';
  }

  String _getExpiryText(VoucherModel voucher) {
    final now = DateTime.now();
    final difference = voucher.validTo.difference(now).inDays;

    if (difference > 0) {
      return 'Hết hạn sau $difference ngày';
    } else if (difference == 0) {
      return 'Hết hạn hôm nay';
    } else {
      return 'Đã hết hạn';
    }
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(amount % 1000000 == 0 ? 0 : 1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(amount % 1000 == 0 ? 0 : 1)}K';
    }
    return '${amount.toInt()}đ';
  }
}
