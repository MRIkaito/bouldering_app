import 'package:http/http.dart' as http;
import 'dart:convert';

/// ■ クラス
/// - お気に入り登録しているユーザーを取得する関数
class FavoriteUserViewModel {
  /// ■ メソッド
  /// お気に入り登録しているユーザーを返す
  ///
  /// 引数
  /// - type : favorite(お気に入り)/favoredBy(被お気に入り)区分を分ける
  /// - userId : ログインしているユーザーID
  ///
  /// 返り値
  /// - お気に入り登録しているユーザーをdynamic型(= Map(String: dynamic))で，
  /// それをList形式で返す
  Future<List<dynamic>> fetchDataFavoriteUser(
      String type, String userId) async {
    // DBに渡すリクエストID
    int requestId;

    if (type == 'favorite') {
      requestId = 4; // favorite(お気に入り)
    } else {
      print("type: $type");
      requestId = 5; // favoredBy(被お気に入り,気に入られている)
    }

    final url = Uri.parse(
            'https://us-central1-gcp-compute-engine-441303.cloudfunctions.net/getData')
        .replace(queryParameters: {
      'request_id': requestId.toString(),
      'user_id': userId.toString(),
    });
    print("url: $url");

    try {
      print("test1");
      // HTTP GETリクエスト
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // レスポンスボディをJSONとしてデコードする
        final List<dynamic> data = jsonDecode(response.body);
        print("受け取ったdata: $data");
        return data;
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
}
