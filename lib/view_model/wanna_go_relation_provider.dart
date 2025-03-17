import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// ■ クラス
/// - (後々外部登録する予定)
/// イキタイジムリレーションのデータ状態を表したデータ構造クラス
class WannaGoRelation {
  final String userId;
  final int gymId;
  final DateTime createdAt;

  WannaGoRelation({
    required this.userId,
    required this.gymId,
    required this.createdAt,
  });
}

/// ■ クラス
/// - イキタイ登録したジムを管理するクラス
class WannaGoNotifier extends StateNotifier<List<WannaGoRelation>> {
  /// ■ コンストラクタ
  WannaGoNotifier() : super([]);

  /// ■ メソッド
  /// - ユーザーID, ジムIDをもらって、イキタイ登録したユーザーをDBに登録する処理
  ///
  /// 引数
  /// - [userId] (イキタイ登録した)ユーザーID
  /// - [gymId] (イキタイ登録を押された)ジムのジムID
  ///
  /// 返り値
  /// - 無し
  /// ※ イキタイジムリレーションに登録して状態を変更する
  Future<void> registerWannaGoGym(String userId, int gymId) async {
    final url = Uri.parse(
            'https://us-central1-gcp-compute-engine-441303.cloudfunctions.net/getData')
        .replace(queryParameters: {
      'request_id': '26',
      'user_id': userId.toString(),
      'gym_id': gymId.toString(),
    });

    try {
      // ここでAPIリクエストを投げて「イキタイ」登録 or 解除
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> wannaGoRelationList = jsonDecode(response.body);
        final List<WannaGoRelation> newWannaGoRelationList = wannaGoRelationList
            .map(
              (wannaGoGym) => WannaGoRelation(
                userId: wannaGoGym['user_id'],
                gymId: wannaGoGym['gym_id'],
                createdAt: wannaGoGym['created_at'],
              ),
            )
            .toList();
        state = [...state, ...newWannaGoRelationList];
      } else {
        throw Exception("イキタイジム登録に失敗しました");
      }
    } catch (error) {
      print("エラーメッセージ:${error}");
    }
  }

  /// ■ メソッド
  /// - イキタイ登録を解除する
  ///
  /// 引数
  /// - [user_id] (イキタイ登録した)ユーザーのID
  /// - [gym_id] (イキタイ登録を解除された)ジムのID
  ///
  /// 返り値
  /// - なし
  Future<void> deleteWannaGoGym(String userId, int gymId) async {
    final url = Uri.parse(
            'https://us-central1-gcp-compute-engine-441303.cloudfunctions.net/getData')
        .replace(queryParameters: {
      'request_id': '27',
      'user_id': userId.toString(),
      'gym_id': gymId.toString(),
    });

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {}
    } catch (error) {}
  }
}

/// ■ プロバイダ
/// イキタイ登録したジム(状態)を提供するプロバイダ
final wannaGoProvider =
    StateNotifierProvider<WannaGoNotifier, List<WannaGoRelation>>((ref) {
  return WannaGoNotifier();
});
