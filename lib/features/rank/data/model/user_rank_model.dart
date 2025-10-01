import 'package:ecommerce_app/features/rank/data/model/rank_model.dart';

class UserRankModel {
  final int id;
  final String? userId;
  final int? rankLevelId;
  final int currentPoints;
  final int lifetimePoints;
  final DateTime? updatedAt;

  // Enhanced: Thông tin rank level chi tiết
  final RankLevelModel? rankLevel;

  UserRankModel({
    required this.id,
    this.userId,
    this.rankLevelId,
    this.currentPoints = 0,
    this.lifetimePoints = 0,
    this.updatedAt,
    this.rankLevel,
  });

  /// Convert JSON -> Model (với rank level join)
  factory UserRankModel.fromJson(Map<String, dynamic> json) {
    return UserRankModel(
      id: json['id'] as int,
      userId: json['user_id'] as String?,
      rankLevelId: json['rank_level_id'] as int?,
      currentPoints: json['current_points'] as int? ?? 0,
      lifetimePoints: json['lifetime_points'] as int? ?? 0,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      // Join với rank_levels table
      rankLevel: json['rank_level'] != null
          ? RankLevelModel.fromJson(json['rank_level'])
          : null,
    );
  }

  /// Convert Model -> JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'rank_level_id': rankLevelId,
      'current_points': currentPoints,
      'lifetime_points': lifetimePoints,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// CopyWith cho immutable update
  UserRankModel copyWith({
    int? id,
    String? userId,
    int? rankLevelId,
    int? currentPoints,
    int? lifetimePoints,
    DateTime? updatedAt,
    RankLevelModel? rankLevel,
  }) {
    return UserRankModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      rankLevelId: rankLevelId ?? this.rankLevelId,
      currentPoints: currentPoints ?? this.currentPoints,
      lifetimePoints: lifetimePoints ?? this.lifetimePoints,
      updatedAt: updatedAt ?? this.updatedAt,
      rankLevel: rankLevel ?? this.rankLevel,
    );
  }

  @override
  String toString() {
    return 'UserRankModel(id: $id, userId: $userId, rankLevelId: $rankLevelId, '
        'currentPoints: $currentPoints, lifetimePoints: $lifetimePoints, '
        'rankLevel: ${rankLevel?.name}, updatedAt: $updatedAt)';
  }
}

class UserRankWithProgression {
  final UserRankModel userRank;
  final RankLevelModel currentRank;
  final RankLevelModel? nextRank;
  final int pointsToNextRank;
  final double progressPercentage;

  UserRankWithProgression({
    required this.userRank,
    required this.currentRank,
    this.nextRank,
    required this.pointsToNextRank,
    required this.progressPercentage,
  });

  factory UserRankWithProgression.calculate({
    required UserRankModel userRank,
    required RankLevelModel currentRank,
    RankLevelModel? nextRank,
  }) {
    int pointsToNext = 0;
    double progress = 0.0;

    if (nextRank != null) {
      pointsToNext = nextRank.minPoints - userRank.currentPoints;
      if (pointsToNext < 0) pointsToNext = 0;

      // Tính % tiến độ trong rank hiện tại
      int rangePoints = nextRank.minPoints - currentRank.minPoints;
      int earnedPoints = userRank.currentPoints - currentRank.minPoints;
      progress = rangePoints > 0 ? (earnedPoints / rangePoints * 100) : 100.0;
      progress = progress.clamp(0.0, 100.0);
    } else {
      // Đã đạt rank cao nhất
      progress = 100.0;
    }

    return UserRankWithProgression(
      userRank: userRank,
      currentRank: currentRank,
      nextRank: nextRank,
      pointsToNextRank: pointsToNext,
      progressPercentage: progress,
    );
  }

  bool get isMaxRank => nextRank == null;
}
