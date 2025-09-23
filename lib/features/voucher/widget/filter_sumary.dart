import 'package:flutter/material.dart';

class FilterSummary extends StatelessWidget {
  final String selectedType;
  final String selectedStatus;
  final VoidCallback onClear;

  const FilterSummary({
    super.key,
    required this.selectedType,
    required this.selectedStatus,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    List<String> activeFilters = [];

    if (selectedType != 'all') {
      switch (selectedType) {
        case 'free_shipping':
          activeFilters.add('Miễn phí ship');
          break;
        case 'percentage':
          activeFilters.add('Giảm %');
          break;
        case 'fixed_amount':
          activeFilters.add('Giảm tiền');
          break;
      }
    }

    if (selectedStatus != 'all') {
      switch (selectedStatus) {
        case 'saved':
          activeFilters.add('Đã lưu');
          break;
        case 'not_saved':
          activeFilters.add('Chưa lưu');
          break;
        case 'valid':
          activeFilters.add('Còn hạn');
          break;
        case 'expired':
          activeFilters.add('Hết hạn');
          break;
      }
    }

    if (activeFilters.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.filter_alt, size: 16, color: Colors.blue),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              'Bộ lọc: ${activeFilters.join(', ')}',
              style: const TextStyle(fontSize: 12, color: Colors.blue),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton(
            onPressed: onClear,
            child: const Text('Xóa bộ lọc', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
