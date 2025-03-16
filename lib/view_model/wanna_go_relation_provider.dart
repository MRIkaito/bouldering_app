import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  Future<void> toggleWannaGo(String userId, int gymId) async {
    try {
      // ここでAPIリクエストを投げて「イキタイ」登録 or 解除
      final response = await postWannaGo(userId, gymId);

      if (response.isSuccess) {
        // 成功したら、状態を更新
        state = AsyncValue.data([...state.value ?? [], gymId]);
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

/// ■ プロバイダ
/// イキタイ登録したジム(状態)を提供するプロバイダ
final wannaGoProvider =
    StateNotifierProvider<WannaGoNotifier, List<WannaGoRelation>>((ref) {
  return WannaGoNotifier();
});

/* 実装途中 */
