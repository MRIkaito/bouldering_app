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
    try {
      print("▼ gymInfoProvider デバッグログ");

      // 1. 基本情報の取得（request_id=31）
      final baseUrl = Uri.parse(
              'https://us-central1-gcp-compute-engine-441303.cloudfunctions.net/getData')
          .replace(queryParameters: {'request_id': '31'});
      final baseResponse = await http.get(baseUrl);
      print("statusCode (base): ${baseResponse.statusCode}");

      if (baseResponse.statusCode != 200) {
        throw Exception('ジム基本情報の取得に失敗');
      }
      final List<dynamic> baseData = jsonDecode(baseResponse.body);

      // 2. イキタイ数の取得（request_id=32）
      final ikitaiUrl = Uri.parse(
              'https://us-central1-gcp-compute-engine-441303.cloudfunctions.net/getData')
          .replace(queryParameters: {'request_id': '32'});
      final ikitaiResponse = await http.get(ikitaiUrl);
      print("statusCode (ikitai): ${ikitaiResponse.statusCode}");

      if (ikitaiResponse.statusCode != 200) {
        throw Exception('イキタイ数の取得に失敗');
      }
      final Map<int, int> ikitaiMap = {
        for (var item in jsonDecode(ikitaiResponse.body))
          int.parse(item['gym_id'].toString()):
              int.parse(item['ikitai_count'].toString())
      };

      // 3. 投稿数の取得（request_id=33）
      final boulUrl = Uri.parse(
              'https://us-central1-gcp-compute-engine-441303.cloudfunctions.net/getData')
          .replace(queryParameters: {'request_id': '33'});
      final boulResponse = await http.get(boulUrl);
      print("statusCode (boul): ${boulResponse.statusCode}");

      if (boulResponse.statusCode != 200) {
        throw Exception('投稿数の取得に失敗');
      }
      final Map<int, int> boulMap = {
        for (var item in jsonDecode(boulResponse.body))
          int.parse(item['gym_id'].toString()):
              int.parse(item['boul_count'].toString())
      };

      // 4. 各ジムに統合
      final Map<int, GymInfo> map = {
        for (var item in baseData)
          if (item['gym_id'] != null)
            item['gym_id']: GymInfo.fromJson({
              ...item,
              'ikitai_count': ikitaiMap[item['gym_id']] ?? 0,
              'boul_count': boulMap[item['gym_id']] ?? 0,
            }),
      };

      state = map;
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
