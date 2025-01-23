import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthNotifier extends StateNotifier<bool> {
  AuthNotifier() : super(false) {
    _checkLoginStatus();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 現在のログイン状態を確認
  void _checkLoginStatus() {
    // FirebaseAuthの現在の状態を確認
    final user = _auth.currentUser;
    // ログイン状態でtrue, 未ログインでfalse
    if (user != null) {
      state = true;
    } else {
      state = false;
    }
  }

  // ログイン処理
  Future<String> login(String mailAddress, String password) async {
    try {
      // Firebase ログイン
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: mailAddress, password: password);
      String userId = userCredential.user!.uid;

      // 状態を更新
      state = true;

      // 状態更新後，繊維が即時発生しないよう，少し遅延をいれる
      await Future.delayed(Duration(milliseconds: 500));
      return userId;
    } catch (e) {
      throw Exception("登録に失敗しました：$e");
    }
  }

  // サインアップ処理
  Future<void> signUp(String mailAddress, String password) async {
    try {
      // Firebase アカウント作成
      await _auth.createUserWithEmailAndPassword(
          email: mailAddress, password: password);

      //
      state = true; // サインアップ成功時に状態を更新
    } catch (e) {
      throw Exception("登録に失敗しました: $e");
    }
  }

  // ログアウト処理
  Future<void> logout() async {
    try {
      await _auth.signOut();
      state = false; // ログアウト時に状態を更新
    } catch (e) {
      throw Exception("ログアウトに失敗しました：$e");
    }
  }
}

// ユーザー情報を取得するFetchData
Future<void> fetchDataUserInformation(int userId) async {
  final url = Uri.parse(
          'https://us-central1-gcp-compute-engine-441303.cloudfunctions.net/getData')
      .replace(queryParameters: {'user_id': userId.toString()});

  try {
    // HTTP GETリクエスト
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // レスポンスボディをJSONとしてデコードする
      final List<dynamic> data = jsonDecode(response.body);

      // 指定されたuser_idのデータを検索
      final user = data.firstWhere((user) => user['user_id'] == userId,
          orElse: () => null // 見つからない場合，nllを返す
          );

      if (user != null) {
        //
      } else {
        print('user_id: $userId のデータが見つかりませんでした');
      }
    } else {
      print('エラーコード：${response.statusCode}');
    }
  } catch (e) {
    print('リクエスト中にErrorが発生しました: $e');
  }
}

// Riverpodプロバイダー
final authProvider = StateNotifierProvider<AuthNotifier, bool>((ref) {
  return AuthNotifier();
});
