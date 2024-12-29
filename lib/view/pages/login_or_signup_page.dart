import 'package:auto_route/auto_route.dart';
import 'package:bouldering_app/view/components/app_logo.dart';
import 'package:bouldering_app/view/components/button.dart';
import 'package:bouldering_app/view/components/submit_form.dart';
import 'package:bouldering_app/view/components/switcher_tab.dart';
import 'package:bouldering_app/view/pages/logined_my_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

@RoutePage()
class LoginOrSignUpPage extends StatefulWidget {
  const LoginOrSignUpPage({super.key});

  @override
  _LoginOrSignUpPageState createState() => _LoginOrSignUpPageState();
}

class _LoginOrSignUpPageState extends State<LoginOrSignUpPage> {
/* ============================================
 * ・変数
 * String _mailAndPasswordCheck：パスワードを管理する変数
 * String _mailAddress：メールアドレスを管理する変数
 *
 * ============================================ */
  String _password = ''; // パスワードを管理する変数
  String _mailAddress = ''; // メールアドレスを管理する変数

/* ============================================
 * ・関数
 * _mailAndPasswordCheck
 *
 * ・引数
 * String _mailAddress：メールアドレス
 * String _password：パスワード
 * BuildContext context：ウィジェットツリー情報
 *
 * ・説明
 * メールアドレス・パスワードがから出ないことを確認する
 * 空の場合は何も発生しない
 * 初めてアカウント作成する場合は，作成後にマイページに遷移する
 * すでにアカウントがある場合は，エラーが発生する
 *
 * ・補足
 *
 * ============================================ */
  void _signUp(
      String mailAddress, String password, BuildContext context) async {
    if (mailAddress.isEmpty || password.isEmpty) {
      print("メールアドレスまたはパスワードが空です");
      return;
    }

    try {
      // メールアドレス・パスワードでユーザー登録
      final FirebaseAuth auth = FirebaseAuth.instance;
      await auth.createUserWithEmailAndPassword(
        email: mailAddress,
        password: password,
      );
      // ユーザー登録に成功した時
      // マイページに遷移+ログイン・サインアップ画面を吐き
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) {
          return LoginedMyPage(); // ユーザID情報を渡す必要があると思う
        }),
      );
    } catch (e) {
      print("エラー発生：$e");
    }
  }

  /* ============================================
 * ・関数
 * _
 *
 * ・引数
 * String _mailAddress：メールアドレス
 * String _password：パスワード
 * BuildContext context：ウィジェットツリー情報
 *
 * ・説明
 * メールアドレス・パスワードがから出ないことを確認する
 * 空の場合は何も発生しない
 * 初めてアカウント作成する場合は，作成後にマイページに遷移する
 * すでにアカウントがある場合は，エラーが発生する
 *
 * ・補足
 *
 * ============================================ */
  void _login(String mailAddress, String password, BuildContext context) async {
    if (mailAddress.isEmpty || password.isEmpty) {
      print("メールアドレスまたはパスワードが空です");
      return;
    }

    try {
      // メールアドレス・パスワードでユーザー登録
      final FirebaseAuth auth = FirebaseAuth.instance;
      await auth.signInWithEmailAndPassword(
        email: mailAddress,
        password: password,
      );
      // ユーザー登録に成功した時
      // マイページに遷移+ログイン・サインアップ画面を吐き
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) {
          return LoginedMyPage();
        }),
      );
    } catch (e) {
      print("エラー発生：$e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, // 戻るボタンを非表示
          elevation: 0,
        ),
        body: Column(
          children: [
            // タブバー部分
            const SwitcherTab(leftTabName: "ログイン", rightTabName: "新規登録"),

            // タブの内容部分
            Expanded(
              child: TabBarView(
                children: [
                  // ログインタブの中身
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 余白
                        const SizedBox(height: 32),
                        // ロゴ
                        const AppLogo(),
                        // 余白
                        const SizedBox(height: 24),
                        // メールアドレスの入力欄
                        const Text(
                          'メールアドレス',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        // 余白
                        const SizedBox(height: 8),
                        // メールアドレス テキストフォーム
                        SubmitFormWidget(
                          isObscure: false,
                          hintText: "mri.benkyochannel@gmail.com",
                          onSubmitTextChanged: (mailAddress) {
                            setState(() {
                              _mailAddress = mailAddress; // 入力されたメールアドレスを受け取る
                            });
                          },
                        ),
                        // 余白
                        const SizedBox(height: 24),
                        // パスワードの入力欄
                        const Text(
                          'パスワード',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        // 余白
                        const SizedBox(height: 8),
                        // パスワードテキストフォーム
                        SubmitFormWidget(
                          isObscure: true,
                          hintText: "6文字以上の半角英数",
                          onSubmitTextChanged: (password) {
                            setState(() {
                              _password = password; // 入力されたパスワードを受け取る
                            });
                          },
                        ),
                        // 余白
                        const SizedBox(height: 24),
                        // ログインボタン
                        Button(
                            buttonName: "ログイン",
                            onPressedFunction: () => {
                                  _login(_mailAddress, _password, context),
                                }),
                      ],
                    ),
                  ),

                  // 新規登録タブの中身
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 余白
                        const SizedBox(height: 32),
                        // アイコン
                        const AppLogo(),
                        // 余白
                        const SizedBox(height: 24),
                        // メールアドレスの入力欄
                        const Text(
                          'メールアドレス',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SubmitFormWidget(
                          isObscure: false,
                          hintText: "mri.benkyochannel@gmail.com",
                          onSubmitTextChanged: (mailAddress) {
                            setState(() {
                              _mailAddress = mailAddress; // 入力されたメールアドレスを受け取る
                            });
                          },
                        ),
                        const SizedBox(height: 24),
                        // パスワードの入力欄
                        const Text(
                          'パスワード',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SubmitFormWidget(
                          isObscure: true,
                          hintText: "6文字以上の半角英数",
                          onSubmitTextChanged: (password) {
                            setState(() {
                              _password = password; // 入力されたパスワードを受け取る
                            });
                          },
                        ),
                        const SizedBox(height: 24),
                        Button(
                            buttonName: "新規登録",
                            onPressedFunction: () async {
                              _signUp(_mailAddress, _password, context);
                            }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
