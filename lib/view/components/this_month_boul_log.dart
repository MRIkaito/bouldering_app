import 'package:bouldering_app/view_model/statics_report_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// ■ クラス
/// - 「今月のボル活」情報を管理するクラス
class ThisMonthBoulLog extends ConsumerWidget {
  // ■ プロパティ
  final String? userId;
  final int monthsAgo;

  // ■ コンストラクタ
  const ThisMonthBoulLog({
    super.key,
    required this.userId,
    required this.monthsAgo,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // userIdがnullの場合，ローディングを表示
    if (userId == null) {
      return _buildContainer(context, '-', '-', '-',
          ref: ref); // ログイン直後など null 時も考慮
    }

    final asyncBoulActivityStats = ref.watch(
        boulActivityStatsProvider((userId: userId!, monthsAgo: monthsAgo)));

    return asyncBoulActivityStats.when(
      loading: () => _buildContainer(context, '-', '-', '-',
          ref: ref), // ← ローディング中は "-" 表示
      error: (error, stack) =>
          _buildContainer(context, '?', '?', '?', ref: ref),
      data: (data) {
        return _buildContainer(
          context,
          data.totalVisits.toString(),
          data.totalGymCount.toString(),
          data.weeklyVisitRate.toString(),
          ref: ref,
        );
      },
    );
  }

  /// ■ メソッド(Widget)
  /// - 今月のボル活を表示するウィジェット
  ///
  /// 引数
  /// [context] ページ遷移などに使うFlutterのビルドコンテキスト
  /// [visits] ボル活の回数．"-" の場合は未取得．”?”の場合はエラー．
  /// [gyms] 施設数．"-" の場合は未取得．"?"の場合はエラー．
  /// [pace] ペース（週あたり）．"-" の場合は未取得．"?"の場合はエラー
  /// [ref] Riverpodの状態管理オブジェクト（再取得ボタンに使用）
  Widget _buildContainer(
    BuildContext context,
    String visits,
    String gyms,
    String pace, {
    WidgetRef? ref,
  }) {
    return Center(
      child: Container(
        width: 400,
        padding: const EdgeInsets.fromLTRB(
            14, 0, 14, 8), // left: 14, top: 0, right: 14, bottom: 8
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
                Row(
                  children: [
                    // 今月のボル活 テキスト
                    const Text(
                      '今月のボル活',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.50,
                      ),
                    ),
                    // 統計情報更新ボタン
                    if (ref != null) // 統計情報更新ボタンはデータ取得していないと押下できないようにする
                      IconButton(
                        onPressed: () {
                          ref.invalidate(
                            boulActivityStatsProvider(
                                (userId: userId!, monthsAgo: monthsAgo)),
                          );
                        },
                        icon: const Icon(
                          Icons.refresh,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    if (userId != null) {
                      context.push('/StaticsReport/$userId');
                    }
                  },
                  child: const Text(
                    '統計レポート >',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.50,
                    ),
                  ),
                ),
              ],
            ),

            // ボル活・施設数・ペース 表記部分
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatsItem('ボル活', visits, '回'),
                _buildStatsItem('施設数', gyms, '施設'),
                _buildStatsItem('ペース', pace, '回 / 週'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// ■ メソッド(ウィジェット)
  /// - ボル活・施設数・(ボル活)ペースを表示するウィジェット
  ///
  /// 引数
  /// - [title] ボル活/施設数/ペース のいずれかの表題を示すもの
  /// - [value] 各表題の回数
  /// - [unit] 各表題の単位(ボル活：回, 施設数：施設, ペース：回/週)
  Widget _buildStatsItem(String title, String value, String unit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
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
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
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
                fontSize: 14,
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
