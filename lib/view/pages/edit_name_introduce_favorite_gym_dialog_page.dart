import 'package:bouldering_app/view/pages/confirmed_dialog_page.dart';
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
  String preUserName = "";
  String userId = "";

  // 初期化
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
      preUserName = "";
      userId = "";
    } else {
      _nicknameController.text = ref.read(userProvider)!.userName;
      preUserName = ref.read(userProvider)!.userName;
      userId = ref.read(userProvider)!.userId;
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
    final userNotifier = ref.read(userProvider.notifier);

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
              decoration: const InputDecoration(
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
              // 戻る
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
              // 決定
              TextButton(
                child: const Text('決定', style: TextStyle(color: Colors.red)),
                onPressed: () async {
                  // ニックネームを取得し，外部DBに保存する．
                  final result = await userNotifier.updateUserName(
                      preUserName, _nicknameController.text, userId);
                  // 登録完了したら，登録完了/失敗ページに遷移
                  Navigator.of(context).pop();
                  confirmedDialog(context, result);
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
