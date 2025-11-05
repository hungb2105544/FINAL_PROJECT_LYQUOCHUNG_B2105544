import 'package:ecommerce_app/features/address/data/model/user_address_model.dart';
import 'dart:convert';
import 'package:ecommerce_app/features/address/presentation/address_selection_page.dart';
import 'package:ecommerce_app/features/address/bloc/address_bloc.dart';
import 'package:ecommerce_app/features/address/bloc/address_event.dart';
import 'package:ecommerce_app/features/address/bloc/address_state.dart';
import 'package:ecommerce_app/features/cart/data/model/cart_item_model.dart';
import 'package:ecommerce_app/features/order/bloc/order_bloc.dart';
import 'package:ecommerce_app/features/order/bloc/order_event.dart';
import 'package:ecommerce_app/features/order/bloc/order_state.dart';
import 'package:ecommerce_app/features/order/data/model/order_model.dart';
import 'package:ecommerce_app/features/order/data/model/order_item_model.dart';
import 'package:ecommerce_app/features/product/presentation/confirm_check_out.dart';
import 'package:ecommerce_app/features/product/presentation/order_success_page.dart';
import 'package:ecommerce_app/features/voucher/data/model/voucher_model.dart';
import 'package:ecommerce_app/features/voucher/presentation/voucher_selection_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key, required this.listproduct});
  final List<CartItem> listproduct;

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  UserAddressModel? _selectedAddress;
  VoucherModel? _selectectedVoucher;
  String _selectedPaymentMethod = 'cod';
  bool _isProcessing = false;
  bool _isLoadingAddress = true; // Thêm flag để track loading

  static const double _vatRate = 0.08;

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'cod',
      'name': 'Thanh toán khi nhận hàng (COD)',
      'icon': Icons.delivery_dining,
      'description': 'Thanh toán bằng tiền mặt khi nhận hàng',
      'color': Colors.green,
    },
    {
      'id': 'bank_transfer',
      'name': 'Chuyển khoản ngân hàng',
      'icon': Icons.account_balance,
      'description': 'Chuyển khoản qua ngân hàng hoặc ví điện tử',
      'color': Colors.blue,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadDefaultAddress();
  }

  // Thêm method để load địa chỉ mặc định
  void _loadDefaultAddress() {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      context.read<AddressBloc>().add(LoadAddress(userId: userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    const encoder = JsonEncoder.withIndent('  ');
    final prettyJson = encoder
        .convert(widget.listproduct.map((item) => item.toMap()).toList());
    print('🛒 Danh sách sản phẩm trong CheckOut Page (JSON):\n$prettyJson');

    return MultiBlocListener(
      listeners: [
        // Listener cho AddressBloc để tự động chọn địa chỉ mặc định
        BlocListener<AddressBloc, AddressState>(
          listener: (context, state) {
            if (state is AddressLoaded || state is AddressOperationSuccess) {
              List<UserAddressModel> addresses = [];

              if (state is AddressLoaded) {
                addresses = state.userAddresses;
              } else if (state is AddressOperationSuccess) {
                addresses = state.userAddresses;
              }

              // Tìm và chọn địa chỉ mặc định
              if (_selectedAddress == null && addresses.isNotEmpty) {
                final defaultAddress = addresses.firstWhere(
                  (addr) => addr.isDefault == true,
                  orElse: () => addresses
                      .first, // Nếu không có default, chọn địa chỉ đầu tiên
                );

                setState(() {
                  _selectedAddress = defaultAddress;
                  _isLoadingAddress = false;
                });
              }
            } else if (state is AddressError || state is NoAddressFound) {
              setState(() {
                _isLoadingAddress = false;
              });
            }
          },
        ),
        // Listener cho OrderPaymentBloc
        BlocListener<OrderPaymentBloc, OrderPaymentState>(
          listener: (context, state) {
            if (state is OrderCreatedSuccess) {
              setState(() => _isProcessing = false);

              if (_selectedPaymentMethod == 'cod') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderSuccessPage(
                      order: state.order,
                      paymentMethod: _selectedPaymentMethod,
                    ),
                  ),
                );
              } else if (_selectedPaymentMethod == 'bank_transfer') {
                print("Dữ liệu từ trang CheckOut : ");
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ConfirmCheckOutPage(
                      order: state.order,
                      totalOrder: state.order.total.toStringAsFixed(0),
                    ),
                  ),
                );
              }
            } else if (state is OrderPaymentError) {
              setState(() => _isProcessing = false);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Thanh toán"),
          elevation: 0,
        ),
        body: _isLoadingAddress
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle("📍 Địa chỉ giao hàng"),
                              const SizedBox(height: 8),
                              _buildAddressSection(),
                              const SizedBox(height: 20),
                              _buildSectionTitle("📦 Danh sách sản phẩm"),
                              const SizedBox(height: 8),
                              _buildProductList(),
                              const SizedBox(height: 20),
                              _buildSectionTitle("💳 Phương thức thanh toán"),
                              const SizedBox(height: 8),
                              _buildPaymentMethodSection(),
                              const SizedBox(height: 20),
                              _buildSectionTitle("🎫 Voucher"),
                              const SizedBox(height: 8),
                              _buildVoucherSection(),
                              const SizedBox(height: 20),
                              _buildSectionTitle("📋 Tóm tắt đơn hàng"),
                              const SizedBox(height: 8),
                              _buildOrderSummary(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  _buildBottomBar(),
                ],
              ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildAddressSection() {
    return InkWell(
      onTap: _navigateToAddressSelection,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: _selectedAddress != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _selectedAddress!.isDefault
                            ? Icons.star
                            : Icons.location_on,
                        color: _selectedAddress!.isDefault
                            ? Colors.amber
                            : Colors.blue,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _selectedAddress!.address!.receiverName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Text(
                        'Thay đổi',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _selectedAddress!.address!.receiverPhone,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_selectedAddress!.address!.street}, ${_selectedAddress!.address!.ward}, ${_selectedAddress!.address!.district}, ${_selectedAddress!.address!.province}',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  if (_selectedAddress!.isDefault)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Địa chỉ mặc định',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              )
            : Row(
                children: [
                  const Icon(Icons.add_location, color: Colors.blue, size: 24),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Chọn địa chỉ giao hàng',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios,
                      size: 16, color: Colors.blue),
                ],
              ),
      ),
    );
  }

  Widget _buildProductList() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.listproduct.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: Colors.grey.shade200,
        ),
        itemBuilder: (context, index) {
          final item = widget.listproduct[index];
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (item.imageProduct != null && item.imageProduct!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.imageProduct!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.image, color: Colors.grey),
                        );
                      },
                    ),
                  )
                else
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.image, color: Colors.grey),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.nameProduct ?? 'Sản phẩm không tên',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'SL: ${item.quantity}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  _formatCurrency(item.price * item.quantity),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: _paymentMethods.map((method) {
          final isSelected = _selectedPaymentMethod == method['id'];
          return InkWell(
            onTap: () {
              setState(() {
                _selectedPaymentMethod = method['id'];
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? method['color'].withOpacity(0.1)
                    : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? method['color'] : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
              ),
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(method['icon'], color: method['color']),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          method['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          method['description'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(Icons.check_circle, color: method['color'])
                  else
                    const Icon(Icons.circle_outlined, color: Colors.grey),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildVoucherSection() {
    return InkWell(
      onTap: _navigateToVoucherSelection,
      child: _selectectedVoucher != null
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: _isVoucherValid() ? Colors.green : Colors.red,
                ),
                borderRadius: BorderRadius.circular(12),
                color: _isVoucherValid()
                    ? Colors.green.withOpacity(0.05)
                    : Colors.red.withOpacity(0.05),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.local_offer,
                    color: _isVoucherValid() ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectectedVoucher!.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getVoucherDisplayText(),
                          style: TextStyle(
                            color: _isVoucherValid()
                                ? Colors.grey.shade600
                                : Colors.red,
                            fontSize: 12,
                          ),
                        ),
                        if (!_isVoucherValid())
                          Text(
                            "Đơn hàng chưa đủ ${_formatCurrency(double.tryParse(_selectectedVoucher!.minOrderValue.toString()) ?? 0)}",
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Icon(
                    _isVoucherValid() ? Icons.check : Icons.error,
                    color: _isVoucherValid() ? Colors.green : Colors.red,
                  ),
                ],
              ),
            )
          : Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.local_offer, color: Colors.orange),
                  SizedBox(width: 12),
                  Expanded(child: Text("Chọn voucher")),
                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                ],
              ),
            ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildSummaryRow("Tổng giá trị sản phẩm",
              _formatCurrency(_calculateTotalProductValue())),
          const SizedBox(height: 8),
          _buildSummaryRow(
              "Phí giao hàng",
              _calculateShippingFee() == 0
                  ? "Miễn phí"
                  : _formatCurrency(_calculateShippingFee())),
          if (_selectectedVoucher != null &&
              _isVoucherValid() &&
              _calculateDiscount() > 0) ...[
            const SizedBox(height: 8),
            _buildSummaryRow("Giảm giá (${_selectectedVoucher!.code})",
                "-${_formatCurrency(_calculateDiscount())}",
                valueColor: Colors.green),
          ],
          const SizedBox(height: 8),
          _buildSummaryRow("Tạm tính", _formatCurrency(_calculateSubtotal())),
          const SizedBox(height: 8),
          _buildSummaryRow("Thuế VAT (8%)", _formatCurrency(_calculateVAT()),
              valueColor: Colors.orange),
          const Divider(),
          _buildSummaryRow(
            "Tổng thanh toán",
            _formatCurrency(_calculateTotal()),
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {bool isTotal = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: FontWeight.bold,
            color: valueColor ?? (isTotal ? Colors.red : Colors.black),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            offset: const Offset(0, -2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Tổng thanh toán:", style: TextStyle(fontSize: 12)),
              Text(
                _formatCurrency(_calculateTotal()),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _selectedAddress != null && !_isProcessing
                  ? _processOrder
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedAddress != null && !_isProcessing
                    ? Theme.of(context).colorScheme.secondary
                    : Colors.grey,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isProcessing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      "Đặt hàng",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // === HELPER METHODS ===

  Future<void> _navigateToAddressSelection() async {
    final UserAddressModel? selectedAddress =
        await Navigator.push<UserAddressModel>(
      context,
      MaterialPageRoute(builder: (context) => const AddressSelectionPage()),
    );

    if (selectedAddress != null) {
      setState(() => _selectedAddress = selectedAddress);
    }
  }

  Future<void> _navigateToVoucherSelection() async {
    final VoucherModel? selectectedVoucher = await Navigator.push<VoucherModel>(
      context,
      MaterialPageRoute(builder: (context) => const VoucherSelectionPage()),
    );

    if (selectectedVoucher != null) {
      setState(() => _selectectedVoucher = selectectedVoucher);
    }
  }

  double _calculateTotalProductValue() {
    return widget.listproduct
        .fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  bool _isVoucherValid() {
    if (_selectectedVoucher == null) return false;
    final totalProductValue = _calculateTotalProductValue();
    final minOrderValue =
        double.tryParse(_selectectedVoucher!.minOrderValue.toString()) ?? 0.0;
    return totalProductValue >= minOrderValue;
  }

  double _calculateDiscount() {
    if (_selectectedVoucher == null || !_isVoucherValid()) return 0.0;

    final totalProductValue = _calculateTotalProductValue();

    if (_selectectedVoucher!.type == "percentage") {
      final discount = totalProductValue * (_selectectedVoucher!.value / 100);
      final maxDiscountAmount = _selectectedVoucher!.maxDiscountAmount != null
          ? double.tryParse(
                  _selectectedVoucher!.maxDiscountAmount.toString()) ??
              0.0
          : double.infinity;

      if (maxDiscountAmount < double.infinity) {
        return discount > maxDiscountAmount ? maxDiscountAmount : discount;
      }
      return discount;
    } else if (_selectectedVoucher!.type == "fixed_amount") {
      final discountAmount = _selectectedVoucher!.value.toDouble();
      return discountAmount > totalProductValue
          ? totalProductValue
          : discountAmount;
    }

    return 0.0;
  }

  double _calculateShippingFee() {
    if (_selectectedVoucher != null &&
        _selectectedVoucher!.type == 'free_shipping' &&
        _isVoucherValid()) {
      return 0;
    }
    return 30000.0;
  }

  double _calculateSubtotal() {
    return _calculateTotalProductValue() +
        _calculateShippingFee() -
        _calculateDiscount();
  }

  double _calculateVAT() {
    return _calculateSubtotal() * _vatRate;
  }

  double _calculateTotal() {
    final total = _calculateSubtotal() + _calculateVAT();
    return total < 0 ? 0 : total;
  }

  String _getVoucherDisplayText() {
    if (_selectectedVoucher == null) return "";

    switch (_selectectedVoucher!.type) {
      case "percentage":
        final maxDiscount = _selectectedVoucher!.maxDiscountAmount != null
            ? " (tối đa ${_formatCurrency(double.tryParse(_selectectedVoucher!.maxDiscountAmount.toString()) ?? 0)})"
            : "";
        return "Giảm ${_selectectedVoucher!.value}%$maxDiscount";
      case "fixed_amount":
        return "Giảm ${_formatCurrency(_selectectedVoucher!.value.toDouble())}";
      case "free_shipping":
        return "Miễn phí vận chuyển";
      default:
        return _selectectedVoucher!.description ?? "";
    }
  }

  String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )} đ';
  }

  String _generateOrderNumber() {
    final now = DateTime.now();
    return 'ORD${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
  }

  OrderModel _createOrderModel(String orderNumber) {
    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
    print("Giảm giá" + _calculateDiscount().toString());
    return OrderModel(
      id: 0,
      orderNumber: orderNumber,
      userId: userId,
      userAddressId: _selectedAddress?.id,
      subtotal: _calculateTotalProductValue(),
      discountAmount: _calculateDiscount(),
      shippingFee: _calculateShippingFee(),
      taxAmount: _calculateVAT(),
      total: _calculateTotal(),
      voucherId: _selectectedVoucher?.id != null
          ? int.tryParse(_selectectedVoucher!.id.toString())
          : null,
      pointsEarned: (_calculateTotal() / 1000).floor(),
      pointsUsed: 0,
      status: 'pending',
      paymentStatus: 'pending',
      paymentMethod: _selectedPaymentMethod,
      notes: null,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
      listOrderItem: [],
    );
  }

  List<OrderItemModel> _createOrderItems() {
    return widget.listproduct.map((cartItem) {
      return OrderItemModel(
        id: 0,
        orderId: null,
        productId: cartItem.productId,
        variantId: cartItem.variantId,
        quantity: cartItem.quantity,
        unitPrice: cartItem.price,
        discountAmount: 0,
        lineTotal: cartItem.price * cartItem.quantity,
        canReview: false,
      );
    }).toList();
  }

  void _processOrder() {
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn địa chỉ giao hàng')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận đặt hàng'),
        content: Text(
            'Bạn có chắc chắn muốn đặt hàng với tổng giá trị ${_formatCurrency(_calculateTotal())}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _confirmOrder();
            },
            child: const Text('Đặt hàng'),
          ),
        ],
      ),
    );
  }

  void _confirmOrder() {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    final orderNumber = _generateOrderNumber();
    final order = _createOrderModel(orderNumber);
    final orderItems = _createOrderItems();

    // Dispatch event tạo đơn hàng
    context.read<OrderPaymentBloc>().add(
          CreateOrderEvent(
            order: order,
            orderItems: orderItems,
          ),
        );
  }
}
