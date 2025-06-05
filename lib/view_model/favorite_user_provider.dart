import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FavoriteUserState {
  final String userId;
  final String userName;
  final String gymName;
  final String userIconUrl;

  FavoriteUserState({
    required this.userId,
    required this.userName,
    required this.gymName,
    required this.userIconUrl,
  });

  FavoriteUserState copyWith({
    String? userId,
    String? userName,
    String? gymName,
    String? userIconUrl,
    bool? isFavorited,
  }) {
    return FavoriteUserState(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      gymName: gymName ?? this.gymName,
      userIconUrl: userIconUrl ?? this.userIconUrl,
    );
  }
}

/// ■ クラス
/// - お気に入り登録しているユーザーを取得する関数
class FavoriteUserNotifier extends StateNotifier<List<FavoriteUserState>> {
  FavoriteUserNotifier() : super([]);

  /// ■ メソッド
  /// お気に入り登録しているユーザーを返す
  ///
  /// 引数
  /// - userId : ログインしているユーザーID
  ///
  /// 返り値
  /// - お気に入り登録しているユーザーをdynamic型(= Map(String: dynamic))で，
  /// それをList形式で返す
  Future<void> fetchDataFavoriteUser(String userId) async {
    final url = Uri.parse(
      'https://us-central1-gcp-compute-engine-441303.cloudfunctions.net/getData',
    ).replace(queryParameters: {
      'request_id': '4',
      'user_id': userId,
    });

    try {
      // HTTP GETリクエスト
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final List<FavoriteUserState> users = data.map((item) {
          print('🧪 favorite fetched raw data: $item');
          return FavoriteUserState(
            userId: item['likee_user_id'] ?? '',
            userName: item['user_name'] ?? '(不明)',
            gymName: item['gym_name'] ?? '-',
            userIconUrl: item['user_icon_url'] ?? '',
          );
        }).toList();

        state = users;
      } else {
        throw Exception("Failed to fetch data");
      }
    } catch (e) {
      print('リクエスト中にErrorが発生しました');
      throw e;
    }
  }

  /// ■ メソッド
  /// - お気に入り登録している人のユーザーID・されている人のユーザーIDのペアが
  /// - 存在するかを確認する
  ///
  /// 引数
  /// - [likerUserId] : お気に入り登録している側のユーザーID
  /// - [likeeUserId] : お気に入り登録されている側のユーザーID
  ///
  /// 返り値
  /// - [true] : likerUserIdのユーザーがlikeeUserIdのユーザーをお気に入り登録している
  /// - [false] : likerUserIdのユーザーはlikeeUserIdのユーザーをお気に入り登録していない
  Future<bool> isAlreadyFavorited(
      String likerUserId, String likeeUserId) async {
    final url = Uri.parse(
            'https://us-central1-gcp-compute-engine-441303.cloudfunctions.net/getData')
        .replace(queryParameters: {
      'request_id': '1',
      'liker_user_id': likerUserId,
      'likee_user_id': likeeUserId,
    });

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data as List).isNotEmpty;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// ■ メソッド
  /// - 特定ユーザーをお気に入り登録する
  ///
  /// 引数
  /// - [likerUserId] お気に入り登録する側のユーザーID
  /// - [likeeUserId] お気に入り登録される側のユーザーID
  ///
  /// 返り値
  /// - 登録完了：true / 登録失敗：false
  Future<bool> addFavoriteUser({
    required String likerUserId,
    required String likeeUserId,
  }) async {
    final url = Uri.parse(
      'https://us-central1-gcp-compute-engine-441303.cloudfunctions.net/getData',
    ).replace(queryParameters: {
      'request_id': '9', // 登録
      'liker_user_id': likerUserId,
      'likee_user_id': likeeUserId,
    });

    final response = await http.get(url);

    if (response.statusCode == 200) {
      print('✅ お気に入り登録成功');

      // ユーザー詳細を取得して状態に追加（仮に別エンドポイントで取得する場合）
      final detailUrl = Uri.parse(
        'https://us-central1-gcp-compute-engine-441303.cloudfunctions.net/getData',
      ).replace(queryParameters: {
        'request_id': '21', // 「特定ユーザーの詳細取得用」のリクエストID
        'user_id': likeeUserId,
      });

      final detailRes = await http.get(detailUrl);

      if (detailRes.statusCode == 200) {
        final dataRaw = jsonDecode(detailRes.body);

        // 配列形式の場合1件目を取り出す
        final data = (dataRaw is List && dataRaw.isNotEmpty) ? dataRaw[0] : {};

        final user = FavoriteUserState(
          userId: likeeUserId,
          userName: data['user_name'] ?? '',
          gymName: data['gym_name'] ?? '-',
          userIconUrl: data['user_icon_url'] ?? '',
        );
        state = [...state, user]; // 追加
      }

      return true;
    } else {
      print('❌ お気に入り登録失敗: ${response.statusCode}');
      return false;
    }
  }

  /// ■ メソッド
  /// - 特定ユーザーのお気に入り登録を解除する
  ///
  /// 引数
  /// - [likerUserId] お気に入り登録する側のユーザーID
  /// - [likeeUserId] お気に入り登録される側のユーザーID
  ///
  /// 返り値
  /// - 削除完了：true / 削除失敗：false
  Future<bool> removeFavoriteUser({
    required String likerUserId,
    required String likeeUserId,
  }) async {
    final url = Uri.parse(
      'https://us-central1-gcp-compute-engine-441303.cloudfunctions.net/getData',
    ).replace(queryParameters: {
      'request_id': '10', // 解除
      'liker_user_id': likerUserId,
      'likee_user_id': likeeUserId,
    });

    final response = await http.delete(url);
    if (response.statusCode == 200) {
      print(' お気に入り解除成功');
      // state から該当ユーザーを削除
      state = state.where((user) => user.userId != likeeUserId).toList();
      return true;
    } else {
      print('❌ お気に入り解除失敗: ${response.statusCode}');
      return false;
    }
  }

  /// ■ メソッド
  /// - 特定ユーザーが現在お気に入りかを確認するヘルパー
  /// - お気に入り登録ユーザー一覧に特定ユーザーが含まれているかを判断する関数を追加
  ///
  /// 引数
  /// - [likeeUserId]お気に入り登録されている(可能性がある)ユーザー
  ///
  /// 返り値
  /// - お気に入り登録されている: true / お気に入り登録されていない: false
  bool isFavoritedByCurrentUser(String likeeUserId) {
    return state.any((user) => user.userId == likeeUserId);
  }
}

// StateNotifierProvider定義
final favoriteUserProvider =
    StateNotifierProvider<FavoriteUserNotifier, List<FavoriteUserState>>(
  (ref) => FavoriteUserNotifier(),
);
