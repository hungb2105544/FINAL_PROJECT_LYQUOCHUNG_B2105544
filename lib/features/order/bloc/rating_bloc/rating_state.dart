import 'package:ecommerce_app/features/product/data/models/product_rating_model.dart';
import 'package:equatable/equatable.dart';

abstract class RatingState extends Equatable {
  const RatingState();

  @override
  List<Object?> get props => [];
}

class RatingInitial extends RatingState {}

class RatingLoading extends RatingState {}

class RatingUploadingImages extends RatingState {
  final int current;
  final int total;

  const RatingUploadingImages({
    required this.current,
    required this.total,
  });

  @override
  List<Object?> get props => [current, total];
}

class ProductRatingsLoaded extends RatingState {
  final List<ProductRatingModel> ratings;
  final String productId;

  const ProductRatingsLoaded({
    required this.ratings,
    required this.productId,
  });

  @override
  List<Object?> get props => [ratings, productId];
}

class UserRatingsLoaded extends RatingState {
  final List<ProductRatingModel> ratings;
  final String userId;

  const UserRatingsLoaded({
    required this.ratings,
    required this.userId,
  });

  @override
  List<Object?> get props => [ratings, userId];
}

class ReviewEligibilityChecked extends RatingState {
  final bool canReview;
  final String message;

  const ReviewEligibilityChecked({
    required this.canReview,
    required this.message,
  });

  @override
  List<Object?> get props => [canReview, message];
}

class RatingSubmitted extends RatingState {
  final ProductRatingModel rating;

  const RatingSubmitted(this.rating);

  @override
  List<Object?> get props => [rating];
}

class RatingUpdated extends RatingState {
  final ProductRatingModel rating;

  const RatingUpdated(this.rating);

  @override
  List<Object?> get props => [rating];
}

class RatingDeleted extends RatingState {
  final int ratingId;

  const RatingDeleted(this.ratingId);

  @override
  List<Object?> get props => [ratingId];
}

class RatingImagesUploaded extends RatingState {
  final List<String> imageUrls;

  const RatingImagesUploaded(this.imageUrls);

  @override
  List<Object?> get props => [imageUrls];
}

class RatingError extends RatingState {
  final String message;
  final String? errorCode;

  const RatingError({
    required this.message,
    this.errorCode,
  });

  @override
  List<Object?> get props => [message, errorCode];
}
