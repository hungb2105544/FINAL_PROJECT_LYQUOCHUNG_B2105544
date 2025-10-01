import 'package:ecommerce_app/features/rank/data/model/point_history_model.dart';
import 'package:ecommerce_app/features/rank/data/model/rank_model.dart';
import 'package:ecommerce_app/features/rank/data/model/user_rank_model.dart';
import 'package:ecommerce_app/features/rank/domain/repositories/rank_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserRankRepositoryImpl implements UserRankRepository {
  SupabaseClient _supabase;

  UserRankRepositoryImpl(this._supabase);

  @override
  Future<UserRankModel?> getUserRank(String userId) async {
    try {
      final response = await _supabase.from('user_ranks').select('''
            *,
            rank_level:rank_levels(*)
          ''').eq('user_id', userId).maybeSingle();

      if (response == null) return null;
      return UserRankModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get user rank: $e');
    }
  }

  @override
  Future<UserRankWithProgression?> getUserRankWithProgression(
      String userId) async {
    try {
      final userRank = await getUserRank(userId);
      if (userRank == null || userRank.rankLevel == null) return null;
      final rankLevels = await getAllRankLevels();
      RankLevelModel? nextRank;
      for (var rank in rankLevels) {
        if (rank.minPoints > userRank.currentPoints) {
          nextRank = rank;
          break;
        }
      }

      return UserRankWithProgression.calculate(
        userRank: userRank,
        currentRank: userRank.rankLevel!,
        nextRank: nextRank,
      );
    } catch (e) {
      throw Exception('Failed to get user rank with progression: $e');
    }
  }

  @override
  Future<UserRankModel> createUserRank(String userId) async {
    try {
      final lowestRank = await _supabase
          .from('rank_levels')
          .select()
          .order('min_points', ascending: true)
          .limit(1)
          .single();

      final data = {
        'user_id': userId,
        'rank_level_id': lowestRank['id'],
        'current_points': 0,
        'lifetime_points': 0,
      };

      final response =
          await _supabase.from('user_ranks').insert(data).select('''
            *,
            rank_level:rank_levels(*)
          ''').single();

      return UserRankModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create user rank: $e');
    }
  }

  @override
  Future<UserRankModel> updatePoints(String userId, int pointsChange) async {
    try {
      if (pointsChange > 0) {
        return await addPoints(
          userId,
          pointsChange,
          reason: 'Points earned',
        );
      } else if (pointsChange < 0) {
        return await deductPoints(
          userId,
          pointsChange.abs(),
          reason: 'Points deducted',
        );
      }

      final currentRank = await getUserRank(userId);
      if (currentRank == null) {
        throw Exception('User rank not found');
      }
      return currentRank;
    } catch (e) {
      throw Exception('Failed to update points: $e');
    }
  }

  @override
  Future<UserRankModel> setPoints(
      String userId, int currentPoints, int lifetimePoints) async {
    try {
      final newRankLevel = await getRankLevelByPoints(currentPoints);
      if (newRankLevel == null) {
        throw Exception('No suitable rank level found');
      }
      final response = await _supabase
          .from('user_ranks')
          .update({
            'current_points': currentPoints,
            'lifetime_points': lifetimePoints,
            'rank_level_id': newRankLevel.id,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId)
          .select('''
            *,
            rank_level:rank_levels(*)
          ''')
          .single();

      return UserRankModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to set points: $e');
    }
  }

  @override
  Future<List<RankLevelModel>> getAllRankLevels() async {
    try {
      final response = await _supabase
          .from('rank_levels')
          .select()
          .order('min_points', ascending: true);

      return (response as List)
          .map((json) => RankLevelModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get rank levels: $e');
    }
  }

  @override
  Future<RankLevelModel?> getRankLevelByPoints(int points) async {
    try {
      final rankLevels = await _supabase
          .from('rank_levels')
          .select()
          .order('min_points', ascending: false);
      for (var rankJson in rankLevels) {
        final rank = RankLevelModel.fromJson(rankJson);
        if (points >= rank.minPoints) {
          if (rank.maxPoints == null || points <= rank.maxPoints!) {
            return rank;
          }
        }
      }
      if (rankLevels.isNotEmpty) {
        return RankLevelModel.fromJson(rankLevels.last);
      }

      return null;
    } catch (e) {
      throw Exception('Failed to get rank level by points: $e');
    }
  }

  @override
  Future<List<UserRankModel>> getTopUsersByRank({int limit = 10}) async {
    try {
      final response = await _supabase.from('user_ranks').select('''
            *,
            rank_level:rank_levels(*)
          ''').order('current_points', ascending: false).limit(limit);

      return (response as List)
          .map((json) => UserRankModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get top users: $e');
    }
  }

  @override
  Future<List<PointHistoryModel>> getPointHistory(String userId,
      {int limit = 20}) async {
    try {
      final response = await _supabase
          .from('point_history')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => PointHistoryModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get point history: $e');
    }
  }

  Future<UserRankModel> addPoints(
    String userId,
    int points, {
    String? reason,
    int? referenceId,
    String? referenceType,
  }) async {
    if (points <= 0) {
      throw ArgumentError('Points must be positive');
    }

    try {
      await _supabase.rpc('add_user_points', params: {
        'user_uuid': userId,
        'points_to_add': points,
        'reason': reason ?? 'Points earned',
        'reference_id': referenceId,
        'reference_type': referenceType,
      });

      final updatedRank = await getUserRank(userId);
      if (updatedRank == null) {
        throw Exception('Failed to get updated user rank');
      }

      return updatedRank;
    } catch (e) {
      throw Exception('Failed to add points: $e');
    }
  }

  Future<UserRankModel> deductPoints(
    String userId,
    int points, {
    String? reason,
    int? referenceId,
    String? referenceType,
  }) async {
    if (points <= 0) {
      throw ArgumentError('Points must be positive');
    }

    try {
      final currentRank = await getUserRank(userId);
      if (currentRank == null) {
        throw Exception('User rank not found');
      }

      final newCurrentPoints = (currentRank.currentPoints - points)
          .clamp(0, double.infinity)
          .toInt();

      final newRankLevel = await getRankLevelByPoints(newCurrentPoints);
      if (newRankLevel == null) {
        throw Exception('No suitable rank level found');
      }

      final response = await _supabase
          .from('user_ranks')
          .update({
            'current_points': newCurrentPoints,
            'rank_level_id': newRankLevel.id,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId)
          .select('''
            *,
            rank_level:rank_levels(*)
          ''')
          .single();

      await _supabase.from('point_history').insert({
        'user_id': userId,
        'points': -points,
        'reason': reason ?? 'Points deducted',
        'reference_id': referenceId,
        'reference_type': referenceType,
      });

      return UserRankModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to deduct points: $e');
    }
  }

  @override
  Future<UserRankModel> refundOrderPoints(
    String userId,
    int orderId,
  ) async {
    try {
      print("=== REFUND ORDER POINTS ===");
      print("User ID: $userId");
      print("Order ID: $orderId");

      final pointsRecord = await _supabase
          .from('point_history')
          .select('id, points, created_at')
          .eq('user_id', userId)
          .eq('reference_id', orderId)
          .eq('reference_type', 'order')
          .gt('points', 0)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      print("Points record: $pointsRecord");

      if (pointsRecord == null) {
        print("⚠️ No points awarded for this order. Skipping refund.");

        final currentRank = await getUserRank(userId);
        if (currentRank == null) {
          throw Exception('User rank not found');
        }
        return currentRank;
      }

      final pointsToRefund = pointsRecord['points'] as int;
      print("✓ Found $pointsToRefund points to refund");

      final refundRecord = await _supabase
          .from('point_history')
          .select('id')
          .eq('user_id', userId)
          .eq('reference_id', orderId)
          .eq('reference_type', 'order_cancelled')
          .maybeSingle();

      if (refundRecord != null) {
        print("⚠️ Points already refunded for this order");
        throw Exception('Points have already been refunded for this order');
      }

      final userRank = await _supabase
          .from('user_ranks')
          .select('id, current_points, lifetime_points')
          .eq('user_id', userId)
          .single();

      print("Current user rank: $userRank");

      final currentPoints = userRank['current_points'] as int;
      final lifetimePoints = userRank['lifetime_points'] as int;

      final newCurrentPoints =
          (currentPoints - pointsToRefund).clamp(0, double.infinity).toInt();
      final newLifetimePoints =
          (lifetimePoints - pointsToRefund).clamp(0, double.infinity).toInt();

      print("Updating points: $currentPoints -> $newCurrentPoints");
      print("Updating lifetime: $lifetimePoints -> $newLifetimePoints");

      final rankLevels = await _supabase
          .from('rank_levels')
          .select('id, min_points, max_points')
          .order('min_points', ascending: true);

      int? newRankLevelId;
      for (final level in rankLevels) {
        final minPoints = level['min_points'] as int;
        final maxPoints = level['max_points'] as int?;

        if (newCurrentPoints >= minPoints &&
            (maxPoints == null || newCurrentPoints <= maxPoints)) {
          newRankLevelId = level['id'] as int;
          break;
        }
      }

      print("New rank level ID: $newRankLevelId");

      await _supabase.from('point_history').insert({
        'user_id': userId,
        'points': -pointsToRefund,
        'reason': 'Order cancelled - Points refunded',
        'reference_id': orderId,
        'reference_type': 'order_cancelled',
      });

      print("✓ Point history record created");

      await _supabase.from('user_ranks').update({
        'current_points': newCurrentPoints,
        'lifetime_points': newLifetimePoints,
        'rank_level_id': newRankLevelId,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('user_id', userId);

      print("✓ User rank updated");

      final updatedRank = await getUserRank(userId);
      if (updatedRank == null) {
        throw Exception('Failed to get updated user rank after refund');
      }

      print("✓ Updated rank retrieved");
      print("New points: ${updatedRank.currentPoints}");
      return updatedRank;
    } on PostgrestException catch (e) {
      print('❌ PostgrestException: ${e.message}');
      print('Code: ${e.code}');
      print('Details: ${e.details}');

      if (e.message.contains('duplicate key') ||
          e.message.contains('unique constraint')) {
        throw Exception('Points have already been refunded for this order');
      }

      throw Exception('Failed to refund order points: ${e.message}');
    } catch (e) {
      print('❌ Error: $e');
      rethrow;
    }
  }

  Future<bool> hasEnoughPoints(String userId, int requiredPoints) async {
    final userRank = await getUserRank(userId);
    return userRank != null && userRank.currentPoints >= requiredPoints;
  }

  @override
  Future<UserRankModel> addPointsFromOrder(
    String userId,
    int orderId,
    int points,
  ) async {
    return await addPoints(
      userId,
      points,
      reason: 'Điểm thưởng từ đơn hàng #$orderId',
      referenceId: orderId,
      referenceType: 'order',
    );
  }

  @override
  Future<UserRankModel> addPointsFromReview(
    String userId,
    int reviewId,
    int points,
  ) async {
    return await addPoints(
      userId,
      points,
      reason: 'Điểm thưởng từ đánh giá sản phẩm',
      referenceId: reviewId,
      referenceType: 'review',
    );
  }

  Future<UserRankModel> addPointsFromReferral(
    String userId,
    String referredUserId,
    int points,
  ) async {
    return await addPoints(
      userId,
      points,
      reason: 'Điểm thưởng giới thiệu bạn bè',
      referenceType: 'referral',
    );
  }
}
