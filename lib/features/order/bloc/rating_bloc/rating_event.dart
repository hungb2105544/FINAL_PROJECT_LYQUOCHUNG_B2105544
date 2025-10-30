import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:ecommerce_app/features/product/data/models/product_rating_model.dart';

// Events
abstract class RatingEvent extends Equatable {
  const RatingEvent();

  @override
  List<Object?> get props => [];
}

class FetchProductRatings extends RatingEvent {
  final String productId;

  const FetchProductRatings(this.productId);

  @override
  List<Object?> get props => [productId];
}

class FetchUserRatings extends RatingEvent {
  final String userId;

  const FetchUserRatings(this.userId);

  @override
  List<Object?> get props => [userId];
}

class CheckReviewEligibility extends RatingEvent {
  final String userId;
  final int productId;
  final int orderItemId;

  const CheckReviewEligibility({
    required this.userId,
    required this.productId,
    required this.orderItemId,
  });

  @override
  List<Object?> get props => [userId, productId, orderItemId];
}

class SubmitRating extends RatingEvent {
  final ProductRatingModel rating;
  final List<File>? images;

  const SubmitRating({
    required this.rating,
    this.images,
  });

  @override
  List<Object?> get props => [rating, images];
}

class UpdateRating extends RatingEvent {
  final ProductRatingModel rating;
  final List<File>? newImages;

  const UpdateRating({
    required this.rating,
    this.newImages,
  });

  @override
  List<Object?> get props => [rating, newImages];
}

class DeleteRating extends RatingEvent {
  final int ratingId;

  const DeleteRating(this.ratingId);

  @override
  List<Object?> get props => [ratingId];
}

class UploadRatingImages extends RatingEvent {
  final List<File> images;

  const UploadRatingImages(this.images);

  @override
  List<Object?> get props => [images];
}
