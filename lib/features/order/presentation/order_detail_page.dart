import 'package:ecommerce_app/features/order/bloc/order_bloc.dart';
import 'package:ecommerce_app/features/order/bloc/order_event.dart';
import 'package:ecommerce_app/features/order/bloc/order_state.dart';
import 'package:ecommerce_app/features/order/bloc/rating_bloc/rating_bloc.dart';
import 'package:ecommerce_app/features/order/bloc/rating_bloc/rating_event.dart';
import 'package:ecommerce_app/features/order/data/model/order_model.dart';
import 'package:ecommerce_app/features/order/data/model/order_item_model.dart';
import 'package:ecommerce_app/features/order/presentation/submit_rating_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

extension OrderItemDisplay on OrderItemModel {
  String get displayName {
    if (product != null && product!['name'] != null) {
      return product!['name'];
    }
    return 'Sản phẩm #$id';
  }

  String? get displayImage {
    if (product != null && product!['image_urls'] != null) {
      final imgs = product!['image_urls'];
      if (imgs is List && imgs.isNotEmpty) {
        return imgs.first;
      }
    }
    return null;
  }

  String? get displayVariant {
    if (variant != null) {
      if (variant!['sku'] != null) return "SKU: ${variant!['sku']}";
      if (variant!['color'] != null) return "Màu: ${variant!['color']}";
    }
    return null;
  }

  int? get productId {
    if (product != null && product!['id'] != null) {
      return product!['id'] is int
          ? product!['id']
          : int.tryParse(product!['id'].toString());
    }
    return null;
  }
}

class OrderDetailPage extends StatefulWidget {
  final OrderModel? order;
  final String? orderId;

  static const route = "/order-detail";

  const OrderDetailPage({
    super.key,
    this.order,
    this.orderId,
  });

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  OrderModel? _currentOrder;
  bool _isInitialized = false;
  String? _orderId;

