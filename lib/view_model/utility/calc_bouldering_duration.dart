import 'package:bouldering_app/model/boulder.dart';

/// ■ メソッド
/// - ボルダリングの開始年月を返す
/// - userデータやboulStartDateを取得できていない場合は" - 年 - ヶ月"と表記する
///
/// 引数：
/// - [user] ユーザークラス情報
String calcBoulderingDuration(Boulder? user) {
  // nullチェック
  if (user?.boulStartDate == null) {
    return " - 年 - か月";
  } else {
    // ボル活開始日
    DateTime boulStartDate = user!.boulStartDate;
    // 現在時刻
    DateTime now = DateTime.now();
    // 経過時間を計算(年・月)
    int years = now.year - boulStartDate.year;
    int months = now.month - boulStartDate.month;

    // 月がマイナスの場合、1年引いて、+12か月する
    if (months < 0) {
      years -= 1;
      months += 12;
    }
    print("${years}年 ${months}か月");
    return "$years年 $monthsか月";
  }
}
