import 'package:flutter/material.dart';

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
        title: const Text('本当に退会しますか？'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('退会後、あなたのデータはすべて消去されます。この操作は取り消せません。'),
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
                onPressed: _isChecked
                    ? () {
                        // 退会処理をここに実装
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
