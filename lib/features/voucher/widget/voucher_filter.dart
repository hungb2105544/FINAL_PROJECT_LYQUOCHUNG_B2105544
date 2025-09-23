import 'package:flutter/material.dart';

class VoucherFilterWidget extends StatefulWidget {
  final String selectedType;
  final String selectedStatus;
  final void Function(String type, String status) onApply;

  const VoucherFilterWidget({
    super.key,
    required this.selectedType,
    required this.selectedStatus,
    required this.onApply,
  });

  @override
  State<VoucherFilterWidget> createState() => _VoucherFilterWidgetState();
}

class _VoucherFilterWidgetState extends State<VoucherFilterWidget> {
  late String tempType;
  late String tempStatus;

  @override
  void initState() {
    super.initState();
    tempType = widget.selectedType;
    tempStatus = widget.selectedStatus;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Bộ lọc Voucher'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Loại voucher:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildTypeChip('all', 'Tất cả'),
                _buildTypeChip('free_shipping', 'Miễn phí ship'),
                _buildTypeChip('percentage', 'Giảm %'),
                _buildTypeChip('fixed_amount', 'Giảm tiền'),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Trạng thái:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildStatusChip('all', 'Tất cả'),
                _buildStatusChip('saved', 'Đã lưu'),
                _buildStatusChip('not_saved', 'Chưa lưu'),
                _buildStatusChip('valid', 'Còn hạn'),
                _buildStatusChip('expired', 'Hết hạn'),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onApply(tempType, tempStatus);
            Navigator.of(context).pop();
          },
          child: const Text('Áp dụng'),
        ),
      ],
    );
  }

  Widget _buildTypeChip(String value, String label) {
    return FilterChip(
      label: Text(label),
      selected: tempType == value,
      onSelected: (_) {
        setState(() {
          tempType = value;
        });
      },
    );
  }

  Widget _buildStatusChip(String value, String label) {
    return FilterChip(
      label: Text(label),
      selected: tempStatus == value,
      onSelected: (_) {
        setState(() {
          tempStatus = value;
        });
      },
    );
  }
}
