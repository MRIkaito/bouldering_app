import 'package:bouldering_app/view/components/app_logo.dart';
import 'package:bouldering_app/view/components/gim_card.dart';
import 'package:bouldering_app/view_model/user_provider.dart';
import 'package:bouldering_app/view_model/utility/is_open.dart';
import 'package:bouldering_app/view_model/wanna_go_relation_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ■ クラス
/// - 自分が登録したイキタイジムを表示するクラス
class WannaGoGymsSectrion extends ConsumerStatefulWidget {
  const WannaGoGymsSectrion({super.key});

  @override
  WannaGoGymsSectionState createState() => WannaGoGymsSectionState();
}

class WannaGoGymsSectionState extends ConsumerState<WannaGoGymsSectrion> {
  // ■ プロパティ
  final ScrollController _scrollController = ScrollController();

  /// ■ 初期化
  @override
  initState() {
    super.initState();
    // 起動時に一度だけジムカードを取得する
    Future.microtask(() async {
      await fetchGymCards();
    });
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
    // print("🟡 [DEBUG] user_id before request: $userId");

    // ユーザーID取得できていない時、実行しない
    if (userId == null) {
      // print("❌ [ERROR] user_id is null! API リクエストをスキップ");
      return;
    }

    // ジムカード情報取得処理
    await ref
        .read(wannaGoRelationProvider.notifier)
        .fetchWannaGoGymCards(userId);
  }

  /// ■ メソッド
  /// イキタイジムを再取得する
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
    final gymCards = ref.watch(wannaGoRelationProvider);
    //【DEBUG】下記エラー表示時に確認するときに使用
    // print("🟢 [DEBUG] gymCardsのデータ: $gymCards");
    // print("🟢 [DEBUG] gymCards.keys: ${gymCards.keys}");
    // print("🟢 [DEBUG] gymCards.values.toList(): ${gymCards.values.toList()}");
    // print("🟢 [DEBUG] gymCards.length: ${gymCards.length}");
    final gymCardsList = gymCards.values.toList();

    return RefreshIndicator(
      onRefresh: _refreshWannaGoGyms,
      child: gymCardsList.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              shrinkWrap: true,
              children: const [
                SizedBox(height: 96),
                AppLogo(),
              ],
            )
          : ListView.builder(
              controller: _scrollController,
              key: const PageStorageKey<String>('wanna_go_gyms_section'),
              itemCount: gymCardsList.isEmpty ? 1 : gymCardsList.length,
              itemBuilder: (context, index) {
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
                  gymId: gymCard.gymId.toString(),
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
