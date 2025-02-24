import 'package:bouldering_app/view/pages/confirmed_dialog_page.dart';
import 'package:bouldering_app/view_model/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GenderSelectionDialogPage extends ConsumerStatefulWidget {
  final String title;
  const GenderSelectionDialogPage({Key? key, required this.title})
      : super(key: key);

  @override
  _GenderSelectionDialogPageState createState() =>
      _GenderSelectionDialogPageState();
}

class _GenderSelectionDialogPageState
    extends ConsumerState<GenderSelectionDialogPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  String? _selectedGender = '未回答';
  String presetGender = "未回答"; // 更新前の性別
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

    if ((ref.read(userProvider)?.gender) == null) {
      _selectedGender = "未回答";
      presetGender = "未回答";
      userId = "";
    } else {
      _selectedGender = _convertGenderCode(ref.read(userProvider)!.gender);
      presetGender = _convertGenderCode(ref.read(userProvider)!.gender);
      userId = ref.read(userProvider)!.userId;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
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
              // ラジオボタン：男性
              RadioListTile<String>(
                title: const Text('男性',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                value: '男性',
                groupValue: _selectedGender,
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
              ),
              // ラジオボタン：女性
              RadioListTile<String>(
                title: const Text('女性',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                value: '女性',
                groupValue: _selectedGender,
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
              ),
              // ラジオボタン：未回答
              RadioListTile<String>(
                title: const Text('未回答',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                value: '未回答',
                groupValue: _selectedGender,
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
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
                  final result = await userNotifier.updateGender(
                      presetGender, (_selectedGender ?? "未回答"), userId);

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

void genderSelectionDialog(BuildContext context, String title) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (BuildContext buildContext, Animation animation,
        Animation secondaryAnimation) {
      return Center(
        child: GenderSelectionDialogPage(title: title),
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

/// ■ メソッド
/// - 性別ごとのコードによって，性別（文字列）を返す
///
/// ・引数
/// - [genderCode] 0, 1, 2のいずれか
/// - 0: 未回答, 1: 男性, 2: 女性
/// - 上記医いずれかの数値でなければ，"未回答"と同様の扱いとする
///
/// ・返り値
/// "未回答", "男性", "女性"のいずれかを返す
String _convertGenderCode(int genderCode) {
  switch (genderCode) {
    case 0:
      return "未回答";
    case 1:
      return "男性";
    case 2:
      return "女性";
    default:
      return "未回答";
  }
}
