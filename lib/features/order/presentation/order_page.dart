import 'package:ecommerce_app/features/order/bloc/order_bloc.dart';
import 'package:ecommerce_app/features/order/bloc/order_event.dart';
import 'package:ecommerce_app/features/order/bloc/order_state.dart';
import 'package:ecommerce_app/features/order/data/model/order_model.dart';
import 'package:ecommerce_app/features/order/presentation/order_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';

class OrderPage extends StatefulWidget {
  final String userId;

  const OrderPage({super.key, required this.userId});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() {
    context.read<OrderPaymentBloc>().add(GetOrdersByUserEvent(widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Đơn hàng của tôi'),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: BlocConsumer<OrderPaymentBloc, OrderPaymentState>(
              listener: (context, state) {
                if (state is OrderCancelled) {
                  // Hiển thị thông báo thành công
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã hủy đơn hàng thành công'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 2),
                    ),
                  );
                  // Tự động reload danh sách
                  _loadOrders();
                } else if (state is OrderPaymentError &&
                    state.message.contains('hủy')) {
                  // Chỉ hiển thị error liên quan đến cancel
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 3),
                      action: SnackBarAction(
                        label: 'Đóng',
                        textColor: Colors.white,
                        onPressed: () {},
                      ),
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is OrderPaymentLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is OrderPaymentError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            size: 64, color: Colors.red[300]),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            state.message,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 3,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _loadOrders,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is OrdersLoaded) {
                  final filteredOrders = _filterOrders(state.orders);

                  if (filteredOrders.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _buildEmptyState(),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async => _loadOrders(),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 16),
                      itemCount: filteredOrders.length,
                      itemBuilder: (context, index) {
                        return _buildOrderCard(filteredOrders[index]);
                      },
                    ),
                  );
                }

                // State mặc định hoặc initial state
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('Tất cả', 'all'),
            const SizedBox(width: 8),
            _buildFilterChip('Chờ xác nhận', 'pending'), // pending
            const SizedBox(width: 8),
            _buildFilterChip('Đã xác nhận', 'confirmed'), // confirmed
            const SizedBox(width: 8),
            _buildFilterChip('Đang xử lý', 'processing'),
            const SizedBox(width: 8),
            _buildFilterChip(
                'Đang giao', 'shipping'), // shipping (corrected from shipped)
            const SizedBox(width: 8),
            _buildFilterChip('Hoàn thành', 'delivered'),
            const SizedBox(width: 8),
            _buildFilterChip('Đã hủy', 'cancelled'),
            const SizedBox(width: 8),
            _buildFilterChip('Đã hoàn tiền', 'refunded'), // refunded
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      labelStyle: TextStyle(
        fontSize: 13,
        color:
            isSelected ? Theme.of(context).colorScheme.primary : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: Colors.white,
      selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      checkmarkColor: Theme.of(context).colorScheme.primary,
      shape: StadiumBorder(
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.grey[300]!,
        ),
      ),
      showCheckmark: false,
    );
  }

  List<Widget> _buildEmptyState() {
    return [
      Lottie.asset(
        'assets/lottie/empty_box.json',
        width: 200,
        height: 200,
      ),
      const SizedBox(height: 16),
      Text(
        _getEmptyMessage(),
        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
      ),
      if (_selectedFilter != 'all') ...[
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => setState(() => _selectedFilter = 'all'),
          child: const Text('Xem tất cả đơn hàng'),
        ),
      ],
    ];
  }

  List<OrderModel> _filterOrders(List<OrderModel> orders) {
    if (_selectedFilter == 'all') return orders;
    return orders.where((order) => order.status == _selectedFilter).toList();
  }

  String _getEmptyMessage() {
    switch (_selectedFilter) {
      case 'pending':
        return 'Chưa có đơn hàng chờ xác nhận';
      case 'confirmed':
        return 'Chưa có đơn hàng đã xác nhận';
      case 'processing':
        return 'Chưa có đơn hàng đang xử lý';
      case 'shipping':
        return 'Chưa có đơn hàng đang giao';
      case 'delivered':
        return 'Chưa có đơn hàng hoàn thành';
      case 'cancelled':
        return 'Chưa có đơn hàng đã hủy';
      case 'refunded':
        return 'Chưa có đơn hàng đã hoàn tiền';
      default:
        return 'Chưa có đơn hàng nào';
    }
  }

  Widget _buildOrderCard(OrderModel order) {
    final firstItem =
        order.listOrderItem.isNotEmpty ? order.listOrderItem.first : null;
    final firstImage = firstItem?.product?['image_urls']?.first;

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailPage(order: order),
          ),
        );
        if (result == true) {
          _loadOrders();
        }
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 3,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Order number và status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Đơn hàng #${order.orderNumber}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusChip(order.status),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Ngày đặt: ${_formatDate(order.createdAt)}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              const Divider(height: 24),

              // Body: Product info
              Row(
                children: [
                  if (firstImage != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        firstImage,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported,
                              color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.shopping_bag_outlined,
                          color: Colors.grey),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          firstItem?.product?['name'] ?? 'Sản phẩm',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${order.listOrderItem.length} sản phẩm',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const Divider(height: 24),

              // Footer: Total và button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tổng tiền',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatCurrency(order.total),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderDetailPage(order: order),
                        ),
                      );
                      if (result == true) {
                        _loadOrders();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Xem chi tiết'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;

    switch (status) {
      case 'pending':
        color = Colors.orange;
        label = 'Chờ xác nhận';
        break;
      case 'confirmed':
        color = Colors.lightGreen; // A distinct color for confirmed
        label = 'Đã xác nhận';
        break;
      case 'processing':
        color = Colors.blue;
        label = 'Đang xử lý';
        break;
      case 'shipping': // Corrected from 'shipped'
        color = Colors.purple;
        label = 'Đang giao';
        break;
      case 'delivered':
        color = Colors.green;
        label = 'Hoàn thành';
        break;
      case 'cancelled':
        color = Colors.red;
        label = 'Đã hủy';
        break;
      case 'refunded':
        color = Colors.blueGrey; // Consistent with OrderDetailPage
        label = 'Đã hoàn tiền';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildPaymentStatusChip(String paymentStatus) {
    Color color;
    String label;

    switch (paymentStatus) {
      case 'pending':
        color = Colors.orange;
        label = 'Chờ thanh toán';
        break;
      case 'paid':
        color = Colors.green;
        label = 'Đã thanh toán';
        break;
      case 'failed':
        color = Colors.red;
        label = 'Thanh toán thất bại';
        break;
      case 'refunded':
        color = Colors.blueGrey;
        label = 'Đã hoàn tiền';
        break;
      default:
        color = Colors.grey;
        label = paymentStatus;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.payment, size: 12, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(amount);
  }
}