  @override
  void initState() {
    super.initState();
    print('📦 [OrderDetailPage] initState');
    print('   order: ${widget.order?.id}');
    print('   orderId: ${widget.orderId}');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      _initializeOrder();
      _isInitialized = true;
    }
  }

  void _initializeOrder() {
    print('🔄 [OrderDetailPage] _initializeOrder');

    if (widget.order != null) {
      setState(() {
        _currentOrder = widget.order;
        _orderId = widget.order!.id.toString();
      });
      return;
    }

    if (widget.orderId != null && widget.orderId!.isNotEmpty) {
      setState(() {
        _orderId = widget.orderId;
      });
      context.read<OrderPaymentBloc>().add(
            GetOrderById(orderId: widget.orderId!),
          );
      return;
    }

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is Map<String, dynamic>) {
      final orderId = args['order_id'];
      if (orderId != null) {
        final orderIdStr = orderId.toString();
        setState(() {
          _orderId = orderIdStr;
        });
        context.read<OrderPaymentBloc>().add(
              GetOrderById(orderId: orderIdStr),
            );
        return;
      }
    } else if (args is String) {
      setState(() {
        _orderId = args;
      });
      context.read<OrderPaymentBloc>().add(
            GetOrderById(orderId: args),
          );
      return;
    } else if (args is OrderModel) {
      setState(() {
        _currentOrder = args;
        _orderId = args.id.toString();
      });
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(_currentOrder != null
            ? 'Đơn hàng #${_currentOrder!.orderNumber}'
            : _orderId != null
                ? 'Đơn hàng #$_orderId'
                : 'Chi tiết đơn hàng'),
        elevation: 0,
      ),
      body: BlocConsumer<OrderPaymentBloc, OrderPaymentState>(
        listener: (context, state) {
          if (state is OrderLoaded) {
            setState(() {
              _currentOrder = state.order;
              _orderId = state.order.id.toString();
            });
          }
        },
        builder: (context, state) {
          if (_currentOrder == null && state is OrderPaymentLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Đang tải thông tin đơn hàng...'),
                ],
              ),
            );
          }

          if (state is OrderPaymentError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(state.message),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (_orderId != null) {
                        context.read<OrderPaymentBloc>().add(
                              GetOrderById(orderId: _orderId!),
                            );
                      }
                    },
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          if (_currentOrder == null) {
            return const Center(
              child: Text('Không tìm thấy thông tin đơn hàng'),
            );
          }

          final order = _currentOrder!;
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusSection(order),
                  const SizedBox(height: 8),
                  _buildProductsSection(order),
                  const SizedBox(height: 8),
                  _buildPriceSection(order),
                  const SizedBox(height: 8),
                  _buildPaymentSection(order),
                  const SizedBox(height: 8),
                  if (order.notes != null) _buildNotesSection(order),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: _currentOrder != null
          ? _buildBottomBar(context, _currentOrder!)
          : null,
    );
  }

  Widget _buildStatusSection(OrderModel order) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(_getStatusIcon(order.status),
              color: _getStatusColor(order.status)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getStatusLabel(order.status),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Cập nhật: ${order.updatedAt}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsSection(OrderModel order) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Sản phẩm đã đặt',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...order.listOrderItem
              .map((item) => _buildProductItem(item, order))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildProductItem(OrderItemModel item, OrderModel order) {
    final canReview = order.status == 'delivered' && (item.canReview ?? false);
    final userId = order.userId;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: item.displayImage != null
                    ? Image.network(
                        item.displayImage!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) => Container(
                            width: 80, height: 80, color: Colors.grey[200]),
                      )
                    : Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[200],
                        child: Icon(Icons.image,
                            color: Colors.grey[400], size: 40),
                      ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.displayName,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w500),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.displayVariant != null)
                      Text(item.displayVariant!,
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 12)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatCurrency(item.unitPrice),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        Text('x${item.quantity}',
                            style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (canReview && item.productId != null && userId != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: OutlinedButton.icon(
                onPressed: () => _navigateToRating(context, item, userId),
                icon: const Icon(Icons.star_outline, size: 18),
                label: const Text('Đánh giá sản phẩm'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orange,
                  side: const BorderSide(color: Colors.orange),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _navigateToRating(
      BuildContext context, OrderItemModel item, String userId) async {
    if (item.productId == null) return;

    context.read<RatingBloc>().add(CheckReviewEligibility(
          userId: userId,
          productId: item.productId!,
          orderItemId: item.id,
        ));

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: context.read<RatingBloc>(),
          child: SubmitRatingPage(
            productId: item.productId!,
            orderItemId: item.id,
            userId: userId,
            productName: item.displayName,
            productImage: item.displayImage,
          ),
        ),
      ),
    );

    if (result == true && mounted && _orderId != null) {
      context.read<OrderPaymentBloc>().add(GetOrderById(orderId: _orderId!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cảm ơn bạn đã đánh giá sản phẩm!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Widget _buildPriceSection(OrderModel order) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildPriceRow('Tạm tính', order.subtotal),
          _buildPriceRow('Giảm giá', -order.discountAmount,
              color: Colors.green),
          _buildPriceRow('Phí vận chuyển', order.shippingFee),
          _buildPriceRow('Thuế', order.taxAmount),
          const Divider(),
          _buildPriceRow('Tổng cộng', order.total, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount,
      {bool isTotal = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: isTotal ? 16 : 14,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        Text(
          _formatCurrency(amount),
          style: TextStyle(
              fontSize: isTotal ? 18 : 15,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: color ?? (isTotal ? Colors.red : Colors.black)),
        ),
      ],
    );
  }

  Widget _buildPaymentSection(OrderModel order) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Thông tin thanh toán',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.payment, 'Phương thức',
              order.paymentMethod ?? 'Chưa cập nhật'),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.verified, 'Trạng thái',
              _getPaymentStatusLabel(order.paymentStatus),
              valueColor: _getPaymentStatusColor(order.paymentStatus)),
        ],
      ),
    );
  }

  Widget _buildNotesSection(OrderModel order) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ghi chú',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(order.notes!, style: TextStyle(color: Colors.grey[700])),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text('$label: $value',
              style: TextStyle(color: valueColor ?? Colors.black)),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5)),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (order.status == 'pending')
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showCancelDialog(context, order),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Colors.red),
                  ),
                  child: const Text('Hủy đơn',
                      style: TextStyle(color: Colors.red)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context, OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận hủy đơn'),
        content: const Text('Bạn có chắc chắn muốn hủy đơn hàng này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Không'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<OrderPaymentBloc>().add(
                    CancelOrderEvent(
                      order: order,
                      userId: order.userId ?? '',
                    ),
                  );
              Navigator.pop(context);
            },
            child: const Text('Hủy đơn', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // ===== Helper methods =====

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.schedule;
      case 'confirmed':
        return Icons.check_circle_outline;
      case 'processing':
        return Icons.inventory_2_outlined;
      case 'shipping':
        return Icons.local_shipping_outlined;
      case 'delivered':
        return Icons.verified;
      case 'cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
      case 'processing':
        return Colors.blue;
      case 'shipping':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Chờ xác nhận';
      case 'confirmed':
        return 'Đã xác nhận';
      case 'processing':
        return 'Đang xử lý';
      case 'shipping':
        return 'Đang giao hàng';
      case 'delivered':
        return 'Đã giao hàng';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return status;
    }
  }

  String _getPaymentStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Chờ thanh toán';
      case 'paid':
        return 'Đã thanh toán';
      case 'failed':
        return 'Thanh toán thất bại';
      case 'refunded':
        return 'Đã hoàn tiền';
      default:
        return 'Không xác định';
    }
  }

  Color _getPaymentStatusColor(String status) {
    switch (status) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
      case 'refunded':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  String _formatCurrency(double? amount) {
    if (amount == null) return '0₫';
    final format = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return format.format(amount);
  }
}
