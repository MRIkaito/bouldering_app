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
  const LoginOrSignUpPage({Key? key}) : super(key: key);

  @override
  _LoginOrSignUpPageState createState() => _LoginOrSignUpPageState();
}

class _LoginOrSignUpPageState extends State<LoginOrSignUpPage> {
  String _password = ''; // パスワードを管理する変数
  String _mailAddress = ''; // メールアドレスを管理する変数

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
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
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              LoginedMyPage()))
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
                            // onPressedFunction: () => {
                            //       Navigator.push(
                            //       context,
                            //           MaterialPageRoute(
                            //               builder: (context) =>
                            //                   LoginedMyPage()))
                            //     }
                            onPressedFunction: () async {
                              try {
                                // メールアドレス・パスワードでユーザー登録
                                final FirebaseAuth auth = FirebaseAuth.instance;
                                await auth.createUserWithEmailAndPassword(
                                  email: _mailAddress,
                                  password: _password,
                                );
                                // ユーザー登録に成功した時
                                // マイページに遷移+ログイン・サインアップ画面を吐き
                                await Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(builder: (context) {
                                    return LoginedMyPage();
                                  }),
                                );
                              } catch (e) {
                                // ユーザー登録に失敗した場合
                                // 失敗した旨を示すメッセージを表示？
                              }
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


///////////////////////////////////////////////////////
// @RoutePage()
// class LoginOrSignUpPage extends StatelessWidget {
//   const LoginOrSignUpPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 2,
//       child: Scaffold(
//         appBar: AppBar(
//           elevation: 0,
//         ),
//         body: Column(
//           children: [
//             // タブバー部分
//             const SwitcherTab(leftTabName: "ログイン", rightTabName: "新規登録"),

//             // タブの内容部分
//             Expanded(
//               child: TabBarView(
//                 children: [
//                   // ログインタブの中身
//                   Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // 余白
//                         const SizedBox(height: 32),
//                         // ロゴ
//                         const AppLogo(),
//                         // 余白
//                         const SizedBox(height: 24),
//                         // メールアドレスの入力欄
//                         const Text(
//                           'メールアドレス',
//                           style: TextStyle(
//                             color: Colors.black,
//                             fontSize: 18,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         // 余白
//                         const SizedBox(height: 8),
//                         // メールアドレス テキストフォーム
//                         const MailAdressFormWidget(),
//                         // 余白
//                         const SizedBox(height: 24),
//                         // パスワードの入力欄
//                         const Text(
//                           'パスワード',
//                           style: TextStyle(
//                             color: Colors.black,
//                             fontSize: 18,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         // 余白
//                         const SizedBox(height: 8),
//                         // パスワードテキストフォーム
//                         const PasswordForm(),
//                         // 余白
//                         const SizedBox(height: 24),
//                         // ログインボタン
//                         Button(
//                             buttonName: "ログイン",
//                             onPressedFunction: () => {
//                                   Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                           builder: (context) =>
//                                               LoginedMyPage()))
//                                 }),
//                       ],
//                     ),
//                   ),
//                   // 新規登録タブの中身
//                   Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // 余白
//                         const SizedBox(height: 32),
//                         // アイコン
//                         const AppLogo(),
//                         // 余白
//                         const SizedBox(height: 24),
//                         // メールアドレスの入力欄
//                         const Text(
//                           'メールアドレス',
//                           style: TextStyle(
//                             color: Colors.black,
//                             fontSize: 18,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         const MailAdressFormWidget(),
//                         const SizedBox(height: 24),
//                         // パスワードの入力欄
//                         const Text(
//                           'パスワード',
//                           style: TextStyle(
//                             color: Colors.black,
//                             fontSize: 18,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         const PasswordForm(),
//                         const SizedBox(height: 24),
//                         Button(
//                             buttonName: "新規登録",
//                             onPressedFunction: () => {
//                                   Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                           builder: (context) =>
//                                               LoginedMyPage()))
//                                 }),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
