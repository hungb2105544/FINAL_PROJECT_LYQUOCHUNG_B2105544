import 'package:ecommerce_app/features/rank/bloc/rank_event.dart';
import 'package:ecommerce_app/features/rank/bloc/rank_state.dart';
import 'package:ecommerce_app/features/rank/domain/repositories/rank_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserRankBloc extends Bloc<UserRankEvent, UserRankState> {
  final UserRankRepository _repository;

  UserRankBloc(this._repository) : super(UserRankInitial()) {
    on<LoadUserRank>(_onLoadUserRank);
    on<LoadUserRankWithProgression>(_onLoadUserRankWithProgression);
    on<CreateUserRank>(_onCreateUserRank);
    on<UpdateUserPoints>(_onUpdateUserPoints);
    on<SetUserPoints>(_onSetUserPoints);
    on<LoadAllRankLevels>(_onLoadAllRankLevels);
    on<LoadTopUsersByRank>(_onLoadTopUsersByRank);
    on<LoadPointHistory>(_onLoadPointHistory);
    on<AddPointsFromOrder>(_onAddPointsFromOrder);
    on<AddPointsFromReview>(_onAddPointsFromReview);
    on<RefundOrderPoints>(_onRefundOrderPoints);
  }

  Future<void> _onLoadUserRank(
    LoadUserRank event,
    Emitter<UserRankState> emit,
  ) async {
    emit(UserRankLoading());
    try {
      final userRank = await _repository.getUserRank(event.userId);
      if (userRank != null) {
        emit(UserRankLoaded(userRank));
      } else {
        emit(const UserRankError('User rank not found'));
      }
    } catch (e) {
      emit(UserRankError(e.toString()));
    }
  }

  Future<void> _onLoadUserRankWithProgression(
    LoadUserRankWithProgression event,
    Emitter<UserRankState> emit,
  ) async {
    emit(UserRankLoading());
    try {
      final userRankProgression =
          await _repository.getUserRankWithProgression(event.userId);
      if (userRankProgression != null) {
        emit(UserRankWithProgressionLoaded(userRankProgression));
      } else {
        emit(const UserRankError('User rank progression not found'));
      }
    } catch (e) {
      emit(UserRankError(e.toString()));
    }
  }

  Future<void> _onCreateUserRank(
    CreateUserRank event,
    Emitter<UserRankState> emit,
  ) async {
    emit(UserRankLoading());
    try {
      final userRank = await _repository.createUserRank(event.userId);
      emit(
          UserRankOperationSuccess(userRank, 'User rank created successfully'));
    } catch (e) {
      emit(UserRankError(e.toString()));
    }
  }

  Future<void> _onUpdateUserPoints(
    UpdateUserPoints event,
    Emitter<UserRankState> emit,
  ) async {
    emit(UserRankLoading());
    try {
      final userRank =
          await _repository.updatePoints(event.userId, event.pointsChange);
      final message = event.pointsChange > 0
          ? 'Added ${event.pointsChange} points successfully'
          : 'Deducted ${event.pointsChange.abs()} points successfully';
      emit(UserRankOperationSuccess(userRank, message));
    } catch (e) {
      emit(UserRankError(e.toString()));
    }
  }

  Future<void> _onSetUserPoints(
    SetUserPoints event,
    Emitter<UserRankState> emit,
  ) async {
    emit(UserRankLoading());
    try {
      final userRank = await _repository.setPoints(
        event.userId,
        event.currentPoints,
        event.lifetimePoints,
      );
      emit(UserRankOperationSuccess(userRank, 'Points set successfully'));
    } catch (e) {
      emit(UserRankError(e.toString()));
    }
  }

  Future<void> _onLoadAllRankLevels(
    LoadAllRankLevels event,
    Emitter<UserRankState> emit,
  ) async {
    emit(UserRankLoading());
    try {
      final rankLevels = await _repository.getAllRankLevels();
      emit(RankLevelsLoaded(rankLevels));
    } catch (e) {
      emit(UserRankError(e.toString()));
    }
  }

  Future<void> _onLoadTopUsersByRank(
    LoadTopUsersByRank event,
    Emitter<UserRankState> emit,
  ) async {
    emit(UserRankLoading());
    try {
      final topUsers = await _repository.getTopUsersByRank(limit: event.limit);
      emit(TopUsersLoaded(topUsers));
    } catch (e) {
      emit(UserRankError(e.toString()));
    }
  }

  Future<void> _onLoadPointHistory(
    LoadPointHistory event,
    Emitter<UserRankState> emit,
  ) async {
    emit(UserRankLoading());
    try {
      final pointHistory =
          await _repository.getPointHistory(event.userId, limit: event.limit);
      emit(PointHistoryLoaded(pointHistory));
    } catch (e) {
      emit(UserRankError(e.toString()));
    }
  }

  Future<void> _onAddPointsFromOrder(
    AddPointsFromOrder event,
    Emitter<UserRankState> emit,
  ) async {
    emit(UserRankLoading());
    try {
      final userRank = await _repository.addPointsFromOrder(
        event.userId,
        event.orderId,
        event.points,
      );
      emit(UserRankOperationSuccess(
        userRank,
        'Added ${event.points} points from order #${event.orderId}',
      ));
    } catch (e) {
      emit(UserRankError(e.toString()));
    }
  }

  Future<void> _onAddPointsFromReview(
    AddPointsFromReview event,
    Emitter<UserRankState> emit,
  ) async {
    emit(UserRankLoading());
    try {
      final userRank = await _repository.addPointsFromReview(
        event.userId,
        event.reviewId,
        event.points,
      );
      emit(UserRankOperationSuccess(
        userRank,
        'Added ${event.points} points from review',
      ));
    } catch (e) {
      emit(UserRankError(e.toString()));
    }
  }

  Future<void> _onRefundOrderPoints(
    RefundOrderPoints event,
    Emitter<UserRankState> emit,
  ) async {
    emit(UserRankLoading());
    try {
      print(
          "debug from repository $event.userId - ${event.userId.runtimeType},$event.orderId - ${event.orderId.runtimeType}");
      final userRank = await _repository.refundOrderPoints(
        event.userId,
        event.orderId,
      );
      emit(UserRankOperationSuccess(
        userRank,
        'Refunded points from order #${event.orderId}',
      ));
    } catch (e) {
      emit(UserRankError(e.toString()));
    }
  }
}
