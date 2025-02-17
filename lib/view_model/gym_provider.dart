import 'package:bouldering_app/model/gym.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// ■ クラス
/// - アプリ起動時に、全ジムのジムID・ジム名・経度・緯度を取得して管理する
/// - Gymクラスを状態保持する
class GymNotifier extends StateNotifier<List<Gym>> {
  // コンストラクタ
  GymNotifier() : super([]);

  /// ■メソッド: fetchGymData
  /// - ジムのID・ジム名・経度・緯度を取得する
  ///
  /// 引数:
  /// なし
  Future<void> fetchGymData() async {
    // DBアクセス・データ取得
    int requestId = 13;

    final url = Uri.parse(
            'https://us-central1-gcp-compute-engine-441303.cloudfunctions.net/getData')
        .replace(queryParameters: {
      'request_id': requestId.toString(),
    });

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> gymLocation = jsonDecode(response.body);
        // response bodyをJSONでDecode
        // 出力例：
        // [
        //  {
        //    "gym_id":1,
        //    "gym_name": "RED POINT",
        //    "longitude": 23.4232,
        //    "longitude": 133.33244
        //  }
        // ]

        print("【Debug】レスポンスデータ(gymLocation):");
        print("$gymLocation");

        if (gymLocation.isEmpty) {
          throw Exception("ジムの情報を取得できませんでした");
        }

        // 状態(state)に代入する一時的な変数
        List<Gym> returnGymList = [];

        for (var gym in gymLocation) {
          if (gym['latitude'] == null || gym['longitude'] == null) {
            print("警告: 緯度・経度が null のデータをスキップしました: $gym");
            continue; // スキップ
          }
          returnGymList.add(Gym(
            gymId: (gym['gym_id'] as int?) ?? 0,
            gymName: (gym['gym_name'] as String?) ?? "ジム名なし",
            latitude: (gym['latitude'] is double)
                ? gym['latitude']
                : double.tryParse(gym['latitude'].toString()) ?? 0.0,
            longitude: (gym['longitude'] is double)
                ? gym['longitude']
                : double.tryParse(gym['longitude'].toString()) ?? 0.0,
            prefecture: (gym['prefecture'] as String?) ?? "不明な都道府県",
            city: (gym['city'] as String?) ?? "不明な市区町村",
          ));
        }

        state = [...returnGymList];
      } else {
        throw Exception("Failed to fetch data");
      }
    } catch (error) {
      throw Exception("ジムデータ取得に失敗しました: $error");
    }
  }
}

/// ■ プロバイダ
final gymProvider = StateNotifierProvider<GymNotifier, List<Gym>>((ref) {
  return GymNotifier();
});
