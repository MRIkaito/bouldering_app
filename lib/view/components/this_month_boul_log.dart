import 'package:bouldering_app/view/pages/statics_report_page.dart';
import 'package:flutter/material.dart';

class ThisMonthBoulLog extends StatelessWidget {
  const ThisMonthBoulLog({super.key});

  @override
  Widget build(BuildContext context) {
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
                    // ページ繊維
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => StaticsReportPage()));
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
            const SizedBox(height: 12), // 縦の間隔を少し短く変更
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatsItem('ボル活', '2', '回'),
                _buildStatsItem('施設数', '2', '施設'),
                _buildStatsItem('ペース', '1', '回 / 週'),
              ],
            ),
          ],
        ),
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
