import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// ■ クラス
/// 退会処理を行う
class ShowExitConfirmationDialogPage extends StatefulWidget {
  const ShowExitConfirmationDialogPage({Key? key}) : super(key: key);

  @override
  _ShowExitConfirmationDialogPageState createState() =>
      _ShowExitConfirmationDialogPageState();
}

class _ShowExitConfirmationDialogPageState
    extends State<ShowExitConfirmationDialogPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isChecked = false; // 退会するかチェックを入れるチェックボックスの変数
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordEntered = false; // 入力状態を管理

  @override
  void initState() {
    super.initState();
    _isPasswordEntered = false; // 入力状態を管理
    // ここに，addListenerを追加する必要がある
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
    _passwordController.removeListener(_updatePasswordState);
    _passwordController.dispose();
    super.dispose();
  }

  void _updatePasswordState() {
    setState() {
      _isPasswordEntered = _passwordController.text.isNotEmpty;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: AlertDialog(
        title: const Text('本当に退会しますか？'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('退会後、あなたのデータはすべて消去されます。この操作は取り消せません。'),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              keyboardType: TextInputType.visiblePassword,
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'パスワードを入力してください',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _isChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      _isChecked = value ?? false;
                    });
                  },
                ),
                const Text('退会します'),
              ],
            ),
          ],
        ),
        actions: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'いいえ',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
              TextButton(
                onPressed: (_isChecked && _isPasswordEntered)
                    ? () async {
                        // 0. ログアウト処理を行って, User状態をclearするのが良い？←1. の関数内に作成している

                        // 1. ユーザーアカウントを削除する関数を呼び出す
                        String password = _passwordController.text;
                        await deleteUserAccount(
                          context,
                          password,
                        );

                        // 2. userテーブルのis_deletedフラグをTRUEに更新する(物理削除する野がいいかもしれない)

                        // 3. 削除完了のダイアログを表示←1. の関数内に作成している
                        // 4. unlogined_my_pageに遷移する。← 1. のkン数内に作成している
                      }
                    : null,
                child: Text(
                  'はい',
                  style: _isChecked
                      ? const TextStyle(color: Colors.red)
                      : const TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

void showExitConfirmationDialog(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (BuildContext buildContext, Animation animation,
        Animation secondaryAnimation) {
      return const Center(
        child: ShowExitConfirmationDialogPage(),
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
/// - ユーザーアカウントを消去する関数
///
/// 引数
/// - [context] ウィジェットツリーの情報
Future<bool> deleteUserAccount(BuildContext context, String password) async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("ユーザーがログインしていません")),
    );
    return false;
  }

  try {
    // 1. 必要なら再認証
    final authCredential = EmailAuthProvider.credential(
      email: user.email!,
      password: password,
    );

    // パスワードが異なったらcatch節に行くかを確認する
    await user.reauthenticateWithCredential(authCredential);

    // 2. アカウント削除
    await user.delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("アカウントを削除しました")),
    );

    // 3. ログアウトしてログイン画面に戻す
    await FirebaseAuth.instance.signOut();
    Navigator.of(context)
        .pushReplacementNamed("/login"); // TODO：ここに、画面を戻る処理を適切に入れる
    return true;
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("エラーが発生しました: $e")),
    );
    return false;
  }
}
