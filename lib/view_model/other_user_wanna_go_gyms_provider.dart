import 'package:bouldering_app/model/gym_info.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// ■ クラス
/// - 他ユーザーのイキタイジム情報を管理するクラス
class OtherUserWannaGoRelationNotifier
    extends StateNotifier<Map<int, GymInfo>> {
  OtherUserWannaGoRelationNotifier(this.userId) : super({});

  /// ■ プロパティ
  final String userId;
  bool _isLoading = false;

  /// ■ メソッド(ゲッター)
  /// - 現在のローディング状態を返す
  bool get isLoading => _isLoading;

  /// ■ メソッド
  /// - イキタイジムをすべて破棄する
  void disposeOtherUserGymCards() {
    state = {};
  }

  /// ■ メソッド
  /// - ジムカード情報を取得する
  Future<void> fetchGymCards() async {
    if (_isLoading) return;

    _isLoading = true;
    print("🟢 [DEBUG] fetchOtherUserGymCards() called for userId: $userId");

    final url = Uri.parse(
            'https://us-central1-gcp-compute-engine-441303.cloudfunctions.net/getData')
        .replace(queryParameters: {
      'request_id': '23',
      'user_id': userId,
    });

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final List<GymInfo> gyms =
            jsonData.map((gymCard) => GymInfo.fromJson(gymCard)).toList();

        state = {
          for (var gym in gyms) gym.gymId: gym.copyWith(),
        };

        print("🟢 [DEBUG] 他ユーザーのイキタイジム取得成功 gyms.length=${state.length}");
      } else {
        print("❌ [ERROR] Failed to fetch gyms. status: ${response.statusCode}");
      }
    } catch (error) {
      print("❌ [ERROR] Exception fetching gyms: $error");
    } finally {
      _isLoading = false;
    }
  }
}

/// ■ プロバイダ
final otherUserWannaGoRelationProvider = StateNotifierProvider.family<
    OtherUserWannaGoRelationNotifier, Map<int, GymInfo>, String>(
  (ref, userId) => OtherUserWannaGoRelationNotifier(userId),
);
