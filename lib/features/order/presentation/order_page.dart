// import 'package:ecommerce_app/features/order/bloc/order_bloc.dart';
// import 'package:ecommerce_app/features/order/bloc/order_event.dart';
// import 'package:ecommerce_app/features/order/bloc/order_state.dart';
// import 'package:ecommerce_app/features/order/data/model/order_model.dart';
// import 'package:ecommerce_app/features/order/presentation/order_detail_page.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';

// class OrderPage extends StatefulWidget {
//   final String userId;

//   const OrderPage({super.key, required this.userId});

//   @override
//   State<OrderPage> createState() => _OrderPageState();
// }

// class _OrderPageState extends State<OrderPage> {
//   String _selectedFilter = 'all';

//   @override
//   void initState() {
//     super.initState();
//     _loadOrders();
//   }

//   void _loadOrders() {
//     context.read<OrderPaymentBloc>().add(GetOrdersByUserEvent(widget.userId));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         title: const Text('Đơn hàng của tôi'),
//         elevation: 0,
//       ),
//       body: Column(
//         children: [
//           _buildFilterChips(),
//           Expanded(
//             child: BlocBuilder<OrderPaymentBloc, OrderPaymentState>(
//               builder: (context, state) {
//                 if (state is OrderPaymentLoading) {
//                   return const Center(child: CircularProgressIndicator());
//                 }

