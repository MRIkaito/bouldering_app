import 'package:bouldering_app/model/bouldering_stats.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// ■ クラス
/// - 統計情報を取得するクラス
class StaticsReportViewModel {
  /// ■ メソッド
  /// - 指定した月のボル活した回数を取得する
  ///
  /// 引数
  /// - [userId] ユーザーID
  /// - [monthsAgo] 当月基準で何か月前のデータを取得するかを指定する
  /// * 当月のデータを取得する場合は0を指定する
  ///
  /// 戻り値
  /// 指定した月の活動した回数
  Future<int> fetchBoulActivityCounts(String userId, int monthsAgo) async {
    int boulActivityCounts = 0;
    const int requestId = 19;

    final url = Uri.parse(
            'https://us-central1-gcp-compute-engine-441303.cloudfunctions.net/getData')
        .replace(queryParameters: {
      'request_id': requestId.toString(),
      'user_id': userId.toString(),
      'months_ago': monthsAgo.toString(),
    });

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // レスポンスボディをJSONとしてデコードする
        final List<dynamic> boulActivityCountsList = jsonDecode(response.body);

        // 正常時は要素一つ分の値を取得することができる
        // 要素無しの場合、異常と判断し、エラー扱い
        if (boulActivityCountsList.isEmpty) {
          throw Exception("ボル活回数データが空です");
        }

        // データは一つのみなので、[0]でデータ取得
        final Map<String, dynamic> boulActivityCountsMap =
            boulActivityCountsList[0];

        // 回数(total_visits)を取得
        boulActivityCounts = boulActivityCountsMap['total_visits'];
        print("boulActivityCounts: $boulActivityCounts");
      } else {
        throw Exception("Failed to fetch data");
      }
    } catch (error) {
      throw Exception("更新に失敗しました: ${error}");
    }

    return boulActivityCounts;
  }

  /// ■ メソッド
  /// - 指定した月の訪問したボルダリング施設を取得する
  ///
  /// 引数
  /// - [userId] ユーザーID
  /// - [monthsAgo] 当月基準で何か月前のデータを取得するかを指定する
  /// * 当月のデータを取得する場合は0を指定する
  ///
  /// 戻り値
  /// 指定した月の訪問したボルダリング施設数
  Future<int> fetchVisitedBoulGymCounts(String userId, int monthsAgo) async {
    int visitedBoulGymCounts = 0;
    const int requestId = 20;

    final url = Uri.parse(
            'https://us-central1-gcp-compute-engine-441303.cloudfunctions.net/getData')
        .replace(queryParameters: {
      'request_id': requestId.toString(),
      'user_id': userId.toString(),
      'months_ago': monthsAgo.toString(),
    });

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // レスポンスボディをJSONとしてデコードする
        final List<dynamic> visitedBoulGymCountsList =
            jsonDecode(response.body);

        // 正常時は要素一つ文の値を取得することができる
        // 要素なしの場合，異常ケースと判断し，Error処理
        if (visitedBoulGymCountsList.isEmpty) {
          throw Exception("訪問施設数データがからです");
        }

        // データは一つのみなので，[0]でデータ取得
        final Map<String, dynamic> visitedBoulGymCountsMap =
            visitedBoulGymCountsList[0];

        // 施設数(total_gym_count)を取得
        visitedBoulGymCounts = visitedBoulGymCountsMap['total_gym_count'];
      } else {
        throw Exception("Failed to fetch data");
      }
    } catch (error) {
      throw Exception("更新に失敗しました: ${error}");
    }

    return visitedBoulGymCounts;
  }

  /// ■ メソッド
  /// - 指定した月の，週あたりのボルダリング活動した回数を取得する
  ///
  /// 引数
  /// - [userId] ユーザーID
  /// - [monthsAgo] 当月基準で何か月前のデータを取得するかを指定する
  /// * 当月のデータを取得する場合は0を指定する
  ///
  /// 戻り値
  /// 指定した月の週あたりのボルダリング活動の回数
  Future<int> fetchBoulCountsPerWeek(String userId, int monthsAgo) async {
    int boulCountsPerWeek = 0;
    const int requestId = 21;

    final url = Uri.parse(
            'https://us-central1-gcp-compute-engine-441303.cloudfunctions.net/getData')
        .replace(queryParameters: {
      'request_id': requestId.toString(),
      'user_id': userId.toString(),
      'months_ago': monthsAgo.toString(),
    });

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // レスポンスボディをJSONとしてデコードする
        final List<dynamic> boulCountsPerWeekList = jsonDecode(response.body);

        // 正常時は要素一つ文の値を取得することができる
        // 要素なしの場合，異常ケースと判断し，Error処理
        if (boulCountsPerWeekList.isEmpty) {
          throw Exception("訪問施設数データがからです");
        }

        // データは一つのみなので，[0]でデータ取得
        final Map<String, dynamic> boulCountsPerWeekMap =
            boulCountsPerWeekList[0];

        // 施設数(total_gym_count)を取得
        boulCountsPerWeek = boulCountsPerWeekMap['weekly_visit_rate'];
      } else {
        throw Exception("Failed to fetch data");
      }
    } catch (error) {
      throw Exception("更新に失敗しました: ${error}");
    }

    return boulCountsPerWeek;
  }

  /// ■ メソッド
  /// - 指定した月の「ボル活回数」「訪問ジム数」「週当たりボル活回数」を取得する
  ///
  /// 引数
  /// - [userId] ユーザーID
  /// - [monthsAgo] 当月基準で何か月前のデータを取得するかを指定する
  /// * 当月のデータを取得する場合は0を指定する
  ///
  /// 戻り値
  /// 指定した月の「ボル活回数」「訪問ジム数」「週当たりボル活回数」
  Future<BoulderingStats> fetchBoulActivityStats(
      String userId, int monthsAgo) async {
    const int requestId = 22;

    print("【deubg】送信する userId: $userId, monthsAgo: $monthsAgo ");

    final url = Uri.parse(
            'https://us-central1-gcp-compute-engine-441303.cloudfunctions.net/getData')
        .replace(queryParameters: {
      'request_id': requestId.toString(),
      'user_id': userId,
      'months_ago': monthsAgo.toString(),
    });

    try {
      final response = await http.get(url);
      print("【Debug】response.statusCode: ${response.statusCode}");
      print("【Debug】response.body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> boulActivityDataMap =
            jsonDecode(response.body);
        print("エラー確認1");
        return BoulderingStats.fromJson(boulActivityDataMap);
      } else {
        throw Exception("データ取得に失敗しました (Status Code: ${response.statusCode})");
      }
    } catch (error) {
      print("更新に失敗しました: ${error.toString()}");
      throw Exception("更新に失敗しました: ${error.toString()}");
    }
  }
}

/// 統計データを取得する FutureProvider
final boulActivityStatsProvider =
    FutureProvider.family<BoulderingStats, ({String userId, int monthsAgo})>(
        (ref, params) async {
  return StaticsReportViewModel()
      .fetchBoulActivityStats(params.userId, params.monthsAgo);
});
