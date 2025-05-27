import 'package:bouldering_app/view_model/auth_provider.dart';
import 'package:bouldering_app/view/components/app_logo.dart';
import 'package:bouldering_app/view/components/button.dart';
import 'package:bouldering_app/view/components/submit_form.dart';
import 'package:bouldering_app/view/components/switcher_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginOrSignUpPage extends ConsumerStatefulWidget {
  const LoginOrSignUpPage({super.key});

  @override
  _LoginOrSignUpPageState createState() => _LoginOrSignUpPageState();
}

class _LoginOrSignUpPageState extends ConsumerState<LoginOrSignUpPage> {
  // パスワードを管理する変数
  String _password = '';
  // メールアドレスを管理する変数
  String _mailAddress = '';

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
          ),
          resizeToAvoidBottomInset: true, // キーボード表示時の画面非表示部分を回避
          body: Column(
            children: [
              // タブバー部分
              const SwitcherTab(leftTabName: "ログイン", rightTabName: "新規登録"),

              // タブの内容部分
              Expanded(
                child: TabBarView(
                  children: [
                    // ログインタブの中身
                    SingleChildScrollView(
                      padding: EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: MediaQuery.of(context).viewInsets.bottom +
                            18, // 下部にキーボード高さ分の余白
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 余白
                          const SizedBox(height: 32),

                          // ロゴ
                          const Center(child: AppLogo()),
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
                          // メールアドレス テキストフォーム
                          SubmitFormWidget(
                            isObscure: false,
                            hintText: "boulder@example.com",
                            autofillHints: [AutofillHints.username],
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

                          // パスワードテキストフォーム
                          SubmitFormWidget(
                            isObscure: true,
                            hintText: "6文字以上の半角英数",
                            autofillHints: [AutofillHints.password],
                            onSubmitTextChanged: (password) {
                              setState(() {
                                _password = password; // 入力されたパスワードを受け取る
                              });
                            },
                          ),
                          const SizedBox(height: 24),

                          // ログインボタン
                          Button(
                              buttonName: "ログイン",
                              onPressedFunction: () async => {
                                    await ref.read(authProvider.notifier).login(
                                        context, _mailAddress, _password),
                                  }),
                        ],
                      ),
                    ),

                    // 新規登録タブの中身
                    SingleChildScrollView(
                      padding: EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: MediaQuery.of(context).viewInsets.bottom +
                            18, // 下部にキーボード高さ分の余白
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 余白
                          const SizedBox(height: 32),

                          // アイコン
                          const Center(child: AppLogo()),
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
                            hintText: "boulder@example.com",
                            autofillHints: [AutofillHints.username],
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
                            autofillHints: [AutofillHints.password],
                            onSubmitTextChanged: (password) {
                              setState(() {
                                _password = password; // 入力されたパスワードを受け取る
                              });
                            },
                          ),
                          const SizedBox(height: 8),

                          const Text(
                            'パスワードは下記の条件を満たしてください\n・英大文字/英小文字/数字を1つずつ使用する\n・最低8文字以上',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),

                          Button(
                              buttonName: "新規登録",
                              onPressedFunction: () async {
                                await ref
                                    .read(authProvider.notifier)
                                    .signUp(context, _mailAddress, _password);
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
