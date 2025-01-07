import 'package:bouldering_app/auth_provider.dart';
import 'package:bouldering_app/view/components/app_logo.dart';
import 'package:bouldering_app/view/components/button.dart';
import 'package:bouldering_app/view/components/submit_form.dart';
import 'package:bouldering_app/view/components/switcher_tab.dart';
import 'package:bouldering_app/view_model/utility/show_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginOrSignUpPage extends ConsumerStatefulWidget {
  const LoginOrSignUpPage({super.key});

  @override
  _LoginOrSignUpPageState createState() => _LoginOrSignUpPageState();
}

class _LoginOrSignUpPageState extends ConsumerState<LoginOrSignUpPage> {
  String _password = ''; // パスワードを管理する変数
  String _mailAddress = ''; // メールアドレスを管理する変数

  Future<void> _signUp() async {
    try {
      await ref.read(authProvider.notifier).signUp(_mailAddress, _password);
      if (mounted) {
        context.go("/Unlogined/LoginOrSignUp/Logined");
      }
    } catch (e) {
      if (mounted) {
        showPopup(context, "エラー発生", "登録に失敗しました");
      }
    }
  }
  // void _signUp(
  //     String mailAddress, String password, BuildContext context) async {
  //   if (mailAddress.isEmpty || password.isEmpty) {
  //     showPopup(context, "メールアドレス, またはパスワードが空です", "入力してください");
  //     return;
  //   }

  //   try {
  //     // メールアドレス・パスワードでユーザー登録
  //     final FirebaseAuth auth = FirebaseAuth.instance;
  //     await auth.createUserWithEmailAndPassword(
  //       email: mailAddress,
  //       password: password,
  //     );
  //     context.go("/Unlogined/LoginOrSignUp/Logined");
  //   } catch (e) {
  //     showPopup(context, "エラー発生", "登録に失敗しました");
  //     // print("エラー発生：$e");
  //   }
  // }

  Future<void> _login() async {
    if (_mailAddress.isEmpty || _password.isEmpty) {
      showPopup(context, "メールアドレス, またはパスワードが空です", "入力してください");
      return;
    }

    try {
      await ref.read(authProvider.notifier).login(_mailAddress, _password);
      if (mounted) {
        context.go("/Unlogined/LoginOrSignUp/Logined");
      }
    } catch (e) {
      if (mounted) {
        showPopup(context, "エラー発生", "ログインに失敗しました");
      }
    }
  }
  // void _login(String mailAddress, String password, BuildContext context) async {
  //   if (mailAddress.isEmpty || password.isEmpty) {
  //     showPopup(context, "メールアドレス, またはパスワードが空です", "入力してください");
  //     return;
  //   }

  //   try {
  //     // メールアドレス・パスワードでユーザー登録
  //     final FirebaseAuth auth = FirebaseAuth.instance;
  //     await auth.signInWithEmailAndPassword(
  //       email: mailAddress,
  //       password: password,
  //     );
  //     context.go("/Unlogined/LoginOrSignUp/Logined");
  //   } catch (e) {
  //     showPopup(context, "エラー発生", "ログインに失敗しました");
  //     // print("エラー発生：$e");
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
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
                                    _login(),
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
                                _signUp();
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
    });
  }
}
