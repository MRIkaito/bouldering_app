import 'package:bouldering_app/model/boulder.dart';
// import 'package:bouldering_app/model/gym.dart';
import 'package:bouldering_app/model/gym_info.dart';

/// ■ メソッド
/// - ユーザーの登録しているホームジム名を表示する
/// - データ取得中などで，homeGymIdやgymNameがnullのケースは" - "と表記する
///
/// 引数：
/// - [userRef] ユーザークラスの情報
/// - [gymRef] ジム情報のクラス
String showGymName(Boulder? userRef, Map<int, GymInfo>? gymRef) {
  String gymName = " - ";

  // nullチェック
  // userRef, userRefに登録のhomeGymId, gymRef, gymRef[キー(※nullでない)]で検索したgymName
  // いずれかがnullであれば，gynNameを「 - 」とする
  if ((userRef?.homeGymId == null) ||
      ((gymRef?[userRef!.homeGymId]?.gymName) == null)) {
    // DO NOTHING
  } else {
    gymName = gymRef![userRef!.homeGymId]!.gymName;
  }
  return gymName;
}