//                 if (state is OrderPaymentError) {
//                   return Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.error_outline,
//                             size: 64, color: Colors.red[300]),
//                         const SizedBox(height: 16),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 32),
//                           child: Text(
//                             state.message,
//                             style: const TextStyle(color: Colors.red),
//                             textAlign: TextAlign.center,
//                             overflow: TextOverflow.ellipsis,
//                             maxLines: 3,
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         ElevatedButton.icon(
//                           onPressed: _loadOrders,
//                           icon: const Icon(Icons.refresh),
//                           label: const Text('Thử lại'),
//                         ),
//                       ],
//                     ),
//                   );
//                 }

//                 if (state is OrdersLoaded) {
//                   final filteredOrders = _filterOrders(state.orders);

//                   if (filteredOrders.isEmpty) {
//                     return Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(Icons.shopping_bag_outlined,
//                               size: 80, color: Colors.grey[400]),
//                           const SizedBox(height: 16),
//                           Text(
//                             'Chưa có đơn hàng nào',
//                             style: TextStyle(
//                                 fontSize: 16, color: Colors.grey[600]),
//                           ),
//                         ],
//                       ),
//                     );
//                   }

//                   return RefreshIndicator(
//                     onRefresh: () async => _loadOrders(),
//                     child: ListView.builder(
//                       padding: const EdgeInsets.all(16),
//                       itemCount: filteredOrders.length,
//                       itemBuilder: (context, index) {
//                         return _buildOrderCard(filteredOrders[index]);
//                       },
//                     ),
//                   );
//                 }

//                 return const SizedBox();
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFilterChips() {
//     return Container(
//       color: Colors.white,
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       child: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         child: Row(
//           children: [
//             _buildFilterChip('Tất cả', 'all'),
//             const SizedBox(width: 8),
//             _buildFilterChip('Chờ xác nhận', 'pending'),
//             const SizedBox(width: 8),
//             _buildFilterChip('Đang xử lý', 'processing'),
//             const SizedBox(width: 8),
//             _buildFilterChip('Đang giao', 'shipped'),
//             const SizedBox(width: 8),
//             _buildFilterChip('Hoàn thành', 'delivered'),
//             const SizedBox(width: 8),
//             _buildFilterChip('Đã hủy', 'cancelled'),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildFilterChip(String label, String value) {
//     final isSelected = _selectedFilter == value;
//     return ConstrainedBox(
//       constraints: const BoxConstraints(
//         minWidth: 80,
//         maxWidth: 120,
//       ),
//       child: FilterChip(
//         label: Text(
//           label,
//           style: TextStyle(
//             fontSize: 12,
//             color: isSelected ? Colors.blue[700] : Colors.grey[700],
//             fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//           ),
//           overflow: TextOverflow.ellipsis,
//         ),
//         selected: isSelected,
//         onSelected: (selected) {
//           setState(() {
//             _selectedFilter = value;
//           });
//         },
//         backgroundColor: Colors.grey[200],
//         selectedColor: Colors.blue[100],
//         checkmarkColor: Colors.blue[700],
//       ),
//     );
//   }

//   List<OrderModel> _filterOrders(List<OrderModel> orders) {
//     if (_selectedFilter == 'all') return orders;
//     return orders.where((order) => order.status == _selectedFilter).toList();
//   }

//   Widget _buildOrderCard(OrderModel order) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 16),
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: InkWell(
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => OrderDetailPage(order: order),
//             ),
//           );
//         },
//         borderRadius: BorderRadius.circular(12),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             // mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               // Dòng đầu tiên: Order number và status
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Expanded(
//                     flex: 2,
//                     child: Text(
//                       'Đơn hàng #${order.orderNumber}',
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Flexible(
//                     child: _buildStatusChip(order.status),
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 8),

//               // Ngày đặt hàng
//               Text(
//                 'Ngày đặt: ${_formatDate(order.createdAt)}',
//                 style: TextStyle(color: Colors.grey[600], fontSize: 13),
//                 overflow: TextOverflow.ellipsis,
//               ),

//               const Divider(height: 24),

//               // Số lượng sản phẩm
//               Row(
//                 children: [
//                   Icon(Icons.shopping_bag_outlined,
//                       size: 20, color: Colors.grey[600]),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       '${order.listOrderItem.length} sản phẩm',
//                       style: TextStyle(color: Colors.grey[700]),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 12),

//               // Tổng tiền
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Tổng tiền:',
//                     style: TextStyle(
//                       fontSize: 15,
//                       color: Colors.grey[700],
//                     ),
//                   ),
//                   Flexible(
//                     child: Text(
//                       _formatCurrency(order.total),
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.red,
//                       ),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 12),

//               // Payment status và button chi tiết
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Flexible(
//                     flex: 2,
//                     child: _buildPaymentStatusChip(order.paymentStatus),
//                   ),
//                   const Spacer(),
//                   Flexible(
//                     child: TextButton.icon(
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => OrderDetailPage(order: order),
//                           ),
//                         );
//                       },
//                       icon: const Icon(Icons.arrow_forward, size: 16),
//                       label: const Text(
//                         'Chi tiết',
//                         style: TextStyle(fontSize: 12),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildStatusChip(String status) {
//     Color color;
//     String label;

//     switch (status) {
//       case 'pending':
//         color = Colors.orange;
//         label = 'Chờ xác nhận';
//         break;
//       case 'processing':
//         color = Colors.blue;
//         label = 'Đang xử lý';
//         break;
//       case 'shipped':
//         color = Colors.purple;
//         label = 'Đang giao';
//         break;
//       case 'delivered':
//         color = Colors.green;
//         label = 'Hoàn thành';
//         break;
//       case 'cancelled':
//         color = Colors.red;
//         label = 'Đã hủy';
//         break;
//       default:
//         color = Colors.grey;
//         label = status;
//     }

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: color.withOpacity(0.3)),
//       ),
//       child: Text(
//         label,
//         style: TextStyle(
//           color: color,
//           fontSize: 10,
//           fontWeight: FontWeight.w600,
//         ),
//         textAlign: TextAlign.center,
//         overflow: TextOverflow.ellipsis,
//       ),
//     );
//   }

//   Widget _buildPaymentStatusChip(String paymentStatus) {
//     Color color;
//     String label;

//     switch (paymentStatus) {
//       case 'pending':
//         color = Colors.orange;
//         label = 'Chờ thanh toán';
//         break;
//       case 'paid':
//         color = Colors.green;
//         label = 'Đã thanh toán';
//         break;
//       case 'failed':
//         color = Colors.red;
//         label = 'Thanh toán thất bại';
//         break;
//       default:
//         color = Colors.grey;
//         label = paymentStatus;
//     }

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(Icons.payment, size: 12, color: color),
//           const SizedBox(width: 4),
//           Flexible(
//             child: Text(
//               label,
//               style: TextStyle(
//                 color: color,
//                 fontSize: 10,
//                 fontWeight: FontWeight.w500,
//               ),
//               overflow: TextOverflow.ellipsis,
//               maxLines: 1,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   String _formatDate(String dateStr) {
//     try {
//       final date = DateTime.parse(dateStr);
//       return DateFormat('dd/MM/yyyy HH:mm').format(date);
//     } catch (e) {
//       return dateStr;
//     }
//   }

//   String _formatCurrency(double amount) {
//     return NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(amount);
//   }
// }
import 'package:ecommerce_app/features/order/bloc/order_bloc.dart';
import 'package:ecommerce_app/features/order/bloc/order_event.dart';
import 'package:ecommerce_app/features/order/bloc/order_state.dart';
import 'package:ecommerce_app/features/order/data/model/order_model.dart';
import 'package:ecommerce_app/features/order/presentation/order_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
                        children: [
                          Icon(Icons.shopping_bag_outlined,
                              size: 80, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            _getEmptyMessage(),
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[600]),
                          ),
                          if (_selectedFilter != 'all') ...[
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _selectedFilter = 'all';
                                });
                              },
                              child: const Text('Xem tất cả đơn hàng'),
                            ),
                          ],
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async => _loadOrders(),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('Tất cả', 'all'),
            const SizedBox(width: 8),
            _buildFilterChip('Chờ xác nhận', 'pending'),
            const SizedBox(width: 8),
            _buildFilterChip('Đang xử lý', 'processing'),
            const SizedBox(width: 8),
            _buildFilterChip('Đang giao', 'shipped'),
            const SizedBox(width: 8),
            _buildFilterChip('Hoàn thành', 'delivered'),
            const SizedBox(width: 8),
            _buildFilterChip('Đã hủy', 'cancelled'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 80,
        maxWidth: 120,
      ),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? Colors.blue[700] : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = value;
          });
        },
        backgroundColor: Colors.grey[200],
        selectedColor: Colors.blue[100],
        checkmarkColor: Colors.blue[700],
      ),
    );
  }

  List<OrderModel> _filterOrders(List<OrderModel> orders) {
    if (_selectedFilter == 'all') return orders;
    return orders.where((order) => order.status == _selectedFilter).toList();
  }

  String _getEmptyMessage() {
    switch (_selectedFilter) {
      case 'pending':
        return 'Chưa có đơn hàng chờ xác nhận';
      case 'processing':
        return 'Chưa có đơn hàng đang xử lý';
      case 'shipped':
        return 'Chưa có đơn hàng đang giao';
      case 'delivered':
        return 'Chưa có đơn hàng hoàn thành';
      case 'cancelled':
        return 'Chưa có đơn hàng đã hủy';
      default:
        return 'Chưa có đơn hàng nào';
    }
  }

  Widget _buildOrderCard(OrderModel order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () async {
          // Navigate và đợi kết quả trả về
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailPage(order: order),
            ),
          );

          // Nếu có thay đổi (ví dụ: đơn hàng bị hủy), reload lại danh sách
          if (result == true) {
            _loadOrders();
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dòng đầu tiên: Order number và status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Đơn hàng #${order.orderNumber}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: _buildStatusChip(order.status),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Ngày đặt hàng
              Text(
                'Ngày đặt: ${_formatDate(order.createdAt)}',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),

              const Divider(height: 24),

              // Số lượng sản phẩm
              Row(
                children: [
                  Icon(Icons.shopping_bag_outlined,
                      size: 20, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${order.listOrderItem.length} sản phẩm',
                      style: TextStyle(color: Colors.grey[700]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Tổng tiền
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tổng tiền:',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[700],
                    ),
                  ),
                  Flexible(
                    child: Text(
                      _formatCurrency(order.total),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Payment status và button chi tiết
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 2,
                    child: _buildPaymentStatusChip(order.paymentStatus),
                  ),
                  const Spacer(),
                  Flexible(
                    child: TextButton.icon(
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
                      icon: const Icon(Icons.arrow_forward, size: 16),
                      label: const Text(
                        'Chi tiết',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
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
      case 'processing':
        color = Colors.blue;
        label = 'Đang xử lý';
        break;
      case 'shipped':
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
      default:
        color = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
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
