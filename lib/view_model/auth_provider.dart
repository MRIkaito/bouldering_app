import 'package:bouldering_app/view/pages/confirmed_dialog_page.dart';
import 'package:bouldering_app/view_model/favorite_by_user_provider.dart';
import 'package:bouldering_app/view_model/favorite_user_provider.dart';
import 'package:bouldering_app/view_model/my_tweets_provider.dart';
import 'package:bouldering_app/view_model/utility/show_popup.dart';
import 'package:bouldering_app/view_model/wanna_go_relation_provider.dart';
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
  /// - [ref] ユーザー情報のプロバイダの参照情報
  AuthNotifier(this.ref) : super(false) {
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
  final Ref ref;

  /// ■ メソッド
  /// - ログイン状態にあるかを確認する
  /// - ログインしていたら，現在のログイン情報を取得
  /// - ログインしていなければ，nullを代入
  void _checkLoginStatus() {
    final user = _auth.currentUser;
    state = user != null;
  }

  /// ■ メソッド
  /// - ログイン処理
  ///
  /// 引数：
  /// - [context] ウィジェットツリーの情報
  /// - [email] メールアドレス
  /// - [password] パスワード
  Future<void> login(
      BuildContext context, String email, String password) async {
    try {
      // サインイン(ログイン)
      final userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      // ユーザー情報取得
      await ref
          .read(userProvider.notifier)
          .fetchUserData(userCredential.user!.uid); // ユーザー情報を必ず取得する

      // ツイート情報取得
      await ref
          .read(myTweetsProvider.notifier)
          .fetchTweets(userCredential.user!.uid); // ツイート情報を最初に取得しておく

      // イキタイジム情報取得
      await ref
          .read(wannaGoRelationProvider.notifier)
          .fetchWannaGoGymCards(userCredential.user!.uid); // イキタイジム情報を最初に取得しておく

// お気に入りユーザーを取得しておく
      await ref
          .read(favoriteUserProvider.notifier)
          .fetchDataFavoriteUser('favorite', userCredential.user!.uid);

// 🔥 被お気に入りユーザーも取得しておく（←これが抜けていた）
      await ref
          .read(favoredByUserProvider.notifier)
          .fetchFavoredByUsers(userCredential.user!.uid);

      // ログイン状態(true)に変更
      state = true;

      if (mounted) {
        // context.push("/Unlogined/LoginOrSignUp/Logined");
        context.go("/mypage");
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
  /// - [password] パスワード
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
      // ユーザー新規登録(登録:true/登録失敗:false)
      final isSignedUp = await ref
          .read(userProvider.notifier)
          .insertNewUserData(userCredential.user!.uid, email);
      // ログインされていなければ新規登録画面でエラー表示(終了)
      if (!isSignedUp) {
        showPopup(context, otherErrorTitle, otherErrorMessage);
        return;
      }
      // ユーザー情報取得
      await ref
          .read(userProvider.notifier)
          .fetchUserData(userCredential.user!.uid);
      // ログイン状態(true)にする
      state = true;
      // マイページへ画面遷移する
      if (mounted) {
        // context.push("/Unlogined/LoginOrSignUp/Logined");
        context.go("/mypage");
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
  /// - パスワードが指定の条件を満たしているかを確認するメソッド
  /// - 条件：英大文字/英小文字/数字を1つずつ使用すること
  /// - 条件(続き)：パスワードは最低8文字以上であること
  /// - 条件を満たしていれば, trueを返す
  /// - 条件を満たしていなければ，falseを返す
  bool _isStrongPassword(String password) {
    final RegExp strongPasswordRegExp =
        RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)[A-Za-z\d@\$!%*?&]{8,}$');
    return strongPasswordRegExp.hasMatch(password);
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
      // 取得していたユーザー情報(状態)をクリア
      ref.read(userProvider.notifier).clearUserData();
    } catch (e) {
      throw Exception("ログアウトに失敗しました：\$e");
    }
  }

  /// ■ メソッド
  /// - 退会処理
  /// - 退会時にユーザー情報(状態)をクリアにする
  ///
  /// 引数
  /// - [context] ウィジェットツリー情報
  /// - [password] パスワード
  Future<void> deleteUserAccount(BuildContext context, String password) async {
    Map<String, dynamic> resultMessage = {
      "result": true,
      "message": "",
    };
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      resultMessage["result"] = false;
      resultMessage["message"] = "ユーザーが見つかりません";
      confirmedDialog(
        context,
        resultMessage["result"],
        message: resultMessage["message"],
      );
      return;
    }

    try {
      // 再認証
      final authCredential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(authCredential);

      // アカウント削除
      await user.delete();

      // ログアウト
      await _auth.signOut();
      // 状態をログアウトに変更
      state = false;

      // 取得していたユーザー情報(状態)をクリア
      ref.read(userProvider.notifier).clearUserData();

      resultMessage["result"] = true;
      resultMessage["message"] = "アカウントを削除しました";
    } on FirebaseAuthException catch (error) {
      resultMessage["result"] = false;
      resultMessage["message"] = "エラーが発生しました";

      switch (error.code) {
        case "wrong-password":
          resultMessage["message"] = "パスワードが間違っています";
          break;

        case "user-not-found":
          resultMessage["message"] = "ユーザーが見つかりません";
          break;

        case "too-many-requests":
          resultMessage["message"] = "リクエストが多すぎます。しばらくお待ちください";
          break;

        default:
          resultMessage["message"] = "エラー：${error.message}";
      }
    } catch (error) {
      resultMessage["result"] = false;
      resultMessage["message"] = "エラーが発生しました";
    }

    // 結果ダイアログを表示し，”戻る" ボタンが押下されたら処理を続行
    bool confirmed = await confirmedDialog(
      context,
      resultMessage["result"],
      message: resultMessage["message"],
    );

    if (confirmed && resultMessage["result"] == true) {
      // ダイアログを閉じてから pop する
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      // 未ログイン画面に遷移
      context.go("/Unlogined");
    }

    return;
  }
}

/// ■ プロバイダ
final authProvider = StateNotifierProvider<AuthNotifier, bool>((ref) {
  return AuthNotifier(ref);
});
