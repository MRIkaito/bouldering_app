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
      totalVisits: json['total_visits'] ?? 0,
      totalGymCount: json['total_gym_count'] ?? 0,
      weeklyVisitRate: (json['weekly_visit_rate'] ?? 0).toDouble(),
      topGyms: List<Map<String, dynamic>>.from(json['top_gyms']),
      // json['top_gyms']の型を明示的に、dynamicから、List<Map<String, dynamic>>に変換
      // 型の不整合を防ぎ、安全性を確保
    );
  }
}
