import 'dart:io';
import 'package:ecommerce_app/core/data/datasources/supabase_client.dart';
import 'package:ecommerce_app/features/order/domain/repositories/rating_repository.dart';
import 'package:ecommerce_app/features/product/data/models/product_rating_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RatingRepositoryImpl implements RatingRepository {
  final supabase = SupabaseConfig.client;

  // Storage bucket name for rating images
  static const String ratingImagesBucket = 'rating-images';

  @override
  Future<List<ProductRatingModel>> fetchProductRatings(String productId) async {
    try {
      final response = await supabase
          .from('product_ratings')
          .select('*')
          .eq('product_id', productId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => ProductRatingModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching product ratings: $e');
      rethrow;
    }
  }

  @override
  Future<List<ProductRatingModel>> fetchUserRatings(String userId) async {
    try {
      final response = await supabase
          .from('product_ratings')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => ProductRatingModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching user ratings: $e');
      rethrow;
    }
  }

  @override
  Future<List<String>> uploadRatingImages(List<File> images) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      throw const AuthException('User is not authenticated.');
    }

    try {
      final List<String> uploadedUrls = [];
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      for (int i = 0; i < images.length; i++) {
        final file = images[i];
        final fileExt = file.path.split('.').last.toLowerCase();

        // Validate file extension
        if (!['jpg', 'jpeg', 'png', 'webp'].contains(fileExt)) {
          throw Exception(
              'Invalid file format. Only JPG, PNG, and WEBP are allowed.');
        }

        // Generate unique file name
        final fileName = '$userId/${timestamp}_$i.$fileExt';

        // Upload to Supabase Storage
        await supabase.storage.from(ratingImagesBucket).upload(
              fileName,
              file,
              fileOptions: const FileOptions(
                cacheControl: '3600',
                upsert: false,
              ),
            );

        // Get public URL
        final imageUrl =
            supabase.storage.from(ratingImagesBucket).getPublicUrl(fileName);

        uploadedUrls.add(imageUrl);
      }

      return uploadedUrls;
    } catch (e) {
      print('Error uploading rating images: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteRatingImages(List<String> imageUrls) async {
    try {
      final List<String> filePaths = [];

      for (final url in imageUrls) {
        // Extract file path from URL
        // Example URL: https://xxx.supabase.co/storage/v1/object/public/rating-images/user_id/timestamp_0.jpg
        final uri = Uri.parse(url);
        final segments = uri.pathSegments;

        // Find the index of 'rating-images' bucket
        final bucketIndex = segments.indexOf(ratingImagesBucket);
        if (bucketIndex != -1 && bucketIndex < segments.length - 1) {
          // Get path after bucket name
          final filePath = segments.sublist(bucketIndex + 1).join('/');
          filePaths.add(filePath);
        }
      }

      if (filePaths.isNotEmpty) {
        await supabase.storage.from(ratingImagesBucket).remove(filePaths);
      }
    } catch (e) {
      print('Error deleting rating images: $e');
      // Don't rethrow, as this is a cleanup operation
    }
  }

  @override
  Future<ProductRatingModel> submitProductRating(
      ProductRatingModel rating) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      throw const AuthException('User is not authenticated.');
    }
    if (rating.productId == null || rating.orderItemId == null) {
      throw ArgumentError(
          'Product ID and Order Item ID must be provided to submit a rating.');
    }

    // 1. Check if user is eligible to review
    final canReview = await canUserReviewProduct(
        userId, rating.productId!, rating.orderItemId!);
    if (!canReview) {
      throw Exception(
          'You are not eligible to review this product or have already reviewed it.');
    }

    try {
      final ratingJson = rating.toJson();
      ratingJson.remove('id');
      // 2. Insert the rating
      final response = await supabase
          .from('product_ratings')
          .insert(ratingJson)
          .select()
          .single();

      // 3. Update product's average rating and total ratings
      await _updateProductRatingStats(rating.productId!);

      // 4. Mark the order item as reviewe
      await supabase
          .from('order_items')
          .update({'can_review': false}).eq('id', rating.orderItemId!);

      return ProductRatingModel.fromJson(response);
    } catch (e) {
      print('Error submitting product rating: $e');

      // Cleanup uploaded images if rating submission fails
      if (rating.images != null && rating.images!.isNotEmpty) {
        await deleteRatingImages(rating.images!);
      }

      rethrow;
    }
  }

  @override
  Future<void> updateProductRating(ProductRatingModel rating) async {
    if (rating.productId == null) {
      throw ArgumentError('Product ID must be provided to update a rating.');
    }

    try {
      // Get old rating data to clean up removed images
      final oldRatingData = await supabase
          .from('product_ratings')
          .select('images')
          .eq('id', rating.id)
          .single();

      final oldImages = (oldRatingData['images'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [];

      // Update the rating
      await supabase
          .from('product_ratings')
          .update(rating.toJson()
            ..['updated_at'] = DateTime.now().toIso8601String())
          .eq('id', rating.id);

      // Re-calculate product's average rating and total ratings
      await _updateProductRatingStats(rating.productId!);

      // Delete removed images
      final newImages = rating.images ?? [];
      final removedImages =
          oldImages.where((oldUrl) => !newImages.contains(oldUrl)).toList();

      if (removedImages.isNotEmpty) {
        await deleteRatingImages(removedImages);
      }
    } catch (e) {
      print('Error updating product rating: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteProductRating(int ratingId) async {
    try {
      // First, get the product_id and images before deleting
      final ratingData = await supabase
          .from('product_ratings')
          .select('product_id, images')
          .eq('id', ratingId)
          .single();

      final productId = ratingData['product_id'] as int?;
      final images =
          (ratingData['images'] as List?)?.map((e) => e.toString()).toList();

      // Delete the rating
      await supabase.from('product_ratings').delete().eq('id', ratingId);

      // Delete associated images
      if (images != null && images.isNotEmpty) {
        await deleteRatingImages(images);
      }

      // Re-calculate stats for the affected product
      if (productId != null) {
        await _updateProductRatingStats(productId);
      }
    } catch (e) {
      print('Error deleting product rating: $e');
      rethrow;
    }
  }

  @override
  Future<bool> canUserReviewProduct(
      String userId, int productId, int orderItemId) async {
    try {
      // Check if order item exists and belongs to the user
      final orderItemResponse = await supabase
          .from('order_items')
          .select('id, order_id, product_id, can_review')
          .eq('id', orderItemId)
          .eq('product_id', productId)
          .maybeSingle();

      if (orderItemResponse == null) {
        return false; // Order item not found or doesn't match product
      }

      // Check if can_review is true
      final canReview = orderItemResponse['can_review'] as bool? ?? false;
      if (!canReview) {
        return false; // Already reviewed or not eligible
      }

      // Verify the order belongs to the user
      final orderId = orderItemResponse['order_id'] as int;
      final orderResponse = await supabase
          .from('orders')
          .select('user_id, status')
          .eq('id', orderId)
          .eq('user_id', userId)
          .maybeSingle();

      if (orderResponse == null) {
        return false; // Order doesn't belong to user
      }

      // Check if order is delivered
      final orderStatus = orderResponse['status'] as String;
      if (orderStatus != 'delivered') {
        return false; // Order not delivered yet
      }

      // Check if user has already reviewed this product for this order item
      final existingReview = await supabase
          .from('product_ratings')
          .select('id')
          .eq('user_id', userId)
          .eq('product_id', productId)
          .eq('order_item_id', orderItemId)
          .maybeSingle();

      return existingReview == null; // Can review if no existing review
    } catch (e) {
      print('Error checking review eligibility: $e');
      return false; // Default to false on error
    }
  }

  /// Calculates and updates the product's rating statistics without using database functions.
  Future<void> _updateProductRatingStats(int productId) async {
    try {
      // Fetch all ratings for this product
      final ratings = await supabase
          .from('product_ratings')
          .select('rating')
          .eq('product_id', productId);

      if (ratings.isEmpty) {
        // No ratings, reset to defaults
        await supabase.from('products').update({
          'average_rating': 0,
          'total_ratings': 0,
          'rating_distribution': {'1': 0, '2': 0, '3': 0, '4': 0, '5': 0},
        }).eq('id', productId);
        return;
      }

      // Calculate statistics
      final ratingList =
          (ratings as List).map((r) => r['rating'] as int).toList();
      final totalRatings = ratingList.length;
      final sumRatings = ratingList.reduce((a, b) => a + b);
      final averageRating = sumRatings / totalRatings;

      // Calculate rating distribution
      final distribution = {
        '1': ratingList.where((r) => r == 1).length,
        '2': ratingList.where((r) => r == 2).length,
        '3': ratingList.where((r) => r == 3).length,
        '4': ratingList.where((r) => r == 4).length,
        '5': ratingList.where((r) => r == 5).length,
      };

      // Update product
      await supabase.from('products').update({
        'average_rating': double.parse(averageRating.toStringAsFixed(2)),
        'total_ratings': totalRatings,
        'rating_distribution': distribution,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', productId);
    } catch (e) {
      print('Error updating product rating stats: $e');
      // Do not rethrow, as this is a background task
    }
  }
}
