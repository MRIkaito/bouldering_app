import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ShowSelfIntroduceFavoriteGimPage extends StatefulWidget {
  final String title;
  const ShowSelfIntroduceFavoriteGimPage({Key? key, required this.title})
      : super(key: key);

  @override
  _ShowSelfIntroduceFavoriteGimPageState createState() =>
      _ShowSelfIntroduceFavoriteGimPageState();
}

class _ShowSelfIntroduceFavoriteGimPageState
    extends State<ShowSelfIntroduceFavoriteGimPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final TextEditingController _nicknameOrSelfIntroduceController =
      TextEditingController();

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
    _nicknameOrSelfIntroduceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  String nicknameOrSelfIntroduce =
                      _nicknameOrSelfIntroduceController.text;
                  print("入力された${widget.title}： $nicknameOrSelfIntroduce");
                  Navigator.of(context).pop();
                  // 必要に応じて登録完了ページに遷移
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
