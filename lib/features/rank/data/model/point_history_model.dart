class PointHistoryModel {
  final int id;
  final String? userId;
  final int points;
  final String reason;
  final int? referenceId;
  final String? referenceType;
  final DateTime? createdAt;

  PointHistoryModel({
    required this.id,
    this.userId,
    required this.points,
    required this.reason,
    this.referenceId,
    this.referenceType,
    this.createdAt,
  });

  factory PointHistoryModel.fromJson(Map<String, dynamic> json) {
    return PointHistoryModel(
      id: json['id'] as int,
      userId: json['user_id'] as String?,
      points: json['points'] as int,
      reason: json['reason'] as String,
      referenceId: json['reference_id'] as int?,
      referenceType: json['reference_type'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'points': points,
      'reason': reason,
      'reference_id': referenceId,
      'reference_type': referenceType,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  bool get isPositive => points > 0;
  bool get isNegative => points < 0;
}
