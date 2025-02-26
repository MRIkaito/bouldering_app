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
    );
  }
}


/* View部分の実装メモ

FutureBuilder<BoulderingStats>(
  future: StaticsReportViewModel().fetchBoulActivityStats(userId, 0),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator();
    }
    if (snapshot.hasError) {
      return Text("エラー: ${snapshot.error}");
    }
    if (!snapshot.hasData) {
      return Text("データがありません");
    }

    final stats = snapshot.data!;
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("今月のボル活 - 2024.9 -", style: TextStyle(color: Colors.white, fontSize: 18)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(children: [Text("${stats.totalVisits} 回")]),
              Column(children: [Text("${stats.totalGymCount} 施設")]),
              Column(children: [Text("${stats.weeklyVisitRate} 回/週")]),
            ],
          ),
          Divider(color: Colors.white),
          Text("TOP5", style: TextStyle(color: Colors.white, fontSize: 16)),
          for (var gym in stats.topGyms)
            Text("${gym['gym_name']}  ${gym['visit_count']}回", style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  },
)

*/
