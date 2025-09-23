import 'dart:ui';

import 'package:ecommerce_app/common_widgets/custom_widget.dart';
import 'package:ecommerce_app/features/product/data/models/branch_stock_model.dart';
import 'package:flutter/material.dart';

class ReviewItem extends StatelessWidget {
  final String avatar;
  final String name;
  final double rating;
  final String comment;

  const ReviewItem({
    super.key,
    required this.avatar,
    required this.name,
    required this.rating,
    required this.comment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(child: Text(avatar)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                RatingStars(rating: rating),
                const SizedBox(height: 4),
                Text(comment),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SpecRow extends StatelessWidget {
  final String label;
  final String value;

  const SpecRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class StockInfoCard extends StatelessWidget {
  final bool isLoading;
  final String? error;
  final BranchStockModel? stock;

  const StockInfoCard({
    super.key,
    required this.isLoading,
    this.error,
    this.stock,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text("Đang kiểm tra tồn kho..."),
          ],
        ),
      );
    }

    if (error != null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red[300]!),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red[600], size: 20),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                "Không thể kiểm tra tồn kho",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );
    }

    if (stock == null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red[300]!),
        ),
        child: Row(
          children: [
            Icon(Icons.inventory_2_outlined, color: Colors.red[600], size: 20),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                "Hết hàng tại tất cả chi nhánh",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final stockColor = stock!.availableStock > 10
        ? Colors.green
        : stock!.availableStock > 0
            ? Colors.orange
            : Colors.red;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: stockColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: stockColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.store, color: stockColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Chi nhánh: ${stock!.branchName}",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: stockColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Còn lại: ${stock!.availableStock} sản phẩm",
                style: TextStyle(
                  color: stockColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "Cách ${stock!.distanceKm.toStringAsFixed(1)}km",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
