import 'dart:io';
import 'package:ecommerce_app/features/order/bloc/rating_bloc/rating_bloc.dart';
import 'package:ecommerce_app/features/order/bloc/rating_bloc/rating_event.dart';
import 'package:ecommerce_app/features/order/bloc/rating_bloc/rating_state.dart';
import 'package:ecommerce_app/service/rating_image_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecommerce_app/features/product/data/models/product_rating_model.dart';

class SubmitRatingPage extends StatefulWidget {
  final int productId;
  final int orderItemId;
  final String userId;
  final String? productName;
  final String? productImage;

  const SubmitRatingPage({
    Key? key,
    required this.productId,
    required this.orderItemId,
    required this.userId,
    this.productName,
    this.productImage,
  }) : super(key: key);

  @override
  State<SubmitRatingPage> createState() => _SubmitRatingPageState();
}

class _SubmitRatingPageState extends State<SubmitRatingPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _commentController = TextEditingController();
  final _prosController = TextEditingController();
  final _consController = TextEditingController();

  int _rating = 5;
  List<File> _selectedImages = [];
  bool _isAnonymous = false;
  bool _canReview = false;
  bool _isCheckingEligibility = true;

  final ImagePicker _picker = ImagePicker();
  static const int maxImages = 5;

  @override
  void initState() {
    super.initState();
    // Check eligibility is already triggered from previous screen
    _checkEligibility();
  }

  void _checkEligibility() {
    // Listen to bloc state for eligibility check
    Future.delayed(const Duration(milliseconds: 100), () {
      final state = context.read<RatingBloc>().state;
      if (state is ReviewEligibilityChecked) {
        setState(() {
          _canReview = state.canReview;
          _isCheckingEligibility = false;
        });

        if (!state.canReview) {
          _showErrorDialog(state.message);
        }
      } else {
        setState(() {
          _isCheckingEligibility = false;
          _canReview = true; // Assume can review if not checked
        });
      }
    });
  }

  void _showErrorDialog(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Không thể đánh giá'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close rating page
              },
              child: const Text('Đóng'),
            ),
          ],
        ),
      );
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _commentController.dispose();
    _prosController.dispose();
    _consController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final remainingSlots = maxImages - _selectedImages.length;
      if (remainingSlots <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tối đa $maxImages ảnh')),
        );
        return;
      }

      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (images.isEmpty) return;

      final imagesToAdd =
          images.take(remainingSlots).map((e) => File(e.path)).toList();

      // Validate images
      final validImages =
          await RatingImageHelper.validateImageFiles(imagesToAdd);

      if (validImages.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không có ảnh hợp lệ')),
          );
        }
        return;
      }

      setState(() {
        _selectedImages.addAll(validImages);
      });

      if (validImages.length < imagesToAdd.length && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Đã thêm ${validImages.length}/${imagesToAdd.length} ảnh hợp lệ',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi chọn ảnh: $e')),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _submitRating() {
    if (!_formKey.currentState!.validate()) return;

    // Parse pros and cons
    final pros = _prosController.text
        .split('\n')
        .where((s) => s.trim().isNotEmpty)
        .toList();
    final cons = _consController.text
        .split('\n')
        .where((s) => s.trim().isNotEmpty)
        .toList();

    // Create rating model
    final rating = ProductRatingModel(
      id: 0,
      productId: widget.productId,
      orderItemId: widget.orderItemId,
      rating: _rating,
      title: _titleController.text.trim(),
      comment: _commentController.text.trim(),
      pros: pros.isEmpty ? null : pros,
      cons: cons.isEmpty ? null : cons,
      isAnonymous: _isAnonymous,
      isVerifiedPurchase: true,
      createdAt: DateTime.now().toIso8601String(),
      userId: widget.userId,
    );

    // Submit via Bloc
    context.read<RatingBloc>().add(
          SubmitRating(
            rating: rating,
            images: _selectedImages.isEmpty ? null : _selectedImages,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Đánh giá sản phẩm'),
        elevation: 0,
      ),
      body: BlocConsumer<RatingBloc, RatingState>(
        listener: (context, state) {
          if (state is RatingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is RatingSubmitted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Đánh giá của bạn đã được gửi!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true);
          }
        },
        builder: (context, state) {
          if (_isCheckingEligibility) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Đang kiểm tra quyền đánh giá...'),
                ],
              ),
            );
          }

          if (!_canReview) {
            return const SizedBox.shrink();
          }

          final isSubmitting =
              state is RatingLoading || state is RatingUploadingImages;

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Product Info Card
                if (widget.productName != null) _buildProductInfoCard(),

                const SizedBox(height: 16),

                // Upload Progress
                if (state is RatingUploadingImages) ...[
                  _buildUploadProgress(state),
                  const SizedBox(height: 16),
                ],

                // Rating Card
                _buildRatingCard(isSubmitting),

                const SizedBox(height: 12),

                // Review Form Card
                _buildReviewFormCard(isSubmitting),

                const SizedBox(height: 12),

                // Images Card
                _buildImagesCard(isSubmitting),

                const SizedBox(height: 12),

                // Options Card
                _buildOptionsCard(isSubmitting),

                const SizedBox(height: 24),

                // Submit Button
                _buildSubmitButton(isSubmitting),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductInfoCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (widget.productImage != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  widget.productImage!,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) {
                    return Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[200],
                      child: Icon(Icons.image, color: Colors.grey[400]),
                    );
                  },
                ),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sản phẩm',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.productName!,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadProgress(RatingUploadingImages state) {
    return Card(
      elevation: 0,
      color: Colors.blue[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Đang tải ảnh lên...',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: state.current / state.total,
              backgroundColor: Colors.blue[100],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            const SizedBox(height: 8),
            Text(
              '${state.current}/${state.total} ảnh',
              style: TextStyle(color: Colors.grey[700], fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingCard(bool isSubmitting) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Đánh giá của bạn',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    size: 36,
                  ),
                  color: Colors.amber,
                  onPressed: isSubmitting
                      ? null
                      : () => setState(() => _rating = index + 1),
                );
              }),
            ),
            const SizedBox(height: 8),
            Text(
              _getRatingLabel(_rating),
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRatingLabel(int rating) {
    switch (rating) {
      case 1:
        return 'Rất tệ';
      case 2:
        return 'Tệ';
      case 3:
        return 'Bình thường';
      case 4:
        return 'Tốt';
      case 5:
        return 'Rất tốt';
      default:
        return '';
    }
  }

  Widget _buildReviewFormCard(bool isSubmitting) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            TextFormField(
              controller: _titleController,
              enabled: !isSubmitting,
              decoration: InputDecoration(
                labelText: 'Tiêu đề đánh giá *',
                hintText: 'Tóm tắt trải nghiệm của bạn',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập tiêu đề';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Comment
            TextFormField(
              controller: _commentController,
              enabled: !isSubmitting,
              decoration: InputDecoration(
                labelText: 'Nhận xét của bạn *',
                hintText: 'Chia sẻ trải nghiệm của bạn về sản phẩm này',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                alignLabelWithHint: true,
              ),
              maxLines: 5,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập nhận xét';
                }
                if (value.trim().length < 10) {
                  return 'Nhận xét phải có ít nhất 10 ký tự';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Pros
            TextFormField(
              controller: _prosController,
              enabled: !isSubmitting,
              decoration: InputDecoration(
                labelText: 'Ưu điểm (tùy chọn)',
                hintText: 'Những điểm bạn thích\nMỗi dòng một ưu điểm',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                alignLabelWithHint: true,
                prefixIcon:
                    const Icon(Icons.add_circle_outline, color: Colors.green),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Cons
            TextFormField(
              controller: _consController,
              enabled: !isSubmitting,
              decoration: InputDecoration(
                labelText: 'Nhược điểm (tùy chọn)',
                hintText: 'Những điểm cần cải thiện\nMỗi dòng một nhược điểm',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                alignLabelWithHint: true,
                prefixIcon:
                    const Icon(Icons.remove_circle_outline, color: Colors.red),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagesCard(bool isSubmitting) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.add_photo_alternate, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Thêm hình ảnh',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_selectedImages.length}/$maxImages',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ..._selectedImages.asMap().entries.map((entry) {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          entry.value,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      if (!isSubmitting)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => _removeImage(entry.key),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                }),
                if (_selectedImages.length < maxImages && !isSubmitting)
                  GestureDetector(
                    onTap: _pickImages,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!, width: 2),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[50],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate,
                              size: 32, color: Colors.grey[400]),
                          const SizedBox(height: 4),
                          Text(
                            'Thêm ảnh',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsCard(bool isSubmitting) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: CheckboxListTile(
        title: const Text('Đăng đánh giá ẩn danh'),
        subtitle: const Text(
          'Tên của bạn sẽ không được hiển thị',
          style: TextStyle(fontSize: 12),
        ),
        value: _isAnonymous,
        enabled: !isSubmitting,
        onChanged: (value) => setState(() => _isAnonymous = value ?? false),
        controlAffinity: ListTileControlAffinity.leading,
        activeColor: Colors.blue,
      ),
    );
  }

  Widget _buildSubmitButton(bool isSubmitting) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isSubmitting ? null : _submitRating,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Gửi đánh giá',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
