import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FavoredByUserState {
  final String userId;
  final String userName;
  final String gymName;
  final String userIconUrl;

  FavoredByUserState({
    required this.userId,
    required this.userName,
    required this.gymName,
    required this.userIconUrl,
  });

  FavoredByUserState copyWith({
    String? userId,
    String? userName,
    String? gymName,
    String? userIconUrl,
    bool? isFavorited,
  }) {
    return FavoredByUserState(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      gymName: gymName ?? this.gymName,
      userIconUrl: userIconUrl ?? this.userIconUrl,
    );
  }
}

class FavoredByUserNotifier extends StateNotifier<List<FavoredByUserState>> {
  FavoredByUserNotifier(this.ref) : super([]);
  final Ref ref; // favorite_user_provider.dartの参照情報

  /// ■ メソッド
  /// - 被お気に入りユーザーを取得
  /// - 初回取得時 or お気に入られページ遷移時のみ呼び出しする
  ///
  /// 引数
  /// - [currentUserId]自身のユーザーID
  Future<void> fetchFavoredByUsers(String currentUserId) async {
    final url = Uri.parse(
      'https://us-central1-gcp-compute-engine-441303.cloudfunctions.net/getData',
    ).replace(queryParameters: {
      'request_id': '5',
      'user_id': currentUserId,
    });

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      final users = data.map((item) {
        return FavoredByUserState(
          userId: item['liker_user_id'] ?? '',
          userName: item['user_name'] ?? '',
          gymName: item['gym_name'] ?? '-',
          userIconUrl: item['user_icon_url'] ?? '',
        );
      }).toList();

      state = users;

      print('🛰️ favoredByUserProvider: fetchFavoredByUsers 取得内容');
      for (final item in data) {
        print(' - ${item['user_name']} (${item['liker_user_id']})');
      }
    } else {
      print('❌ 被お気に入りユーザー取得失敗: ${response.statusCode}');
    }
  }

  /// ■ メソッド
  /// - お気に入り登録 or 解除の状態をトグルする
  ///
  /// 引数
  /// - [userId]お気に入り対象のユーザーID
  /// - [newStatus]相手をお気に入りする(true)か，お気に入り解除する(false)かの真偽値
  void toggleFavoriteStatus(String userId, bool newStatus) {
    state = [
      for (final user in state)
        if (user.userId == userId)
          user.copyWith(isFavorited: newStatus)
        else
          user
    ];
  }

  /// ■ メソッド
  /// - お気に入りユーザーを追加する
  // Future<void> addFavoriteUser({
  //   required String likerUserId,
  //   required String likeeUserId,
  // }) async {
  //   final url = Uri.parse(
  //     'https://us-central1-gcp-compute-engine-441303.cloudfunctions.net/handleFavoriteUser',
  //   );

  //   final body = jsonEncode({
  //     'request_id': '9',
  //     'liker_user_id': likerUserId,
  //     'likee_user_id': likeeUserId,
  //   });

  //   final response = await http.post(
  //     url,
  //     headers: {'Content-Type': 'application/json'},
  //     body: body,
  //   );

  //   if (response.statusCode == 200) {
  //     // favoriteUserProvider にも追加
  //     final detailUrl = Uri.parse(
  //       'https://us-central1-gcp-compute-engine-441303.cloudfunctions.net/getData',
  //     ).replace(queryParameters: {
  //       'request_id': '21',
  //       'user_id': likeeUserId,
  //     });

  //     final detailRes = await http.get(detailUrl);
  //     if (detailRes.statusCode == 200) {
  //       final dataRaw = jsonDecode(detailRes.body);
  //       final data = (dataRaw is List && dataRaw.isNotEmpty) ? dataRaw[0] : {};

  //       final user = FavoriteUserState(
  //         userId: likeeUserId,
  //         userName: data['user_name'] ?? '',
  //         gymName: data['gym_name'] ?? '-',
  //         userIconUrl: data['user_icon_url'] ?? '',
  //       );

  //       final favoriteNotifier = ref.read(favoriteUserProvider.notifier);
  //       favoriteNotifier.state = [...favoriteNotifier.state, user];
  //     }
  //   } else {
  //     print('❌ お気に入り登録失敗: ${response.statusCode}');
  //   }
  // }

  /// ■ メソッド
  /// - お気に入りユーザーを解除する
  // Future<void> removeFavoriteUser({
  //   required String likerUserId,
  //   required String likeeUserId,
  // }) async {
  //   final url = Uri.parse(
  //     'https://us-central1-gcp-compute-engine-441303.cloudfunctions.net/handleFavoriteUser',
  //   );

  //   final body = jsonEncode({
  //     'request_id': '10',
  //     'liker_user_id': likerUserId,
  //     'likee_user_id': likeeUserId,
  //   });

  //   final response = await http.post(
  //     url,
  //     headers: {'Content-Type': 'application/json'},
  //     body: body,
  //   );

  //   if (response.statusCode == 200) {
  //     // favoriteUserProvider からも削除
  //     final favoriteNotifier = ref.read(favoriteUserProvider.notifier);
  //     favoriteNotifier.state = favoriteNotifier.state
  //         .where((user) => user.userId != likeeUserId)
  //         .toList();
  //   } else {
  //     print('❌ お気に入り解除失敗: ${response.statusCode}');
  //   }
  // }
}

final favoredByUserProvider =
    StateNotifierProvider<FavoredByUserNotifier, List<FavoredByUserState>>(
  (ref) => FavoredByUserNotifier(ref),
);
