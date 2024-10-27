import 'package:flutter/material.dart';

class StaticsReport extends StatelessWidget {
  // 何年, 何月, ボル活回数, 施設数, １から5位の施設名，1から5位の訪問回数
  // 背景色
  // 上記のパラメータをコンストラクタ引数に取るよう後で編集
  const StaticsReport({super.key, this.backgroundColor = 0xFF0056FF});
  final int backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 344,
      height: 328, // 見た目をバランスよく表示するために高さを調整しました
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
                '今月のボル活 - 2024.9 -',
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
              _buildStatsItem('ボル活', '2', '回'),
              _buildStatsItem('施設数', '2', '施設'),
              _buildStatsItem('ペース', '1', '週あたり回数'),
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
                _buildTop5Item('フォークボルダリングジム', '1 回'),
                _buildTop5Item('フォークボルダリングジム', '- 回'),
                _buildTop5Item('フォークボルダリングジム', '- 回'),
                _buildTop5Item('フォークボルダリングジム', '- 回'),
                _buildTop5Item('フォークボルダリングジム', '- 回'),
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
