import 'package:bouldering_app/view/pages/confirmed_dialog_page.dart';
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
            const Text('メールアドレスを変更したい場合は，下記フォームに入力してください'),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'example@gmail.com',
              ),
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
                  '戻る',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              TextButton(
                onPressed: () {
                  // 決定ボタンが押されたときの処理を実装
                  final result = true; //この部分をDB実装したものの結果をもらうように変更する

                  // 仮実装：メールアドレスを取得し，外部DBに保存
                  String email = _emailController.text;
                  print('入力されたメールアドレス: $email');

                  // 登録処理ができたら，登録完了ページに遷移
                  Navigator.of(context).pop();
                  confirmedDialog(context, result);
                },
                child: const Text('決定', style: TextStyle(color: Colors.red)),
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
