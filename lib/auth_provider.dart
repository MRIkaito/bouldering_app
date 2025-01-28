import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bouldering_app/user_provider.dart';

class AuthNotifier extends StateNotifier<bool> {
  AuthNotifier(this.ref) : super(false) {
    _checkLoginStatus();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Ref ref; // これがおそらくuserProvider

  // 現在のログイン状態を確認
  void _checkLoginStatus() {
    // FirebaseAuthの現在の状態を確認
    final user = _auth.currentUser;

    // ログイン状態でtrue, 未ログインでfalse
    if (user != null) {
      state = true;
      // ref.read(userProvider.notifier).fetchUserData(user.)
    } else {
      state = false;
    }
  }

  // ログイン処理
  Future<void> login(String mailAddress, String password) async {
    try {
      // Firebase ログイン
      final userCredential = await _auth.signInWithEmailAndPassword(
          email: mailAddress, password: password);

      // 状態を更新
      state = true;

      // ユーザー情報を取得する
      ref.read(userProvider.notifier).fetchUserData(userCredential.user!.uid);

      // 状態更新後，繊維が即時発生しないよう，少し遅延をいれる
      await Future.delayed(Duration(milliseconds: 500));
    } catch (e) {
      throw Exception("登録に失敗しました：$e");
    }
  }

  // サインアップ処理には、userProviderの部分の処理をどうするか工夫が必要
  // サインアップ処理
  Future<void> signUp(String mailAddress, String password) async {
    try {
      // Firebase アカウント作成
      await _auth.createUserWithEmailAndPassword(
          email: mailAddress, password: password);

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
      ref.read(userProvider.notifier).clearUserData(); // ユーザーデータをクリアする
    } catch (e) {
      throw Exception("ログアウトに失敗しました：$e");
    }
  }
}

// Riverpodプロバイダー
final authProvider = StateNotifierProvider<AuthNotifier, bool>((ref) {
  return AuthNotifier(ref);
});
