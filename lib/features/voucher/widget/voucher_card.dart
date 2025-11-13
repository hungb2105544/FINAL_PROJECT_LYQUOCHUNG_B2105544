import 'package:ecommerce_app/features/voucher/bloc/voucher_bloc.dart';
import 'package:ecommerce_app/features/voucher/bloc/voucher_event.dart';
import 'package:ecommerce_app/features/voucher/data/model/voucher_model.dart';
import 'package:ecommerce_app/features/voucher/presentation/voucher_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VoucherCard extends StatelessWidget {
  const VoucherCard({
    super.key,
    required this.voucher,
    required this.userId,
    required this.isUserVoucher,
  });

  final VoucherModel voucher;
  final String userId;
  final bool isUserVoucher;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VoucherDetailPage(
              voucher: voucher,
              userId: userId,
              isUserVoucher: isUserVoucher,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 130,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
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
                  isUserVoucher
                      ? Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey.shade600,
                        )
                      : ConstrainedBox(
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
