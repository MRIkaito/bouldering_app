import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bouldering_app/model/gym_info.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// ■ クラス
/// - アプリ全体で管理する，ジム情報を状態管理するクラス
class GymInfoNotifier extends StateNotifier<Map<int, GymInfo>> {
  GymInfoNotifier() : super({});

  /// ■ メソッド
  /// - GymInfoクラスのプロパティとして設定されているジムデータをDBから取得する
  Future<void> fetchGymInfoData() async {
    const requestId = 13;

    final url = Uri.parse(
            'https://us-central1-gcp-compute-engine-441303.cloudfunctions.net/getData')
        .replace(queryParameters: {
      'request_id': requestId.toString(),
    });

    try {
      print("▼ gymInfoProvider デバッグログ");
      print("URL: $url");

      final response = await http.get(url);

      print("statusCode: ${response.statusCode}");
      print("body: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final Map<int, GymInfo> map = {
          for (var item in data)
            if (item['gym_id'] != null) item['gym_id']: GymInfo.fromJson(item),
        };
        state = map;
      } else {
        throw Exception('ジム詳細情報の取得に失敗 (statusCode=${response.statusCode})');
      }
    } catch (e) {
      print("ジム詳細取得エラー: $e");
    }
  }
}

/// ■ プロバイダ
/// - ジム情報が管理されている状態を提供する
final gymInfoProvider =
    StateNotifierProvider<GymInfoNotifier, Map<int, GymInfo>>((ref) {
  return GymInfoNotifier();
});
