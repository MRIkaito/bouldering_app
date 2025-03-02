class BoulderingStats {
  final int totalVisits;
  final int totalGymCount;
  final double weeklyVisitRate;
  final List<Map<String, dynamic>> topGyms;

  BoulderingStats({
    required this.totalVisits,
    required this.totalGymCount,
    required this.weeklyVisitRate,
    required this.topGyms,
  });

  factory BoulderingStats.fromJson(Map<String, dynamic> json) {
    return BoulderingStats(
      totalVisits: int.tryParse(json['total_visits']) ?? 0,
      totalGymCount: int.tryParse(json['total_gym_count']) ?? 0,
      weeklyVisitRate:
          double.tryParse(json['weekly_visit_rate'].toString()) ?? 0.0,
      topGyms: List<Map<String, dynamic>>.from(json['top_gyms']),
      // json['top_gyms']の型を明示的に、dynamicから、List<Map<String, dynamic>>に変換
      // 型の不整合を防ぎ、安全性を確保
    );
  }
}
