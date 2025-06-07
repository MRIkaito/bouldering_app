import 'package:bouldering_app/view/pages/confirmed_dialog_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MailAddressConfirmationDialogPage extends StatefulWidget {
  const MailAddressConfirmationDialogPage({Key? key}) : super(key: key);

  @override
  _MailAddressConfirmationDialogPageState createState() =>
      _MailAddressConfirmationDialogPageState();
}

class _MailAddressConfirmationDialogPageState
    extends State<MailAddressConfirmationDialogPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: AlertDialog(
        title: const Text('メールアドレス変更'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('新しいメールアドレスと、パスワードを入力してください'),

            const SizedBox(height: 16),
            // メールアドレス入力フォーム
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '新しいメールアドレス',
              ),
            ),
            const SizedBox(height: 2),

            // パスワード入力フォーム
            TextField(
              controller: _passwordController,
              keyboardType: TextInputType.visiblePassword,
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '現在のパスワード',
              ),
            ),
          ],
        ),
        actions: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 戻る
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  '戻る',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              // 変更
              TextButton(
                onPressed: () async {
                  String email = _emailController.text;
                  String password = _passwordController.text;
                  final resultNo = await updateEmail(context, email, password);

                  if (resultNo == 0) {
                    Navigator.of(context).pop();
                    confirmedDialog(context, true,
                        message: "確認メールを送信しました．リンクをクリックして変更処理してください．");
                  } else if (resultNo == 1) {
                    Navigator.of(context).pop();
                    confirmedDialog(context, false,
                        message: "ログインが正常にできておりませんでした．もう一度ログインしなおして，お試しください．");
                  } else if (resultNo == 2) {
                    Navigator.of(context).pop();
                    confirmedDialog(context, false,
                        message:
                            "メールアドレス更新中にエラーが発生しました．再度お試しいただき，同じエラーが発生する場合は運営までお問い合わせください．");
                  }
                },
                child: const Text('変更', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

void mailAddressConfirmationDialog(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (BuildContext buildContext, Animation animation,
        Animation secondaryAnimation) {
      return const Center(
        child: MailAddressConfirmationDialogPage(),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: animation,
          child: child,
        ),
      );
    },
  );
}

/// ■ メソッド
/// - メールアドレスを更新するメソッド
///
/// 引数
/// - [context] ウィジェットツリー情報
/// - [newEmail] あたらしく登録するメールアドレス
/// - [password] 登録中のパスワード
///
/// 返り値
/// - 0: 確認メールを送信しました．リンクをクリックして確認してください．
/// - 1: ログインが正常にできておりませんでした．もう一度ログインしなおして，お試しください．
/// - 2: メールアドレス更新中にエラーが発生しました．再度お試しいただき，同じエラーが発生する場合，運営までお問い合わせください．
Future<int> updateEmail(
    BuildContext context, String newEmail, String password) async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    return 1;
  }

  try {
    // Firebaseは最近ログインしていないとメール変更を許可しない
    // → 再認証実施
    final credential = EmailAuthProvider.credential(
      email: user.email!, // ここは変更前のメールアドレスを設定
      password: password,
    );

    // 再認証実施
    await user.reauthenticateWithCredential(credential);
    // メールアドレス更新処理
    await user.verifyBeforeUpdateEmail(newEmail);

    return 0;
  } catch (e) {
    return 2;
  }
}
