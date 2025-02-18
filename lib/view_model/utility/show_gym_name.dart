import 'package:bouldering_app/model/boulder.dart';
import 'package:bouldering_app/model/gym.dart';

/// ■ メソッド
/// - ユーザーのホームジム名を表示する
///
/// 引数：
/// - [userRef] ユーザークラスの情報
/// - [gymRef] ジム情報のクラス
String showGymName(Boulder? userRef, Map<int, Gym> gymRef) {
  String gymName = "-";

  // userRef(ユーザーState)とgymRef(ジムState)のnullチェック
  if ((userRef?.homeGymId == null) &&
      ((gymRef[userRef!.homeGymId]?.gymName) == null)) {
    gymName = "-";
  } else {
    gymName = gymRef[userRef!.homeGymId]!.gymName;
  }

  print("gymName:$gymName");
  return gymName;
}
