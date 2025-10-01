import 'package:ecommerce_app/features/rank/data/model/point_history_model.dart';
import 'package:ecommerce_app/features/rank/data/model/rank_model.dart';
import 'package:ecommerce_app/features/rank/data/model/user_rank_model.dart';

abstract class UserRankRepository {
  /// Lấy thông tin rank của user (có join rank_level)
  Future<UserRankModel?> getUserRank(String userId);

  /// Lấy thông tin rank với tiến độ
  Future<UserRankWithProgression?> getUserRankWithProgression(String userId);

  /// Tạo mới user rank (khi user đăng ký)
  Future<UserRankModel> createUserRank(String userId);

  /// Cập nhật điểm và rank level (tự động tính rank mới)
  Future<UserRankModel> updatePoints(String userId, int pointsChange);

  /// Set điểm cụ thể (admin)
  Future<UserRankModel> setPoints(
      String userId, int currentPoints, int lifetimePoints);

  /// Lấy danh sách tất cả rank levels (để tính toán)
  Future<List<RankLevelModel>> getAllRankLevels();

  /// Lấy rank level phù hợp với số điểm
  Future<RankLevelModel?> getRankLevelByPoints(int points);

  /// Lấy top users theo rank
  Future<List<UserRankModel>> getTopUsersByRank({int limit = 10});

  /// Lấy lịch sử điểm của user
  Future<List<PointHistoryModel>> getPointHistory(String userId,
      {int limit = 20});
  //Thêm điểm từ đơn hàng
  Future<UserRankModel> addPointsFromOrder(
    String userId,
    int orderId,
    int points,
  );
//Thêm điểm từ việc viết đánh giá
  Future<UserRankModel> addPointsFromReview(
    String userId,
    int reviewId,
    int points,
  );
  // Trả lại điêm khi hủy đơn hàng
  Future<UserRankModel> refundOrderPoints(
    String userId,
    int orderId,
  );
}
