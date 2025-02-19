import 'package:bouldering_app/model/boulder.dart';
import 'package:bouldering_app/model/gym.dart';

/// ■ メソッド
/// - ユーザーのホームジム名を表示する
///
/// 引数：
/// - [userRef] ユーザークラスの情報
/// - [gymRef] ジム情報のクラス
String showGymName(Boulder? userRef, Map<int, Gym>? gymRef) {
  String gymName = "登録なし";

  // nullチェック
  // userRef, userRefに登録のhomeGymId, gymRef, gymRef[キー(※nullでない)]で検索したgymName
  // のいずれかがnullであれば，gynNameを「登録なし」とする
  if ((userRef?.homeGymId == null) ||
      ((gymRef?[userRef!.homeGymId]?.gymName) == null)) {
    // DO NOTHING
    // gymName = "登録なし";  と同義
  } else {
    gymName = gymRef![userRef!.homeGymId]!.gymName;
  }

  print("gymName:$gymName");
  return gymName;
}
