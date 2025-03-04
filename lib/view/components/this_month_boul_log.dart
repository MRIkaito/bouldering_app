import 'package:bouldering_app/view_model/statics_report_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ThisMonthBoulLog extends ConsumerWidget {
  final String? userId;
  final int monthsAgo;
  const ThisMonthBoulLog(
      {super.key, required this.userId, required this.monthsAgo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // userIdがnullの場合，ローディングを表示
    if (userId == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final asyncBoulActivityStats = ref.watch(
        boulActivityStatsProvider((userId: userId!, monthsAgo: monthsAgo)));

    return asyncBoulActivityStats.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          children: [
            const Text("エラーが発生しました"),
            Text(error.toString()),
          ],
        ),
      ),
      data: (boulActivityStats) {
        return Center(
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(16),
            decoration: ShapeDecoration(
              color: const Color(0xFF0056FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '今月のボル活',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.50,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        context.push('/StaticsReport/$userId');
                      },
                      child: const Text(
                        '統計レポート >',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.50,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatsItem(
                        'ボル活', boulActivityStats.totalVisits.toString(), '回'),
                    _buildStatsItem('施設数',
                        boulActivityStats.totalGymCount.toString(), '施設'),
                    _buildStatsItem('ペース',
                        boulActivityStats.weeklyVisitRate.toString(), '回 / 週'),
                  ],
                ),
              ],
            ),
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
            fontSize: 18,
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
                fontSize: 40,
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
                fontSize: 16,
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
}
