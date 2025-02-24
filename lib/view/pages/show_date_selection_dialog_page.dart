import 'package:bouldering_app/view/pages/confirmed_dialog_page.dart';
import 'package:bouldering_app/view_model/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShowDateSelectionDialogPage extends ConsumerStatefulWidget {
  final String title;
  const ShowDateSelectionDialogPage({Key? key, required this.title})
      : super(key: key);

  @override
  _ShowDateSelectionDialogPageState createState() =>
      _ShowDateSelectionDialogPageState();
}

class _ShowDateSelectionDialogPageState
    extends ConsumerState<ShowDateSelectionDialogPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late bool isBoulderingDebut;

  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;
  int _selectedDay = DateTime.now().day;

  // presetDate：更新前の日付
  DateTime presetDate = DateTime.now();
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
    isBoulderingDebut = widget.title == "ボルダリングデビュー日";

    // true: "ボルダリングデビュー日" / false:"生年月日"
    if (isBoulderingDebut) {
      if ((ref.read(userProvider)?.boulStartDate) == null) {
        // 初期値で処理継続する
        // DO NOTHING
      } else {
        presetDate = ref.read(userProvider)!.boulStartDate;
        userId = ref.read(userProvider)!.userId;
        _selectedYear = presetDate.year;
        _selectedMonth = presetDate.month;
        _selectedDay = presetDate.day;
      }
    } else {
      if ((ref.read(userProvider)?.birthday) == null) {
        // 初期値で処理継続する
        // DO NOTHING
      } else {
        presetDate = ref.read(userProvider)!.birthday;
        userId = ref.read(userProvider)!.userId;
        _selectedYear = presetDate.year;
        _selectedMonth = presetDate.month;
        _selectedDay = presetDate.day;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showDatePicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return Container(
          height: MediaQuery.of(context).size.height / 3,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 年ピッカー
              Container(
                width: MediaQuery.of(context).size.width / 3,
                child: CupertinoPicker(
                  itemExtent: 32.0,
                  onSelectedItemChanged: (int index) {
                    setState(() {
                      _selectedYear = 1925 + index;
                    });
                  },
                  children: List<Widget>.generate(
                    (DateTime.now().year - 1924),
                    (int index) {
                      return Center(
                        child: Text('${1925 + index}年'),
                      );
                    },
                  ),
                ),
              ),
              // 月ピッカー
              Container(
                width: MediaQuery.of(context).size.width / 3,
                child: CupertinoPicker(
                  itemExtent: 32.0,
                  onSelectedItemChanged: (int index) {
                    setState(() {
                      _selectedMonth = index + 1;
                    });
                  },
                  children: List<Widget>.generate(
                    12,
                    (int index) {
                      return Center(
                        child: Text('${index + 1}月'),
                      );
                    },
                  ),
                ),
              ),
              // 日ピッカー（ボルダリングデビュー日は日選択なし）
              // if (!isBoulderingDebut)  // TODO：ボルダリングでも選択できるようにするかけんおつ
              Container(
                width: MediaQuery.of(context).size.width / 3,
                child: CupertinoPicker(
                  itemExtent: 32.0,
                  onSelectedItemChanged: (int index) {
                    setState(() {
                      _selectedDay = index + 1;
                    });
                  },
                  children: List<Widget>.generate(
                    31,
                    (int index) {
                      return Center(
                        child: Text('${index + 1}日'),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userNotifier = ref.read(userProvider.notifier);

    String formattedDate = "$_selectedYear年 $_selectedMonth月 $_selectedDay日";

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
                onTap: _showDatePicker,
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
                      // 何年何月の部分
                      Text(
                        formattedDate,
                        style: const TextStyle(fontSize: 18),
                      ),
                      // カレンダーアイコン
                      const Icon(
                        Icons.calendar_today,
                        color: Colors.grey,
                      ),
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
                  final result = await userNotifier.updateDate(
                      presetDate.year,
                      presetDate.month,
                      presetDate.day,
                      _selectedYear,
                      _selectedMonth,
                      _selectedDay,
                      userId,
                      isBoulderingDebut);

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

void showDateSelectionDialog(BuildContext context, String title) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (BuildContext buildContext, Animation animation,
        Animation secondaryAnimation) {
      return Center(
        child: ShowDateSelectionDialogPage(title: title),
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
