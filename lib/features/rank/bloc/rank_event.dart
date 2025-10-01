import 'package:equatable/equatable.dart';

abstract class UserRankEvent extends Equatable {
  const UserRankEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserRank extends UserRankEvent {
  final String userId;

  const LoadUserRank(this.userId);

  @override
  List<Object?> get props => [userId];
}

class LoadUserRankWithProgression extends UserRankEvent {
  final String userId;

  const LoadUserRankWithProgression(this.userId);

  @override
  List<Object?> get props => [userId];
}

class CreateUserRank extends UserRankEvent {
  final String userId;

  const CreateUserRank(this.userId);

  @override
  List<Object?> get props => [userId];
}

class UpdateUserPoints extends UserRankEvent {
  final String userId;
  final int pointsChange;

  const UpdateUserPoints(this.userId, this.pointsChange);

  @override
  List<Object?> get props => [userId, pointsChange];
}

class SetUserPoints extends UserRankEvent {
  final String userId;
  final int currentPoints;
  final int lifetimePoints;

  const SetUserPoints(this.userId, this.currentPoints, this.lifetimePoints);

  @override
  List<Object?> get props => [userId, currentPoints, lifetimePoints];
}

class LoadAllRankLevels extends UserRankEvent {
  const LoadAllRankLevels();
}

class LoadTopUsersByRank extends UserRankEvent {
  final int limit;

  const LoadTopUsersByRank({this.limit = 10});

  @override
  List<Object?> get props => [limit];
}

class LoadPointHistory extends UserRankEvent {
  final String userId;
  final int limit;

  const LoadPointHistory(this.userId, {this.limit = 20});

  @override
  List<Object?> get props => [userId, limit];
}

class AddPointsFromOrder extends UserRankEvent {
  final String userId;
  final int orderId;
  final int points;

  const AddPointsFromOrder(this.userId, this.orderId, this.points);

  @override
  List<Object?> get props => [userId, orderId, points];
}

class AddPointsFromReview extends UserRankEvent {
  final String userId;
  final int reviewId;
  final int points;

  const AddPointsFromReview(this.userId, this.reviewId, this.points);

  @override
  List<Object?> get props => [userId, reviewId, points];
}

class RefundOrderPoints extends UserRankEvent {
  final String userId;
  final int orderId;

  const RefundOrderPoints(this.userId, this.orderId);

  @override
  List<Object?> get props => [userId, orderId];
}
