import 'package:intl/intl.dart';

/// ■ メソッド
/// - 現在時刻において、営業中か否かを判別する
bool isOpen(Map<String, String> hours) {
  DateTime now = DateTime.now();
  String currentDay = DateFormat('EEE').format(now).toString().toLowerCase();
  String currentTime = DateFormat('HH:mm:ss').format(now); // 現在の時刻を表す

  // 営業時間を取得
  String openTime = hours['${currentDay}_open']!;
  String closeTime = hours['${currentDay}_close']!;

  if (openTime == '-' || closeTime == '-') {
    return false;
  } else {
    // 営業中か否かを判別
    return ((currentTime.compareTo(openTime) >= 0) &&
        (currentTime.compareTo(closeTime)) <= 0);
  }
}
