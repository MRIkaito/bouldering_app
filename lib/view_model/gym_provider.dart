import 'package:bouldering_app/model/gym.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// ■ クラス
/// - アプリ起動時に、全ジムのジムID・ジム名・経度・緯度を取得して管理する
/// - Gymクラスを状態保持する
class GymNotifier extends StateNotifier<List<Gym>> {
  /// ■ コンストラクタ
  /// TODO 初期状態をどうするかを考える必要がある
  GymNotifier() : super([]); // ひとまず、空の配列でコンストラクタを作成する

  /// ■メソッド: fetchGymData
  /// - ジムのID・ジム名・経度・緯度を取得する
  ///
  /// 引数:
  /// - []
  Future<void> fetchGymData() async {
    // DBアクセス・データ取得
    int requestId = 13; // TODO：リクエストIDを確認する

    final url = Uri.parse(
            'https://us-central1-gcp-compute-engine-441303.cloudfunctions.net/getData')
        .replace(queryParameters: {
      'request_id': requestId.toString(),
    });

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
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
        final List<dynamic> gymLocation = jsonDecode(response.body);
        print("【Debug】レスポンスデータ(gymLocation):");
        print("$gymLocation");

        if (gymLocation.isEmpty) {
          throw Exception("ジムの情報を取得できませんでした");
        }

        // 取得した事務情報の要素数
        int gymLocationsLength = gymLocation.length;
        // 状態(state)に代入する一時的な変数
        List<Gym> returnGymList = [];
        // 取得したジム情報を、Gymクラスに変換して状態に代入する
        for (int i = 0; i < gymLocationsLength; i++) {
          Gym aimAppendGymLocation = Gym(
            gymId: gymLocation[i]['gym_id'],
            gymName: gymLocation[i]['gym_name'],
            latitude: gymLocation[i]['latitude'],
            longitude: gymLocation[i]['longitude'],
          );

          returnGymList.add(aimAppendGymLocation);
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
