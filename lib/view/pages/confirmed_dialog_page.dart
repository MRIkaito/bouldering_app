import 'package:flutter/material.dart';

class ConfirmedDialogPage extends StatefulWidget {
  final bool result;
  final String? message; // カスタムメッセージを受け取る

  const ConfirmedDialogPage(this.result, {Key? key, this.message})
      : super(key: key);

  @override
  _ConfirmedDialogPageState createState() => _ConfirmedDialogPageState();
}

class _ConfirmedDialogPageState extends State<ConfirmedDialogPage>
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
        title: Text(
          widget.message ?? // メッセージが渡されていればそれを表示、なければ下記デフォルトメッセージを表示
              (widget.result
                  ? '登録が完了しました'
                  : '登録に失敗しました\n再度試して同じエラーが生じる場合，お手数ですが運営までお問い合わせください'),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            widget.result
                ? Icon(
                    Icons.check_circle_outline,
                    size: (MediaQuery.of(context).size.width) / 3,
                    color: Colors.green,
                  )
                : Icon(
                    Icons.close,
                    size: (MediaQuery.of(context).size.width) / 3,
                    color: Colors.red,
                  ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // trueを返す
              },
              child: const Text(
                '戻る',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ■ メソッド
/// - 完了/失敗を示す画面を呼び出すメソッド
Future<bool> confirmedDialog(BuildContext context, bool result,
    {String? message}) {
  return showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (BuildContext buildContext, Animation animation,
        Animation secondaryAnimation) {
      return Center(
        child: ConfirmedDialogPage(result, message: message),
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
  ).then((value) => value ?? false);
}
