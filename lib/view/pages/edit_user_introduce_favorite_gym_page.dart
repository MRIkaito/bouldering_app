import 'package:bouldering_app/view/pages/confirmed_dialog_page.dart';
import 'package:bouldering_app/view_model/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShowSelfIntroduceFavoriteGimPage extends ConsumerStatefulWidget {
  final String title;
  const ShowSelfIntroduceFavoriteGimPage({Key? key, required this.title})
      : super(key: key);

  @override
  _ShowSelfIntroduceFavoriteGimPageState createState() =>
      _ShowSelfIntroduceFavoriteGimPageState();
}

class _ShowSelfIntroduceFavoriteGimPageState
    extends ConsumerState<ShowSelfIntroduceFavoriteGimPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final TextEditingController _nicknameOrSelfIntroduceController =
      TextEditingController();
  late String pageTitle;
  String preDescription = "";
  String userId = "";

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
    pageTitle = widget.title;

    // 自己紹介ページ
    if (pageTitle == "自己紹介") {
      if ((ref.read(userProvider)?.userIntroduce) == null) {
        _nicknameOrSelfIntroduceController.text = "";
        preDescription = "";
        userId = "";
      } else {
        _nicknameOrSelfIntroduceController.text =
            ref.read(userProvider)!.userIntroduce;
        preDescription = ref.read(userProvider)!.userIntroduce;
        userId = ref.read(userProvider)!.userId;
      }

      // 好きなジムページ
    } else {
      if ((ref.read(userProvider)?.favoriteGym) == null) {
        _nicknameOrSelfIntroduceController.text = "";
        preDescription = "";
        userId = "";
      } else {
        _nicknameOrSelfIntroduceController.text =
            ref.read(userProvider)!.favoriteGym;
        preDescription = ref.read(userProvider)!.favoriteGym;
        userId = ref.read(userProvider)!.userId;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _nicknameOrSelfIntroduceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userNotifier = ref.read(userProvider.notifier);

    return FadeTransition(
      opacity: _animation,
      child: AlertDialog(
        title: Text(
          widget.title,
          textAlign: TextAlign.center,
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8, // 固定幅を設定
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              TextField(
                controller: _nicknameOrSelfIntroduceController,
                keyboardType: TextInputType.multiline,
                maxLines: 4, // 4行分のスペースを設定
                inputFormatters: [
                  LengthLimitingTextInputFormatter(100),
                ],
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '${widget.title}を入力してください',
                ),
              ),
            ],
          ),
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
                onPressed: () async {
                  final result =
                      await userNotifier.updateFavoriteGymsOrUserIntroduce(
                          preDescription,
                          _nicknameOrSelfIntroduceController.text,
                          widget.title,
                          userId);
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

void showSelfIntroduceFavoriteGim(BuildContext context, String title) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (BuildContext buildContext, Animation animation,
        Animation secondaryAnimation) {
      return Center(
        child: ShowSelfIntroduceFavoriteGimPage(title: title),
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
