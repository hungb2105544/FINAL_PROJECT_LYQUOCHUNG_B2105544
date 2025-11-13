// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';

// class PointsUsageWidget extends StatefulWidget {
//   final int availablePoints;
//   final double orderTotal;
//   final int pointsToMoneyRatio;
//   final Function(int pointsUsed, double discountAmount) onPointsChanged;

//   const PointsUsageWidget({
//     Key? key,
//     required this.availablePoints,
//     required this.orderTotal,
//     this.pointsToMoneyRatio = 100,
//     required this.onPointsChanged,
//   }) : super(key: key);

//   @override
//   State<PointsUsageWidget> createState() => _PointsUsageWidgetState();
// }

// class _PointsUsageWidgetState extends State<PointsUsageWidget> {
//   final TextEditingController _pointsController = TextEditingController();
//   int _pointsToUse = 0;
//   double _discountAmount = 0;
//   bool _isExpanded = false;

//   @override
//   void initState() {
//     super.initState();
//     _pointsController.text = '0';
//   }

//   @override
//   void dispose() {
//     _pointsController.dispose();
//     super.dispose();
//   }

//   // Tính số tiền giảm giá từ điểm
//   double _calculateDiscountFromPoints(int points) {
//     // 100 điểm = 1000đ (10đ/điểm)
//     return (points / widget.pointsToMoneyRatio) * 1000;
//   }

//   // Tính số điểm tối đa có thể dùng
//   int _calculateMaxPoints() {
//     // Không được vượt quá 50% tổng đơn hàng
//     final maxDiscountAmount = widget.orderTotal * 0.5;
//     final maxPointsForDiscount =
//         (maxDiscountAmount / 1000 * widget.pointsToMoneyRatio).floor();

//     // Lấy giá trị nhỏ nhất giữa điểm có sẵn và điểm tối đa được dùng
//     return widget.availablePoints < maxPointsForDiscount
//         ? widget.availablePoints
//         : maxPointsForDiscount;
//   }

//   void _updatePoints(int points) {
//     final maxPoints = _calculateMaxPoints();

//     // Giới hạn điểm sử dụng
//     if (points > maxPoints) {
//       points = maxPoints;
//       _pointsController.text = points.toString();

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Bạn chỉ có thể sử dụng tối đa $maxPoints điểm'),
//           backgroundColor: Colors.orange,
//           duration: const Duration(seconds: 2),
//         ),
//       );
//     }

//     setState(() {
//       _pointsToUse = points;
//       _discountAmount = _calculateDiscountFromPoints(points);
//     });

//     widget.onPointsChanged(_pointsToUse, _discountAmount);
//   }

//   void _useAllPoints() {
//     final maxPoints = _calculateMaxPoints();
//     _pointsController.text = maxPoints.toString();
//     _updatePoints(maxPoints);
//   }

//   String _formatCurrency(double amount) {
//     return NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(amount);
//   }

//   String _formatNumber(int number) {
//     return NumberFormat('#,###', 'vi_VN').format(number);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final maxPoints = _calculateMaxPoints();
//     final maxDiscount = _calculateDiscountFromPoints(maxPoints);

