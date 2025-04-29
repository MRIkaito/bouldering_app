import 'package:bouldering_app/view/components/gim_card.dart';
import 'package:bouldering_app/view_model/user_provider.dart';
import 'package:bouldering_app/view_model/utility/is_open.dart';
import 'package:bouldering_app/view_model/wanna_go_relation_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OtherUserWannaGoGymsSectrion extends ConsumerStatefulWidget {
  const OtherUserWannaGoGymsSectrion({super.key});

  @override
  WannaGoGymsSectionState createState() => WannaGoGymsSectionState();
}

class WannaGoGymsSectionState
    extends ConsumerState<OtherUserWannaGoGymsSectrion> {
  /// ■ 初期化
  @override
  initState() {
    super.initState();
  }

  /// ■ dispose
  void dispose() {
    super.dispose();
  }

  /// ■ メソッド
  /// - イキタイ登録したジムを取得する
  Future<void> fetchGymCards() async {
    // ユーザーID
    final userId = ref.read(userProvider)?.userId;
    print("🟡 [DEBUG] user_id before request: $userId");

    // ユーザーID取得できていない時、実行しない
    if (userId == null) {
      print("❌ [ERROR] user_id is null! API リクエストをスキップ");
      return;
    }

    // ジムカード情報取得処理
    await ref
        .read(wannaGoRelationProvider.notifier)
        .fetchWannaGoGymCards(userId);
  }

  /// ■ メソッド
  /// イキタイジムを再取得する
  ///
  /// 引数
  /// - なし
  ///
  /// 返り値
  /// - なし
  Future<void> _refreshWannaGoGyms() async {
    // 今持っているイキタイジムをすべて破棄する
    ref.read(wannaGoRelationProvider.notifier).disposeWannaGoGymCards();

    // イキタイに登録しているジムを新しく取得しなおす
    await fetchGymCards();

    return;
  }

  @override
  Widget build(BuildContext context) {
    // 自分のイキタイ登録しているジム情報
    // ✅ デバッグポイント 1: wannaGoRelationProvider の状態をチェック
    final gymCards = ref.watch(wannaGoRelationProvider);
    print("🟢 [DEBUG] gymCardsのデータ: $gymCards");
    print("🟢 [DEBUG] gymCards.keys: ${gymCards.keys}");
    print("🟢 [DEBUG] gymCards.values.toList(): ${gymCards.values.toList()}");
    print("🟢 [DEBUG] gymCards.length: ${gymCards.length}");

    final gymCardsList = gymCards.values.toList();

    return RefreshIndicator(
      onRefresh: _refreshWannaGoGyms,
      child: ListView.builder(
        key: const PageStorageKey<String>('wanna_go_gyms_section'),
        itemCount: gymCardsList.isEmpty ? 1 : gymCardsList.length,
        itemBuilder: (context, index) {
          // 登録ジムがまだないケース
          if (gymCardsList.isEmpty) {
            return const Center(
              child: Text(
                "登録されているジムがありません。",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final gymCard = gymCardsList[index];
          final Map<String, String> gymOpenHours = {
            'sun_open': gymCard.sunOpen ?? '-',
            'sun_close': gymCard.sunClose ?? '-',
            'mon_open': gymCard.monOpen ?? '-',
            'mon_close': gymCard.monClose ?? '-',
            'tue_open': gymCard.tueOpen ?? '-',
            'tue_close': gymCard.tueClose ?? '-',
            'wed_open': gymCard.wedOpen ?? '-',
            'wed_close': gymCard.wedClose ?? '-',
            'thu_open': gymCard.thuOpen ?? '-',
            'thu_close': gymCard.thuClose ?? '-',
            'fri_open': gymCard.friOpen ?? '-',
            'fri_close': gymCard.friClose ?? '-',
            'sat_open': gymCard.satOpen ?? '-',
            'sat_close': gymCard.satClose ?? '-',
          };

          // TODO：gymPhotosを渡す仕様に変更する
          return GimCard(
            gymName: gymCard.gymName,
            gymPrefecture: gymCard.prefecture,
            ikitaiCount: gymCard.ikitaiCount,
            boulCount: gymCard.boulCount,
            minimumFee: gymCard.minimumFee,
            isBoulderingGym: gymCard.isBoulderingGym,
            isSpeedGym: gymCard.isSpeedGym,
            isLeadGym: gymCard.isLeadGym,
            isOpened: isOpen(gymOpenHours),
          );
        },
      ),
    );
  }
}
