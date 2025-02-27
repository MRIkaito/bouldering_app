import 'package:bouldering_app/model/bouldering_stats.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ■ クラス
/// 統計情報を表示するクラス
/// 必須)「何年何月」「ボル活回数」「施設数」「週当たりボル活回数」「1～5位までの施設名・訪問回数」をもらう必要がある
/// 任意)「背景色」は前月のみもらう
class StaticsReport extends ConsumerWidget {
  const StaticsReport({
    super.key,
    required this.date,
    required this.boulActivityCounts,
    required this.boulGymCounts,
    required this.boulActivityCountsPerWeek,
    required this.top5GymStats,
    this.backgroundColor = 0xFF0056FF,
  });
  final DateTime date;
  final int boulActivityCounts;
  final int boulGymCounts;
  final int boulActivityCountsPerWeek;
  final BoulderingStats top5GymStats;
  final int backgroundColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 344,
      height: 328,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: Color(backgroundColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '今月のボル活 - ${}.${} -', // TODO：値もらう
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.50,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatsItem('ボル活', boulActivityCounts.toString(), '回'), // TODO：値もらう
              _buildStatsItem('施設数',  boulGymCounts.toString(), '施設'), // TODO：値もらう
              _buildStatsItem('ペース', boulActivityCountsPerWeek.toString(), '週あたり回数'), // TODO：値もらう
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
          Expanded(
            child: ListView(
              physics: const NeverScrollableScrollPhysics(), // スクロール表示をオフ
              children: [
                _buildTop5Item('フォークボルダリングジム', '1 回'), // TODO：値もらう
                _buildTop5Item('フォークボルダリングジム', '- 回'), // TODO： 値もらう
                _buildTop5Item('フォークボルダリングジム', '- 回'), // TODO： 値もらう
                _buildTop5Item('フォークボルダリングジム', '- 回'), // TODO： 値もらう
                _buildTop5Item('フォークボルダリングジム', '- 回'), // TODO： 値もらう
              ],
            ),
          ),
        ],
      ),
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
