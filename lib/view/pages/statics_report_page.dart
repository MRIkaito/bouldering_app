import 'package:bouldering_app/model/bouldering_stats.dart';
import 'package:bouldering_app/view_model/statics_report_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class StaticsReportPage extends ConsumerWidget {
  const StaticsReportPage({super.key, required this.userId});
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncCurrentMonthStats =
        ref.watch(boulActivityStatsProvider((userId: userId, monthsAgo: 0)));
    final asyncPreviousMonthStats =
        ref.watch(boulActivityStatsProvider((userId: userId, monthsAgo: 1)));

    final now = DateTime.now();
    final previousMonth = DateTime(now.year, now.month - 1, 1);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFEF7FF),
        surfaceTintColor: const Color(0xFFFEF7FF),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              _buildStatsContainer(
                  context,
                  "今月のボル活 - ${now.year}.${now.month} -",
                  asyncCurrentMonthStats,
                  const Color(0xFF0056FF)),
              const SizedBox(height: 16),
              _buildStatsContainer(
                  context,
                  "昨月のボル活 - ${previousMonth.year}.${previousMonth.month} -",
                  asyncPreviousMonthStats,
                  const Color(0xFF8D8D8D)),
              const SizedBox(height: 24)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsContainer(BuildContext context, String title,
      AsyncValue<BoulderingStats> asyncStats, Color bgColor) {
    return asyncStats.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => const Center(child: Text("エラーが発生しました")),
      data: (boulActivityStats) {
        return Container(
          width: 344,
          padding: const EdgeInsets.all(16),
          decoration: ShapeDecoration(
            color: bgColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.50,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatsItem(
                      'ボル活', boulActivityStats.totalVisits.toString(), '回'),
                  _buildStatsItem(
                      '施設数', boulActivityStats.totalGymCount.toString(), '施設'),
                  _buildStatsItem('ペース',
                      boulActivityStats.weeklyVisitRate.toString(), '週あたり回数'),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(
                color: Colors.white,
                thickness: 1.0,
                indent: 0,
                endIndent: 0,
              ),
              const SizedBox(height: 8),
              const Text(
                'TOP5',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.50,
                ),
              ),
              const SizedBox(height: 4),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: boulActivityStats.topGyms.length,
                itemBuilder: (context, index) {
                  final gym = boulActivityStats.topGyms[index];
                  final gymId = gym['gym_id'].toString();
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              context
                                  .push('/FacilityInfo/$gymId'); // ジム詳細ページに遷移
                            },
                            child: Text(
                              gym['gym_name'],
                              softWrap: true,
                              overflow: TextOverflow.visible,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.50,
                              ),
                            ),
                          ),
                        ),
                        Text(
                          '${gym['visit_count']} 回',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.50,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsItem(String title, String value, String unit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w600,
            letterSpacing: -0.50,
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w600,
                letterSpacing: -0.50,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              unit,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w600,
                letterSpacing: -0.50,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTop5Item(String gymName, String count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            gymName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w600,
              letterSpacing: -0.50,
            ),
          ),
          Text(
            count,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w600,
              letterSpacing: -0.50,
            ),
          ),
        ],
      ),
    );
  }
}
