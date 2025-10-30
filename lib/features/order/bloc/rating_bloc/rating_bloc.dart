import 'package:ecommerce_app/features/order/bloc/rating_bloc/rating_event.dart';
import 'package:ecommerce_app/features/order/bloc/rating_bloc/rating_state.dart';
import 'package:ecommerce_app/features/order/data/repositories/rating_repository_impl.dart';
import 'package:ecommerce_app/features/order/domain/repositories/rating_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RatingBloc extends Bloc<RatingEvent, RatingState> {
  final RatingRepository repository;

  RatingBloc({required this.repository}) : super(RatingInitial()) {
    on<FetchProductRatings>(_onFetchProductRatings);
    on<FetchUserRatings>(_onFetchUserRatings);
    on<CheckReviewEligibility>(_onCheckReviewEligibility);
    on<SubmitRating>(_onSubmitRating);
    on<UpdateRating>(_onUpdateRating);
    on<DeleteRating>(_onDeleteRating);
    on<UploadRatingImages>(_onUploadRatingImages);
  }

  Future<void> _onFetchProductRatings(
    FetchProductRatings event,
    Emitter<RatingState> emit,
  ) async {
    try {
      emit(RatingLoading());
      final ratings = await repository.fetchProductRatings(event.productId);
      emit(ProductRatingsLoaded(
        ratings: ratings,
        productId: event.productId,
      ));
    } catch (e) {
      emit(RatingError(
        message: 'Failed to fetch product ratings: ${e.toString()}',
        errorCode: 'FETCH_PRODUCT_RATINGS_ERROR',
      ));
    }
  }

  Future<void> _onFetchUserRatings(
    FetchUserRatings event,
    Emitter<RatingState> emit,
  ) async {
    try {
      emit(RatingLoading());
      final ratings = await repository.fetchUserRatings(event.userId);
      emit(UserRatingsLoaded(
        ratings: ratings,
        userId: event.userId,
      ));
    } catch (e) {
      emit(RatingError(
        message: 'Failed to fetch user ratings: ${e.toString()}',
        errorCode: 'FETCH_USER_RATINGS_ERROR',
      ));
    }
  }

  Future<void> _onCheckReviewEligibility(
    CheckReviewEligibility event,
    Emitter<RatingState> emit,
  ) async {
    try {
      emit(RatingLoading());
      final canReview = await repository.canUserReviewProduct(
        event.userId,
        event.productId,
        event.orderItemId,
      );

      if (canReview) {
        emit(const ReviewEligibilityChecked(
          canReview: true,
          message: 'You can review this product',
        ));
      } else {
        emit(const ReviewEligibilityChecked(
          canReview: false,
          message:
              'You are not eligible to review this product or have already reviewed it',
        ));
      }
    } catch (e) {
      emit(RatingError(
        message: 'Failed to check review eligibility: ${e.toString()}',
        errorCode: 'CHECK_ELIGIBILITY_ERROR',
      ));
    }
  }

  Future<void> _onSubmitRating(
    SubmitRating event,
    Emitter<RatingState> emit,
  ) async {
    try {
      emit(RatingLoading());

      // Upload images if provided
      List<String>? imageUrls;
      if (event.images != null && event.images!.isNotEmpty) {
        emit(RatingUploadingImages(
          current: 0,
          total: event.images!.length,
        ));

        imageUrls = await (repository as RatingRepositoryImpl)
            .uploadRatingImages(event.images!);

        emit(RatingUploadingImages(
          current: event.images!.length,
          total: event.images!.length,
        ));
      }

      // Create rating with uploaded image URLs
      final ratingToSubmit = event.rating.copyWith(
        images: imageUrls,
        createdAt: DateTime.now().toIso8601String(),
      );

      final submittedRating =
          await repository.submitProductRating(ratingToSubmit);

      emit(RatingSubmitted(submittedRating));
    } catch (e) {
      emit(RatingError(
        message: 'Failed to submit rating: ${e.toString()}',
        errorCode: 'SUBMIT_RATING_ERROR',
      ));
    }
  }

  Future<void> _onUpdateRating(
    UpdateRating event,
    Emitter<RatingState> emit,
  ) async {
    try {
      emit(RatingLoading());

      // Upload new images if provided
      List<String> updatedImageUrls = List.from(event.rating.images ?? []);

      if (event.newImages != null && event.newImages!.isNotEmpty) {
        emit(RatingUploadingImages(
          current: 0,
          total: event.newImages!.length,
        ));

        final newImageUrls = await (repository as RatingRepositoryImpl)
            .uploadRatingImages(event.newImages!);
        updatedImageUrls.addAll(newImageUrls);

        emit(RatingUploadingImages(
          current: event.newImages!.length,
          total: event.newImages!.length,
        ));
      }

      // Update rating with new image URLs
      final ratingToUpdate = event.rating.copyWith(
        images: updatedImageUrls,
        updatedAt: DateTime.now().toIso8601String(),
      );

      await repository.updateProductRating(ratingToUpdate);

      emit(RatingUpdated(ratingToUpdate));
    } catch (e) {
      emit(RatingError(
        message: 'Failed to update rating: ${e.toString()}',
        errorCode: 'UPDATE_RATING_ERROR',
      ));
    }
  }

  Future<void> _onDeleteRating(
    DeleteRating event,
    Emitter<RatingState> emit,
  ) async {
    try {
      emit(RatingLoading());
      await repository.deleteProductRating(event.ratingId);
      emit(RatingDeleted(event.ratingId));
    } catch (e) {
      emit(RatingError(
        message: 'Failed to delete rating: ${e.toString()}',
        errorCode: 'DELETE_RATING_ERROR',
      ));
    }
  }

  Future<void> _onUploadRatingImages(
    UploadRatingImages event,
    Emitter<RatingState> emit,
  ) async {
    try {
      emit(RatingUploadingImages(
        current: 0,
        total: event.images.length,
      ));

      final imageUrls = await (repository as RatingRepositoryImpl)
          .uploadRatingImages(event.images);

      emit(RatingUploadingImages(
        current: event.images.length,
        total: event.images.length,
      ));

      emit(RatingImagesUploaded(imageUrls));
    } catch (e) {
      emit(RatingError(
        message: 'Failed to upload images: ${e.toString()}',
        errorCode: 'UPLOAD_IMAGES_ERROR',
      ));
    }
  }
}
