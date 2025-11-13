// File: lib/features/voucher/presentation/voucher_detail_page.dart
import 'package:ecommerce_app/features/voucher/bloc/voucher_bloc.dart';
import 'package:ecommerce_app/features/voucher/bloc/voucher_event.dart';
import 'package:ecommerce_app/features/voucher/data/model/voucher_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class VoucherDetailPage extends StatelessWidget {
  final VoucherModel voucher;
  final String userId;
  final bool isUserVoucher;

  const VoucherDetailPage({
    super.key,
    required this.voucher,
    required this.userId,
    this.isUserVoucher = false,
  });

  @override
  Widget build(BuildContext context) {
    final isExpired = voucher.validTo.isBefore(DateTime.now());
    final isUsageLimitReached =
        voucher.usageLimit != null && voucher.usedCount >= voucher.usageLimit!;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: const Color(0xFF182145),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _getGradientColors(voucher.type),
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 60),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon container với border
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.5),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            _getVoucherIcon(voucher.type),
                            size: 45,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 14),
                        // Giá trị giảm giá
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _getDiscountText(voucher),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _getVoucherTypeName(voucher.type),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // Tên và mã voucher
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        voucher.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF182145),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Mã voucher có thể copy
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFeb7816).withOpacity(0.1),
                              const Color(0xFFeb7816).withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFeb7816).withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  FontAwesomeIcons.ticketSimple,
                                  size: 18,
                                  color: Color(0xFFeb7816),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  voucher.code,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFeb7816),
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                            InkWell(
                              onTap: () {
                                Clipboard.setData(
                                    ClipboardData(text: voucher.code));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        const Text('Đã sao chép mã voucher'),
                                    backgroundColor: const Color(0xFF182145),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFFeb7816).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.copy,
                                  size: 18,
                                  color: Color(0xFFeb7816),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Trạng thái voucher
                if (isExpired || isUsageLimitReached)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline,
                            color: Colors.red.shade700, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            isExpired
                                ? 'Voucher đã hết hạn sử dụng'
                                : 'Voucher đã hết lượt sử dụng',
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 8),

                // Mô tả
                if (voucher.description != null &&
                    voucher.description!.isNotEmpty)
                  _buildSection(
                    context,
                    'Mô tả chi tiết',
                    FontAwesomeIcons.circleInfo,
                    child: Text(
                      voucher.description!,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ),

                // Điều kiện sử dụng
                _buildSection(
                  context,
                  'Điều kiện áp dụng',
                  FontAwesomeIcons.clipboardCheck,
                  child: Column(
                    children: [
                      _buildInfoRow(
                        icon: FontAwesomeIcons.cartShopping,
                        label: 'Giá trị đơn hàng tối thiểu',
                        value: voucher.minOrderValue > 0
                            ? _formatCurrency(voucher.minOrderValue)
                            : 'Không yêu cầu',
                        valueColor: voucher.minOrderValue > 0
                            ? const Color(0xFFeb7816)
                            : Colors.green.shade600,
                      ),
                      if (voucher.maxDiscountAmount != null &&
                          voucher.type == 'percentage')
                        _buildInfoRow(
                          icon: FontAwesomeIcons.coins,
                          label: 'Giảm giá tối đa',
                          value: _formatCurrency(voucher.maxDiscountAmount!),
                          valueColor: Colors.green.shade600,
                        ),
                    ],
                  ),
                ),

                // Giới hạn sử dụng
                _buildSection(
                  context,
                  'Giới hạn sử dụng',
                  FontAwesomeIcons.userGroup,
                  child: Column(
                    children: [
                      if (voucher.usageLimit != null)
                        _buildInfoRow(
                          icon: FontAwesomeIcons.users,
                          label: 'Tổng lượt sử dụng',
                          value:
                              '${voucher.usedCount}/${voucher.usageLimit} lượt',
                          valueColor: const Color(0xFF182145),
                        ),
                      _buildInfoRow(
                        icon: FontAwesomeIcons.user,
                        label: 'Giới hạn mỗi người',
                        value: '${voucher.usageLimitPerUser} lần',
                        valueColor: const Color(0xFF182145),
                      ),
                    ],
                  ),
                ),

                // Thời gian hiệu lực
                _buildSection(
                  context,
                  'Thời gian hiệu lực',
                  FontAwesomeIcons.clock,
                  child: Column(
                    children: [
                      if (voucher.validFrom != null)
                        _buildInfoRow(
                          icon: FontAwesomeIcons.calendarDay,
                          label: 'Bắt đầu',
                          value: _formatDateTime(voucher.validFrom!),
                        ),
                      _buildInfoRow(
                        icon: FontAwesomeIcons.calendarXmark,
                        label: 'Kết thúc',
                        value: _formatDateTime(voucher.validTo),
                        valueColor: isExpired
                            ? Colors.red.shade600
                            : Colors.green.shade600,
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _getRemainingTimeColor(voucher.validTo)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _getRemainingTimeColor(voucher.validTo)
                                .withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              FontAwesomeIcons.hourglassHalf,
                              size: 16,
                              color: _getRemainingTimeColor(voucher.validTo),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Còn lại: ${_getRemainingTime(voucher.validTo)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      _getRemainingTimeColor(voucher.validTo),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
      // Nút hành động
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: isUserVoucher
              ? ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF182145),
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Đóng',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                )
              : ElevatedButton(
                  onPressed: voucher.isSaved
                      ? null
                      : () {
                          context.read<VoucherBloc>().add(
                                SaveVoucherEvent(userId, voucher.id),
                              );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Đã lưu voucher thành công'),
                              backgroundColor: const Color(0xFF182145),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                          Navigator.pop(context);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: voucher.isSaved
                        ? Colors.grey.shade400
                        : const Color(0xFFeb7816),
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: voucher.isSaved ? 0 : 2,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        voucher.isSaved
                            ? FontAwesomeIcons.circleCheck
                            : FontAwesomeIcons.download,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        voucher.isSaved ? 'Đã lưu voucher' : 'Lưu voucher',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon, {
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF182145).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: const Color(0xFF182145),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF182145),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: valueColor ?? const Color(0xFF182145),
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getGradientColors(String type) {
    switch (type) {
      case 'free_shipping':
        return [
          const Color(0xFF182145),
          const Color(0xFF2a3f7a),
        ];
      case 'percentage':
        return [
          const Color(0xFFeb7816),
          const Color(0xFFff9944),
        ];
      case 'fixed_amount':
        return [
          const Color(0xFF182145),
          const Color(0xFFeb7816),
        ];
      default:
        return [
          const Color(0xFF182145),
          const Color(0xFF2a3f7a),
        ];
    }
  }

  IconData _getVoucherIcon(String type) {
    switch (type) {
      case 'free_shipping':
        return FontAwesomeIcons.truck;
      case 'percentage':
        return FontAwesomeIcons.percent;
      case 'fixed_amount':
        return FontAwesomeIcons.moneyBill;
      default:
        return FontAwesomeIcons.gift;
    }
  }

  String _getVoucherTypeName(String type) {
    switch (type) {
      case 'free_shipping':
        return 'Miễn phí vận chuyển';
      case 'percentage':
        return 'Giảm theo phần trăm';
      case 'fixed_amount':
        return 'Giảm giá cố định';
      default:
        return 'Voucher khuyến mãi';
    }
  }

  String _getDiscountText(VoucherModel voucher) {
    if (voucher.type == 'percentage') {
      return '-${voucher.value}%';
    } else if (voucher.type == 'fixed_amount') {
      return '-${_formatCurrency(voucher.value.toDouble())}';
    } else if (voucher.type == 'free_shipping') {
      return 'FREE SHIP';
    }
    return 'GIẢM GIÁ';
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      symbol: '₫',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  String _formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  String _getRemainingTime(DateTime validTo) {
    final now = DateTime.now();
    final difference = validTo.difference(now);

    if (difference.isNegative) {
      return 'Đã hết hạn';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ngày';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút';
    } else {
      return 'Sắp hết hạn';
    }
  }

  Color _getRemainingTimeColor(DateTime validTo) {
    final now = DateTime.now();
    final difference = validTo.difference(now);

    if (difference.isNegative) {
      return Colors.red.shade600;
    } else if (difference.inDays < 3) {
      return const Color(0xFFeb7816);
    } else {
      return Colors.green.shade600;
    }
  }
}