//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: _pointsToUse > 0 ? Colors.orange : Colors.grey[300]!,
//           width: _pointsToUse > 0 ? 2 : 1,
//         ),
//         boxShadow: [
//           if (_pointsToUse > 0)
//             BoxShadow(
//               color: Colors.orange.withOpacity(0.1),
//               blurRadius: 12,
//               offset: const Offset(0, 4),
//             ),
//         ],
//       ),
//       child: Column(
//         children: [
//           // Header - Có thể mở rộng
//           InkWell(
//             onTap: () {
//               setState(() {
//                 _isExpanded = !_isExpanded;
//               });
//             },
//             borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Row(
//                 children: [
//                   // Icon
//                   Container(
//                     padding: const EdgeInsets.all(10),
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: [
//                           Colors.orange[400]!,
//                           Colors.deepOrange[400]!,
//                         ],
//                       ),
//                       borderRadius: BorderRadius.circular(12),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.orange.withOpacity(0.3),
//                           blurRadius: 8,
//                           offset: const Offset(0, 4),
//                         ),
//                       ],
//                     ),
//                     child: const Icon(
//                       Icons.stars_rounded,
//                       color: Colors.white,
//                       size: 24,
//                     ),
//                   ),
//                   const SizedBox(width: 16),

//                   // Info
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             const Text(
//                               'Sử dụng điểm tích lũy',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             if (_pointsToUse > 0) ...[
//                               const SizedBox(width: 8),
//                               Container(
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 8,
//                                   vertical: 2,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   color: Colors.orange,
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                                 child: const Text(
//                                   'Đang dùng',
//                                   style: TextStyle(
//                                     fontSize: 10,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ],
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           'Bạn có ${_formatNumber(widget.availablePoints)} điểm',
//                           style: TextStyle(
//                             fontSize: 13,
//                             color: Colors.grey[600],
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                         if (_pointsToUse > 0) ...[
//                           const SizedBox(height: 4),
//                           Text(
//                             'Giảm ${_formatCurrency(_discountAmount)}',
//                             style: const TextStyle(
//                               fontSize: 14,
//                               color: Colors.orange,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ],
//                     ),
//                   ),

//                   // Expand Icon
//                   Icon(
//                     _isExpanded
//                         ? Icons.keyboard_arrow_up_rounded
//                         : Icons.keyboard_arrow_down_rounded,
//                     color: Colors.grey[600],
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           // Expanded Content
//           if (_isExpanded) ...[
//             const Divider(height: 1),
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Thông tin quy đổi
//                   Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: Colors.orange[50],
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(
//                         color: Colors.orange[200]!,
//                         width: 1,
//                       ),
//                     ),
//                     child: Row(
//                       children: [
//                         Icon(
//                           Icons.info_outline_rounded,
//                           size: 20,
//                           color: Colors.orange[700],
//                         ),
//                         const SizedBox(width: 8),
//                         Expanded(
//                           child: Text(
//                             '${widget.pointsToMoneyRatio} điểm = 1.000₫ • Tối đa ${_formatNumber(maxPoints)} điểm (${_formatCurrency(maxDiscount)})',
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: Colors.orange[900],
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   const SizedBox(height: 16),

//                   // Input điểm
//                   Row(
//                     children: [
//                       Expanded(
//                         child: TextField(
//                           controller: _pointsController,
//                           keyboardType: TextInputType.number,
//                           inputFormatters: [
//                             FilteringTextInputFormatter.digitsOnly,
//                           ],
//                           decoration: InputDecoration(
//                             labelText: 'Nhập số điểm muốn sử dụng',
//                             hintText: '0',
//                             prefixIcon: const Icon(Icons.stars_rounded),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: const BorderSide(
//                                 color: Colors.orange,
//                                 width: 2,
//                               ),
//                             ),
//                             contentPadding: const EdgeInsets.symmetric(
//                               horizontal: 16,
//                               vertical: 14,
//                             ),
//                           ),
//                           onChanged: (value) {
//                             final points = int.tryParse(value) ?? 0;
//                             _updatePoints(points);
//                           },
//                         ),
//                       ),
//                       const SizedBox(width: 12),

//                       // Nút dùng tất cả
//                       ElevatedButton(
//                         onPressed:
//                             widget.availablePoints > 0 ? _useAllPoints : null,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.orange,
//                           foregroundColor: Colors.white,
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 20,
//                             vertical: 16,
//                           ),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           elevation: 0,
//                         ),
//                         child: const Text(
//                           'Dùng hết',
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 14,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),

//                   const SizedBox(height: 16),

//                   // Quick select buttons
//                   if (widget.availablePoints >= 100) ...[
//                     const Text(
//                       'Chọn nhanh:',
//                       style: TextStyle(
//                         fontSize: 13,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Wrap(
//                       spacing: 8,
//                       runSpacing: 8,
//                       children: [
//                         if (widget.availablePoints >= 100)
//                           _buildQuickSelectChip(100),
//                         if (widget.availablePoints >= 200)
//                           _buildQuickSelectChip(200),
//                         if (widget.availablePoints >= 500)
//                           _buildQuickSelectChip(500),
//                         if (widget.availablePoints >= 1000)
//                           _buildQuickSelectChip(1000),
//                       ],
//                     ),
//                   ],

//                   if (_pointsToUse > 0) ...[
//                     const SizedBox(height: 16),
//                     // Clear button
//                     SizedBox(
//                       width: double.infinity,
//                       child: OutlinedButton.icon(
//                         onPressed: () {
//                           _pointsController.text = '0';
//                           _updatePoints(0);
//                         },
//                         icon: const Icon(Icons.clear_rounded, size: 18),
//                         label: const Text('Xóa'),
//                         style: OutlinedButton.styleFrom(
//                           foregroundColor: Colors.grey[700],
//                           side: BorderSide(color: Colors.grey[300]!),
//                           padding: const EdgeInsets.symmetric(vertical: 12),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildQuickSelectChip(int points) {
//     if (points > _calculateMaxPoints()) return const SizedBox.shrink();

//     final isSelected = _pointsToUse == points;

//     return InkWell(
//       onTap: () {
//         _pointsController.text = points.toString();
//         _updatePoints(points);
//       },
//       borderRadius: BorderRadius.circular(20),
//       child: Container(
//         padding: const EdgeInsets.symmetric(
//           horizontal: 16,
//           vertical: 8,
//         ),
//         decoration: BoxDecoration(
//           color: isSelected ? Colors.orange : Colors.grey[100],
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(
//             color: isSelected ? Colors.orange : Colors.grey[300]!,
//             width: isSelected ? 2 : 1,
//           ),
//         ),
//         child: Text(
//           '${_formatNumber(points)} điểm',
//           style: TextStyle(
//             fontSize: 13,
//             fontWeight: FontWeight.w600,
//             color: isSelected ? Colors.white : Colors.grey[700],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class PointsUsageWidget extends StatefulWidget {
  final int availablePoints;
  final double orderTotal;
  final int pointsToMoneyRatio;
  final Function(int pointsUsed, double discountAmount) onPointsChanged;

  const PointsUsageWidget({
    Key? key,
    required this.availablePoints,
    required this.orderTotal,
    this.pointsToMoneyRatio = 100,
    required this.onPointsChanged,
  }) : super(key: key);

  @override
  State<PointsUsageWidget> createState() => _PointsUsageWidgetState();
}

class _PointsUsageWidgetState extends State<PointsUsageWidget> {
  final TextEditingController _pointsController = TextEditingController();
  int _pointsToUse = 0;
  double _discountAmount = 0;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _pointsController.text = '0';
  }

  @override
  void dispose() {
    _pointsController.dispose();
    super.dispose();
  }

  // Tính số tiền giảm giá từ điểm
  double _calculateDiscountFromPoints(int points) {
    // 100 điểm = 1000đ (10đ/điểm)
    return (points / widget.pointsToMoneyRatio) * 1000;
  }

  // Tính số điểm tối đa có thể dùng
  int _calculateMaxPoints() {
    // Không được vượt quá 50% tổng đơn hàng
    final maxDiscountAmount = widget.orderTotal * 0.5;
    final maxPointsForDiscount =
        (maxDiscountAmount / 1000 * widget.pointsToMoneyRatio).floor();

    // Lấy giá trị nhỏ nhất giữa điểm có sẵn và điểm tối đa được dùng
    return widget.availablePoints < maxPointsForDiscount
        ? widget.availablePoints
        : maxPointsForDiscount;
  }

  void _updatePoints(int points) {
    final maxPoints = _calculateMaxPoints();

    // Giới hạn điểm sử dụng
    if (points > maxPoints) {
      points = maxPoints;
      _pointsController.text = points.toString();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bạn chỉ có thể sử dụng tối đa $maxPoints điểm'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
    }

    setState(() {
      _pointsToUse = points;
      _discountAmount = _calculateDiscountFromPoints(points);
    });

    widget.onPointsChanged(_pointsToUse, _discountAmount);
  }

  void _useAllPoints() {
    final maxPoints = _calculateMaxPoints();
    _pointsController.text = maxPoints.toString();
    _updatePoints(maxPoints);
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(amount);
  }

  String _formatNumber(int number) {
    return NumberFormat('#,###', 'vi_VN').format(number);
  }

  @override
  Widget build(BuildContext context) {
    final maxPoints = _calculateMaxPoints();
    final maxDiscount = _calculateDiscountFromPoints(maxPoints);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _pointsToUse > 0 ? Colors.orange : Colors.grey[300]!,
          width: _pointsToUse > 0 ? 2 : 1,
        ),
        boxShadow: [
          if (_pointsToUse > 0)
            BoxShadow(
              color: Colors.orange.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header - Có thể mở rộng
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.orange[400]!,
                          Colors.deepOrange[400]!,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.stars_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            const Flexible(
                              child: Text(
                                'Sử dụng điểm tích lũy',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (_pointsToUse > 0) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Đang dùng',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Bạn có ${_formatNumber(widget.availablePoints)} điểm',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (_pointsToUse > 0) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Giảm ${_formatCurrency(_discountAmount)}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Expand Icon
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
          ),

          // Expanded Content
          if (_isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Thông tin quy đổi
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.orange[200]!,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 20,
                          color: Colors.orange[700],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${widget.pointsToMoneyRatio} điểm = 1.000₫ • Tối đa ${_formatNumber(maxPoints)} điểm (${_formatCurrency(maxDiscount)})',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange[900],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Input điểm
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _pointsController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            labelText: 'Nhập số điểm',
                            hintText: '0',
                            prefixIcon: const Icon(Icons.stars_rounded),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.orange,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          onChanged: (value) {
                            final points = int.tryParse(value) ?? 0;
                            _updatePoints(points);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Nút dùng tất cả
                      ElevatedButton(
                        onPressed:
                            widget.availablePoints > 0 ? _useAllPoints : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Dùng hết',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Quick select buttons
                  if (widget.availablePoints >= 100) ...[
                    const Text(
                      'Chọn nhanh:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (widget.availablePoints >= 100)
                          _buildQuickSelectChip(100),
                        if (widget.availablePoints >= 200)
                          _buildQuickSelectChip(200),
                        if (widget.availablePoints >= 500)
                          _buildQuickSelectChip(500),
                        if (widget.availablePoints >= 1000)
                          _buildQuickSelectChip(1000),
                      ],
                    ),
                  ],

                  if (_pointsToUse > 0) ...[
                    const SizedBox(height: 16),
                    // Clear button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _pointsController.text = '0';
                          _updatePoints(0);
                        },
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        label: const Text('Xóa'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey[700],
                          side: BorderSide(color: Colors.grey[300]!),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickSelectChip(int points) {
    if (points > _calculateMaxPoints()) return const SizedBox.shrink();

    final isSelected = _pointsToUse == points;

    return InkWell(
      onTap: () {
        _pointsController.text = points.toString();
        _updatePoints(points);
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.orange : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          '${_formatNumber(points)} điểm',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }
}
