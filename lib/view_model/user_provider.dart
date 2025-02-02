import 'package:auto_route/annotations.dart';
import 'package:bouldering_app/model/boulder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// ■ クラス
/// - ログイン時に取得するユーザー情報を管理する
/// - Usersの状態をクラスとして保持する
class UserNotifier extends StateNotifier<Boulder?> {
  /// ■コンストラクタ
  /// - 状態をnullに初期化して、未ログイン状態にする
  UserNotifier() : super(null);

  /// ■ メソッド：fetchUserData
  /// - ユーザーデータを取得する
  ///
  /// 引数：
  /// - [userId] ユーザーのID
  Future<void> fetchUserData(String userId) async {
    // テスト:ユーザーIDが渡されているかを確認する
    print("userId(user_provider.dart): ${userId}");

    // リクエストNOを確認する必要有
    int requestId = 3;

    final url = Uri.parse(
            'https://us-central1-gcp-compute-engine-441303.cloudfunctions.net/getData')
        .replace(queryParameters: {
      'request_id': requestId.toString(),
      'user_id': userId,
    });

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // レスポンスボディをJSONとしてデコードする
        // ここでまず、[{"id":1. "name":"Alice"}]のような形で取得する
        final List<dynamic> userInformation = jsonDecode(response.body);
        print("レスポンスデータ(userInformation): $userInformation");

        if (userInformation.isEmpty) {
          throw Exception("ユーザーデータが空です");
        }

        // ここで、{"id":1. "name":"Alice"}を取得
        // ※ データは1つしか取得しないので、[0]でアクセスしてもOK
        final Map<String, dynamic> user = userInformation[0];
        print("取得したユーザーデータ(user): $user");

        // fromJsonで、Boulderクラスのデータをすべて取得する
        final use = Boulder.fromJson(user);

        // 最後に、state(状態)としてデータを取得する
        state = use;
      } else {
        throw Exception("Failed to fetch data");
      }
    } catch (error) {
      throw Exception("ログインに失敗しました: ${error}");
    }
  }

  /// ■ メソッド：insertNewUserData
  /// - (サインアップ)ユーザー情報を新規登録する
  /// - サインアップ時に使用する
  ///
  /// 返り値：
  /// - true：新規登録成功
  /// - false：新規登録失敗
  Future<bool> insertNewUserData(String userId, String email) async {
    int requestId = 11;

    final url = Uri.parse(
            'https://us-central1-gcp-compute-engine-441303.cloudfunctions.net/getData')
        .replace(queryParameters: {
      'request_id': requestId.toString(),
      'user_id': userId.toString(),
      'email': email.toString(),
    });

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  /// ■ メソッド：clearUserData
  /// - ユーザ─情報をクリアする(state = null)
  /// - ログアウト時に使用する
  void clearUserData() {
    state = null;
  }
}

/// ■ プロバイダ
final userProvider = StateNotifierProvider<UserNotifier, Boulder?>((ref) {
  return UserNotifier();
});
