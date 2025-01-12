import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  Future<void> login(String mailAddress, String password) async {
    try {
      // Firebase ログイン
      await _auth.signInWithEmailAndPassword(
          email: mailAddress, password: password);

      // 状態を更新
      state = true;

      // 状態更新後，繊維が即時発生しないよう，少し遅延をいれる
      await Future.delayed(Duration(milliseconds: 500));
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

// Riverpodプロバイダー
final authProvider = StateNotifierProvider<AuthNotifier, bool>((ref) {
  return AuthNotifier();
});
