import 'package:bouldering_app/view/pages/confirmed_dialog_page.dart';
import 'package:bouldering_app/view_model/utility/is_strong_password.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PasswordUpdateDialogPage extends StatefulWidget {
  const PasswordUpdateDialogPage({Key? key}) : super(key: key);

  @override
  _PasswordUpdateDialogPageState createState() =>
      _PasswordUpdateDialogPageState();
}

class _PasswordUpdateDialogPageState extends State<PasswordUpdateDialogPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

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
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  /// ■ メソッド
  /// - パスワードを更新するメソッド
  ///
  /// 引数
  /// なし
  ///
  /// ※ 下記プロパティを利用する
  /// - [context] ウィジェットツリー情報
  /// - [user.email!] 登録中のメールアドレス
  /// - [_currentPasswordController.text] 古いパスワード
  /// - [_newPasswordController] 新しい（更新したい）パスワード
  ///
  /// 返り値
  /// - [resultMessage]
  /// - 型：Map<String, dynamic>
  /// → キー1(bool) ["result"] ：更新結果が入る(true/ false)
  /// → キー2(String) ["message"]：更新結果のメッセージが入る
  Future<Map<String, dynamic>> _updatePassword() async {
    Map<String, dynamic> resultMessage = {
      "result": true,
      "message": "",
    };

    setState(() => _isLoading = true);

    // 新しいパスワード
    final String newPassword = _newPasswordController.text;

    // 強度チェック
    if (!isStrongPassword(newPassword)) {
      resultMessage["result"] = false;
      resultMessage["message"] = "新しいパスワードが条件を満たしていません。";
      setState(() => _isLoading = false);
      return resultMessage;
    }

    try {
      User? user = _auth.currentUser;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'ユーザーが見つかりません',
        );
      }
      print("email: ${user.email}");

      // 現在のパスワードで再認証
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: _currentPasswordController.text,
      );
      await user.reauthenticateWithCredential(credential);

      // 新しいパスワードを設定
      await user.updatePassword(_newPasswordController.text);

      resultMessage["result"] = true;
      resultMessage["message"] = "パスワードを変更しました";
    } on FirebaseAuthException catch (error) {
      String errorMessage = "パスワード変更に失敗しました";
      if (error.code == 'wront-password') {
        errorMessage = "現在のパスワードが違います";
      } else if (error.code == 'weak-password') {
        errorMessage = "新しいパスワードが脆弱です";
      }

      resultMessage["result"] = false;
      resultMessage["message"] = errorMessage;
    } finally {
      setState(() => _isLoading = false);
    }

    return resultMessage;
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: AlertDialog(
        title: const Text('パスワード変更'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('メールアドレスと古いパスワード、新しいパスワードを入力してください'),
            const SizedBox(height: 16),

            // 古いパスワード入力フォーム
            TextField(
              controller: _currentPasswordController,
              keyboardType: TextInputType.visiblePassword,
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '現在のパスワード',
              ),
            ),
            const SizedBox(height: 2),

            // 新しいパスワード入力フォーム
            TextField(
              controller: _newPasswordController,
              keyboardType: TextInputType.visiblePassword,
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '新しいパスワード',
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'パスワードの条件：\n・8文字以上\n・英大文字・英小文字・数字をそれぞれ1文字以上含めてください',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
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
              // 決定
              TextButton(
                onPressed: _isLoading
                    ? null
                    : () async {
                        final Map<String, dynamic> resultMessage =
                            await _updatePassword();

                        if (resultMessage["result"] == true) {
                          Navigator.of(context).pop();
                          confirmedDialog(
                            context,
                            resultMessage["result"],
                            message: resultMessage["message"],
                          );
                        } else {
                          confirmedDialog(
                            context,
                            resultMessage["result"],
                            message: resultMessage["message"],
                          );
                        }
                      },
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('変更', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

void passwordUpdateDialog(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (BuildContext buildContext, Animation animation,
        Animation secondaryAnimation) {
      return const Center(
        child: PasswordUpdateDialogPage(),
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
