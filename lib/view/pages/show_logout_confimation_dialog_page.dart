import 'package:bouldering_app/view/pages/login_or_signup_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ShowLogoutConfirmationDialogPage extends StatefulWidget {
  const ShowLogoutConfirmationDialogPage({Key? key}) : super(key: key);

  @override
  _ShowLogoutConfirmationDialogPageState createState() =>
      _ShowLogoutConfirmationDialogPageState();
}

class _ShowLogoutConfirmationDialogPageState
    extends State<ShowLogoutConfirmationDialogPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: AlertDialog(
        title: const Text(
          'ログアウトします\nよろしいですか？',
          textAlign: TextAlign.center,
        ),
        actions: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  // 何もせず，一つ前の画面に戻る
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'いいえ',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    // 退会処理をここに実装
                    await FirebaseAuth.instance.signOut();
                    // すべての画面を取り除き、ログイン画面に戻る
                    // GoRouterの `go` メソッドを使用してログインページへ遷移
                    context.go('/unlogined'); // `UnloginedMyRoute` に対応するパスを指定
                    // // ログイン画面に遷移
                    // Navigator.of(context).pushReplacement(MaterialPageRoute(
                    //     builder: (context) => LoginOrSignUpPage()));
                  } catch (e) {
                    // エラーハンドリング
                    print("ログアウト中にエラーが発生しました: $e");
                  }
                },
                child: const Text('はい', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

void showLogoutConfirmationDialog(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (BuildContext buildContext, Animation animation,
        Animation secondaryAnimation) {
      return const Center(
        child: ShowLogoutConfirmationDialogPage(),
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
