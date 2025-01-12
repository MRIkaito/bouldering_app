import 'package:bouldering_app/auth_provider.dart';
import 'package:bouldering_app/view_model/utility/show_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ShowLogoutConfirmationDialogPage extends ConsumerWidget {
  const ShowLogoutConfirmationDialogPage({Key? key}) : super(key: key);

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(authProvider.notifier).logout();

      // ダイアログを閉じてから画面遷移を実行
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
      context.go("/Unlogined");
    } catch (e) {
      showPopup(context, "エラー発生", "登録に失敗しました");
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
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
                await _logout(context, ref);
              },
              child: const Text('はい', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ],
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
