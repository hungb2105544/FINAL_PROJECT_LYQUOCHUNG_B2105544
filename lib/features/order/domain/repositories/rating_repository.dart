import 'package:ecommerce_app/features/product/data/models/index.dart';

abstract class RatingRepository {
  /// Fetch all ratings for a specific product
  Future<List<ProductRatingModel>> fetchProductRatings(String productId);

  /// Submit a new product rating
  Future<ProductRatingModel> submitProductRating(ProductRatingModel rating);

  /// Fetch all ratings by a specific user
  Future<List<ProductRatingModel>> fetchUserRatings(String userId);

  /// Update an existing product rating
  Future<void> updateProductRating(ProductRatingModel rating);

  /// Delete a product rating
  Future<void> deleteProductRating(int ratingId);

  /// Check if a user can review a product
  Future<bool> canUserReviewProduct(
      String userId, int productId, int orderItemId);
}
