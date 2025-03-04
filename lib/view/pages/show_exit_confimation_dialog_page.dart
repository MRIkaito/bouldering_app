import 'package:bouldering_app/view_model/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ■ クラス
/// 退会処理を行う
class ShowExitConfirmationDialogPage extends ConsumerStatefulWidget {
  const ShowExitConfirmationDialogPage({Key? key}) : super(key: key);

  @override
  _ShowExitConfirmationDialogPageState createState() =>
      _ShowExitConfirmationDialogPageState();
}

class _ShowExitConfirmationDialogPageState
    extends ConsumerState<ShowExitConfirmationDialogPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isChecked = false; // 退会するかのチェックを入れるチェックボックス
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordEntered = false; // 入力状態を管理

  @override
  void initState() {
    super.initState();
    _isPasswordEntered = false;
    _passwordController.addListener(_updatePasswordState);
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

  /// 退会処理
  Future<void> _deleteUserAccount(BuildContext context, WidgetRef ref) async {
    await ref
        .read(authProvider.notifier)
        .deleteUserAccount(context, _passwordController.text);
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
              // いいえボタン
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'いいえ',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
              //  はいボタン(退会)
              TextButton(
                onPressed: (_isChecked && _isPasswordEntered)
                    ? () async {
                        await _deleteUserAccount(context, ref);
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
