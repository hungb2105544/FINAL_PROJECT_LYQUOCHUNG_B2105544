import 'package:ecommerce_app/features/rank/data/model/point_history_model.dart';
import 'package:ecommerce_app/features/rank/data/model/rank_model.dart';
import 'package:ecommerce_app/features/rank/data/model/user_rank_model.dart';
import 'package:equatable/equatable.dart';

abstract class UserRankState extends Equatable {
  const UserRankState();

  @override
  List<Object?> get props => [];
}

class UserRankInitial extends UserRankState {}

class UserRankLoading extends UserRankState {}

class UserRankLoaded extends UserRankState {
  final UserRankModel userRank;

  const UserRankLoaded(this.userRank);

  @override
  List<Object?> get props => [userRank];
}

class UserRankWithProgressionLoaded extends UserRankState {
  final UserRankWithProgression userRankProgression;

  const UserRankWithProgressionLoaded(this.userRankProgression);

  @override
  List<Object?> get props => [userRankProgression];
}

class RankLevelsLoaded extends UserRankState {
  final List<RankLevelModel> rankLevels;

  const RankLevelsLoaded(this.rankLevels);

  @override
  List<Object?> get props => [rankLevels];
}

class TopUsersLoaded extends UserRankState {
  final List<UserRankModel> topUsers;

  const TopUsersLoaded(this.topUsers);

  @override
  List<Object?> get props => [topUsers];
}

class PointHistoryLoaded extends UserRankState {
  final List<PointHistoryModel> pointHistory;

  const PointHistoryLoaded(this.pointHistory);

  @override
  List<Object?> get props => [pointHistory];
}

class UserRankOperationSuccess extends UserRankState {
  final UserRankModel userRank;
  final String message;

  const UserRankOperationSuccess(this.userRank, this.message);

  @override
  List<Object?> get props => [userRank, message];
}

class UserRankError extends UserRankState {
  final String message;

  const UserRankError(this.message);

  @override
  List<Object?> get props => [message];
}
