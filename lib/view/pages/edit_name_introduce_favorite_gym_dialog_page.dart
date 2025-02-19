import 'package:bouldering_app/view/pages/show_mail_address_confirmed_page.dart';
import 'package:bouldering_app/view_model/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class editNameIntroduceFavoriteGymDialogPage extends ConsumerStatefulWidget {
  const editNameIntroduceFavoriteGymDialogPage({Key? key}) : super(key: key);

  @override
  _editNameIntroduceFavoriteGymDialogPageState createState() =>
      _editNameIntroduceFavoriteGymDialogPageState();
}

class _editNameIntroduceFavoriteGymDialogPageState
    extends ConsumerState<editNameIntroduceFavoriteGymDialogPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final TextEditingController _nicknameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    if ((ref.read(userProvider)?.userName) == null) {
      _nicknameController.text = "";
    } else {
      _nicknameController.text = ref.read(userProvider)!.userName;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: AlertDialog(
        title: const Text(
          'ニックネーム',
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            TextField(
              controller: _nicknameController,
              keyboardType: TextInputType.text,
              inputFormatters: [
                LengthLimitingTextInputFormatter(15),
              ],
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: '15文字以内のニックネームを入力',
              ),
            ),
          ],
        ),
        actions: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                child: const Text(
                  '戻る',
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () {
                  // 何もせずに前の画面に戻る
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('決定', style: TextStyle(color: Colors.red)),
                onPressed: () {
                  // ニックネームを取得し，外部DBに保存する．

                  // 仮実装
                  String nickname = _nicknameController.text;
                  print("入力されたニックネーム： $nickname");

                  // 登録完了したら，登録完了ページに遷移
                  Navigator.of(context).pop();
                  showConfirmedDialog(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

void editNameIntroduceFavoriteGymPage(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (BuildContext buildContext, Animation animation,
        Animation secondaryAnimation) {
      return const Center(
        child: editNameIntroduceFavoriteGymDialogPage(),
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
