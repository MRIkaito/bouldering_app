import 'package:bouldering_app/view_model/utility/show_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bouldering_app/view_model/user_provider.dart';
import 'package:go_router/go_router.dart';

/// ■ クラス
/// - 認証情報を管理する
class AuthNotifier extends StateNotifier<bool> {
  /// ■コンストラクタ
  /// - 最初はログイン状態をfalseに設定する
  /// - 次に、checkLoginStatus()で、ログイン状態を確認する
  ///
  /// 引数：
  /// - [userProviderRef] ユーザー情報のプロバイダの参照情報
  AuthNotifier(this.userProviderRef) : super(false) {
    _checkLoginStatus();
  }

  /// ■ 定数
  /// -通信に関わる定数を定義
  static const String emailAlreadyInUse = "email-already-in-use";
  static const String emailAlreadyInUseTitle = "すでにメールアドレスが登録されています";
  static const String emailAlreadyInUseMessage = "入力されたメールアドレスはすでに使用されています。";
  static const String invalidEmail = "invalid-email";
  static const String invalidEmailTitle = "無効なメールアドレス";
  static const String invalidEmailMessage = "入力されたメールアドレスは無効です。";
  static const String userNotFound = "user-not-found";
  static const String userNotFoundTitle = "ユーザーが見つかりません";
  static const String userNotFoundMessage = "入力されたメールアドレスが見つかりません";
  static const String wrongPassword = "wrong-password";
  static const String wrongPasswordTitle = "パスワードエラー";
  static const String wrongPasswordMessage = "パスワードが違います。";
  static const String networkRequestFailed = "network-request-failed";
  static const String networkRequestFailedTitle = "ネットワークエラー";
  static const String networkRequestFailedMessage =
      "サーバーとの通信に失敗しました。デバイスのネットワーク設定と環境を確認して、再度試してください。";
  static const String otherErrorTitle = "不明なエラー";
  static const String otherErrorMessage = "不明なエラーが発生しました。時間をおいて再度お試しください。";
  static const String weakPassword = "weak-password";
  static const String weakPasswordTitle = "パスワードエラー";
  static const String weakPasswordMessage = "パスワードが指定された条件を満たしていません。";

  /// ■ プロパティ
  /// - FirebaseAuthenticationのインスタンス
  /// - ログイン・サインアップのときに使用する
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// ■ プロパティ
  /// - userProvider
  /// - ユーザー情報を参照する
  final Ref userProviderRef;

  /// ■ メソッド
  /// - ログイン状態にあるかを確認する
  /// - ログインしていたら，現在のログイン情報を取得
  /// - ログインしていなければ，nullを代入
  void _checkLoginStatus() {
    final user = _auth.currentUser;
    state = user != null;
  }

  /// ■ メソッド
  /// - パスワードが指定の条件を満たしているかを確認するメソッド
  /// - 条件：英大文字/英小文字/数字を1つずつ使用すること
  /// - 条件(続き)：パスワードは最低8文字以上であること
  /// - 条件を満たしていれば, trueを返す
  /// - 条件を満たしていなければ，falseを返す
  bool _isStrongPassword(String password) {
    final RegExp strongPasswordRegExp =
        RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)[A-Za-z\d@\$!%*?&]{8,}\$');
    return strongPasswordRegExp.hasMatch(password);
  }

  /// ■ メソッド
  /// - ログイン処理
  ///
  /// 引数：
  /// - [context] ウィジェットツリーの情報
  /// - [email] メールアドレス
  /// - [パスワード] パスワード
  Future<void> login(
      BuildContext context, String email, String password) async {
    try {
      // サインイン(ログイン)
      final userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      print("userId(auth_provider.dart):${userCredential.user!.uid}");

      // ユーザー情報取得
      userProviderRef
          .read(userProvider.notifier)
          .fetchUserData(userCredential.user!.uid);

      // ログイン状態(true)に変更
      state = true;

      // ログインページに遷移
      if (mounted) {
        context.push("/Unlogined/LoginOrSignUp/Logined");
      }
    } on FirebaseAuthException catch (e) {
      final errorMap = {
        invalidEmail: [invalidEmailTitle, invalidEmailMessage],
        userNotFound: [userNotFoundTitle, userNotFoundMessage],
        wrongPassword: [wrongPasswordTitle, wrongPasswordMessage],
        networkRequestFailed: [
          networkRequestFailedTitle,
          networkRequestFailedMessage
        ]
      };
      showPopup(context, errorMap[e.code]?[0] ?? otherErrorTitle,
          errorMap[e.code]?[1] ?? otherErrorMessage);
    }
  }

  /// ■ メソッド
  /// - サインアップ(新規登録)処理
  ///
  /// 引数：
  /// - [context] ウィジェットツリーの情報
  /// - [email] メールアドレス
  /// - [パスワード] パスワード
  Future<void> signUp(
      BuildContext context, String email, String password) async {
    // パスワードが指定の条件を満たしていなければ終了する
    if (!_isStrongPassword(password)) {
      showPopup(context, weakPasswordTitle, weakPasswordMessage);
      return;
    }
    try {
      // ユーザーを新規登録して，ログイン情報を取得する
      final userCredential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      // ユーザーを新規登録して，ログイン状態になったかを確認する
      final isSignedUp = await userProviderRef
          .read(userProvider.notifier)
          .insertNewUserData(userCredential.user!.uid, email);
      // ログインされていなければ，サインアップ(新規登録)画面でエラーの旨を表示する(終了)
      if (!isSignedUp) {
        showPopup(context, otherErrorTitle, otherErrorMessage);
        return;
      }
      // ユーザー情報取得
      await userProviderRef
          .read(userProvider.notifier)
          .fetchUserData(userCredential.user!.uid);
      // ログイン状態(true)にする
      state = true;
      // マイページへ画面遷移する
      if (mounted) {
        context.push("/Unlogined/LoginOrSignUp/Logined");
      }
    } on FirebaseAuthException catch (e) {
      final errorMap = {
        emailAlreadyInUse: [emailAlreadyInUseTitle, invalidEmailMessage],
        invalidEmail: [invalidEmailTitle, invalidEmailMessage],
        networkRequestFailed: [
          networkRequestFailedTitle,
          networkRequestFailedMessage
        ]
      };
      if (e.code != weakPassword) {
        showPopup(context, errorMap[e.code]?[0] ?? otherErrorTitle,
            errorMap[e.code]?[1] ?? otherErrorMessage);
      }
    }
  }

  /// ■ メソッド
  /// - ログアウト
  /// - ログアウト時にユーザー情報(状態)をクリアする
  Future<void> logout() async {
    try {
      // ログアウト(サインアウト)
      await _auth.signOut();
      // 状態をログアウトに変更
      state = false;
      // 取得してたユーザー情報(状態)をクリアする
      userProviderRef.read(userProvider.notifier).clearUserData();
    } catch (e) {
      throw Exception("ログアウトに失敗しました：\$e");
    }
  }
}

/// ■ プロバイダ
final authProvider = StateNotifierProvider<AuthNotifier, bool>((ref) {
  return AuthNotifier(ref);
});
