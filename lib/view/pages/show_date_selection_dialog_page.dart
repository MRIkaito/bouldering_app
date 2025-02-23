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
                      _selectedYear = 1900 + index;
                    });
                  },
                  children: List<Widget>.generate(
                    131,
                    (int index) {
                      return Center(
                        child: Text('${1900 + index}年'),
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
              if (!isBoulderingDebut)
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
    final userRef = ref.read(userProvider);

    String formattedDate = isBoulderingDebut
        ? "$_selectedYear年 $_selectedMonth月"
        : "$_selectedYear年 $_selectedMonth月 $_selectedDay日";

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
                      Text(
                        formattedDate,
                        style: const TextStyle(fontSize: 18),
                      ),
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
                onPressed: () {
                  // TODO：下記、適切な名前、引数設定を行う
                  // userRef!.updateBoulStartDate();

                  print(
                      "選択された日付： $_selectedYear-$_selectedMonth-$_selectedDay");
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
