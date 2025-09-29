import 'package:ecommerce_app/features/order/data/model/order_model.dart';
import 'package:flutter/material.dart';

class OrderSuccessPage extends StatefulWidget {
  const OrderSuccessPage({
    super.key,
    required this.order,
    required this.paymentMethod,
  });

  final OrderModel order;
  final String paymentMethod;

  @override
  State<OrderSuccessPage> createState() => _OrderSuccessPageState();
}

class _OrderSuccessPageState extends State<OrderSuccessPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )} đ';
  }

  String _getPaymentMethodText() {
    switch (widget.paymentMethod) {
      case 'cod':
        return 'Thanh toán khi nhận hàng (COD)';
      case 'bank_transfer':
        return 'Chuyển khoản ngân hàng';
      default:
        return widget.paymentMethod;
    }
  }

  String _getPaymentStatusText() {
    if (widget.order.paymentStatus == 'paid') {
      return 'Đã thanh toán';
    } else if (widget.paymentMethod == 'cod') {
      return 'Thanh toán khi nhận hàng';
    } else {
      return 'Chờ thanh toán';
    }
  }

  Color _getPaymentStatusColor() {
    if (widget.order.paymentStatus == 'paid') {
      return Colors.green;
    } else if (widget.paymentMethod == 'cod') {
      return Colors.blue;
    } else {
      return Colors.orange;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16), // Giảm padding
                child: Column(
                  children: [
                    const SizedBox(height: 16), // Giảm khoảng cách

                    // Success Icon với Animation
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: 100, // Giảm kích thước
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Colors.green.shade400,
                              Colors.green.shade600,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 50, // Giảm kích thước icon
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Title
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          const Text(
                            'Đặt hàng thành công!',
                            style: TextStyle(
                              fontSize: 24, // Giảm font size
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Cảm ơn bạn đã tin tưởng và đặt hàng',
                            style: TextStyle(
                              fontSize: 14, // Giảm font size
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Thông tin đơn hàng
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        width: double.infinity, // Đảm bảo chiều rộng tối đa
                        padding: const EdgeInsets.all(16), // Giảm padding
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.shade50,
                              Colors.blue.shade100.withOpacity(0.3),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.blue.shade200,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding:
                                      const EdgeInsets.all(6), // Giảm padding
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.receipt_long,
                                    color: Colors.blue.shade700,
                                    size: 20, // Giảm kích thước icon
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  // Thêm Flexible để tránh overflow
                                  child: Text(
                                    'Thông tin đơn hàng',
                                    style: TextStyle(
                                      fontSize: 16, // Giảm font size
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade900,
                                    ),
                                    maxLines: 2, // Giới hạn số dòng
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow(
                              'Mã đơn hàng',
                              widget.order.orderNumber,
                              isBold: true,
                            ),
                            const Divider(height: 16),
                            _buildInfoRow(
                              'Thời gian đặt',
                              _formatDate(widget.order.createdAt),
                            ),
                            const Divider(height: 16),
                            _buildInfoRow(
                              'Phương thức thanh toán',
                              _getPaymentMethodText(),
                            ),
                            const Divider(height: 16),
                            _buildPaymentStatusRow(),
                            const Divider(height: 16),
                            _buildInfoRow(
                              'Tổng tiền',
                              _formatCurrency(widget.order.total),
                              isBold: true,
                              valueColor: Colors.red.shade600,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Thông tin giao hàng (nếu có)
                    if (widget.paymentMethod == 'cod') _buildShippingInfo(),

                    if (widget.paymentMethod == 'bank_transfer' &&
                        widget.order.paymentStatus == 'paid')
                      _buildPaymentSuccessInfo(),

                    const SizedBox(height: 16),

                    // Điểm thưởng (nếu có)
                    if (widget.order.pointsEarned > 0) _buildPointsEarnedInfo(),

                    const SizedBox(height: 16), // Thêm khoảng cách cuối cùng
                  ],
                ),
              ),
            ),

            // Bottom buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    offset: const Offset(0, -2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            vertical: 14), // Giảm padding
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Xem đơn hàng của tôi',
                        style: TextStyle(
                          fontSize: 15, // Giảm font size
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.primary,
                        padding: const EdgeInsets.symmetric(
                            vertical: 14), // Giảm padding
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      child: const Text(
                        'Tiếp tục mua sắm',
                        style: TextStyle(
                          fontSize: 15, // Giảm font size
                          fontWeight: FontWeight.bold,
                        ),
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

  Widget _buildPaymentStatusRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            'Trạng thái thanh toán',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: _getPaymentStatusColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getPaymentStatusColor(),
              width: 1,
            ),
          ),
          child: Text(
            _getPaymentStatusText(),
            style: TextStyle(
              fontSize: 12, // Giảm font size
              fontWeight: FontWeight.bold,
              color: _getPaymentStatusColor(),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildShippingInfo() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12), // Giảm padding
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.orange.shade200,
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.local_shipping_outlined,
              color: Colors.orange.shade700,
              size: 20, // Giảm kích thước icon
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Đơn hàng đang được xử lý',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade900,
                      fontSize: 13, // Giảm font size
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Chúng tôi sẽ liên hệ với bạn sớm nhất để xác nhận đơn hàng.',
                    style: TextStyle(
                      fontSize: 12, // Giảm font size
                      color: Colors.grey[700],
                      height: 1.4,
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

  Widget _buildPaymentSuccessInfo() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12), // Giảm padding
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.green.shade200,
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Colors.green.shade700,
              size: 20, // Giảm kích thước icon
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thanh toán thành công',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade900,
                      fontSize: 13, // Giảm font size
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Đơn hàng của bạn đang được chuẩn bị và sẽ được giao sớm nhất.',
                    style: TextStyle(
                      fontSize: 12, // Giảm font size
                      color: Colors.grey[700],
                      height: 1.4,
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

  Widget _buildPointsEarnedInfo() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12), // Giảm padding
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.purple.shade50,
              Colors.purple.shade100.withOpacity(0.3),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.purple.shade200,
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6), // Giảm padding
              decoration: BoxDecoration(
                color: Colors.purple.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.stars_rounded,
                color: Colors.purple.shade700,
                size: 20, // Giảm kích thước icon
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bạn nhận được ${widget.order.pointsEarned} điểm thưởng',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade900,
                      fontSize: 13, // Giảm font size
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Điểm thưởng có thể sử dụng cho đơn hàng tiếp theo',
                    style: TextStyle(
                      fontSize: 12, // Giảm font size
                      color: Colors.grey[700],
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

  Widget _buildInfoRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 15 : 14, // Giảm font size
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: valueColor ?? Colors.black87,
            ),
            textAlign: TextAlign.right,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
