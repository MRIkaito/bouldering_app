import 'package:bouldering_app/model/gym.dart';
import 'package:bouldering_app/view/pages/confirmed_dialog_page.dart';
import 'package:bouldering_app/view/pages/gym_search_page.dart';
import 'package:bouldering_app/view_model/gym_provider.dart';
import 'package:bouldering_app/view_model/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

class SelectHomeGymDialogPage extends ConsumerStatefulWidget {
  final String title;
  final String gymName;
  const SelectHomeGymDialogPage(
      {Key? key, required this.title, required this.gymName})
      : super(key: key);

  @override
  _SelectHomeGymDialogPageState createState() =>
      _SelectHomeGymDialogPageState();
}

class _SelectHomeGymDialogPageState
    extends ConsumerState<SelectHomeGymDialogPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  String userId = "";
  String presetGymName = "";
  String displayedGymName = "";
  // ジム名を検索しても見つからないとき用のダミーデータ
  Gym dummyGym = Gym(
    gymName: "-",
    latitude: 0,
    longitude: 0,
    prefecture: "-",
    city: "-",
  );

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
    presetGymName = widget.gymName;
    displayedGymName = widget.gymName;

    if (ref.read(userProvider)?.userId == null) {
      userId = "";
    } else {
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
              GestureDetector(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GymSearchPage()),
                  );
                  if (result != null) {
                    setState(() {
                      displayedGymName = result as String;
                    });
                  }
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        displayedGymName,
                        style: const TextStyle(fontSize: 18),
                      ),
                      SvgPicture.asset('lib/view/assets/date_range.svg'),
                    ],
                  ),
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
                  // ジム名が同じ場合はDBアクセス無し
                  // 補足)
                  // ホームジム選択のみ、フロント側で同じ名前の場合は更新完了として終了するように実装
                  // ∵ 更新前後のホームIDが同じ場合でも、firstWhereの処理を実装することは処理負荷がかかると判断し、実装しない
                  if (presetGymName == displayedGymName) {
                    Navigator.of(context).pop();
                    confirmedDialog(context, true);
                  } else {
                    final gymMap = ref.read(gymProvider);
                    final int updateGymId = gymMap.entries
                        .firstWhere(
                          (entry) => entry.value.gymName == displayedGymName,
                          orElse: () => MapEntry(-1, dummyGym),
                        )
                        .key;
                    final bool result =
                        await userNotifier.updateHomeGym(updateGymId, userId);
                    Navigator.of(context).pop();
                    confirmedDialog(context, result);
                  }
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

void selectHomeGymDialog(BuildContext context, String title, String gymName) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (BuildContext buildContext, Animation animation,
        Animation secondaryAnimation) {
      return Center(
        child: SelectHomeGymDialogPage(title: title, gymName: gymName),
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
