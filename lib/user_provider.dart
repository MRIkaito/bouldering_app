import 'package:auto_route/annotations.dart';
import 'package:bouldering_app/model/users.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserNotifier extends StateNotifier<Users?> {
  UserNotifier() : super(null);

  // ユーザーデータを取得する関数
  Future<void> fetchUserData(String userId) async {
    int requestId = 1; // リクエストNoを確認

    final url = Uri.parse(
            'https://us-central1-gcp-compute-engine-441303.cloudfunctions.net/getData')
        .replace(queryParameters: {
      'request_id': requestId.toString(),
      'user_id': userId.toString(),
    });

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // レスポンスボディをJSONとしてデコードする
        // ここでまず、[{"id":1. "name":"Alice"}]のような形で取得
        final List<dynamic> userInformation = jsonDecode(response.body);

        // ここで、{"id":1. "name":"Alice"}を取得
        // ※データは1つしか取得しないので、[0]でアクセスしてもOK
        final Map<String, dynamic> user = userInformation[0];

        // ここで、fromJsonで、Usersクラスのデータをすべて取得する
        final use = Users.fromJson(user);

        // 最後に、state(状態)としてデータを取得する
        state = use;
      } else {
        throw Exception("Failed to fetch data");
      }
    } catch (error) {
      throw Exception("ログインに失敗しました: ${error}");
    }
  }

  // ユーザー情報をクリア
  void clearUserData() {
    state = null;
  }
}

final userProvider = StateNotifierProvider<UserNotifier, Users?>((ref) {
  return UserNotifier();
});
