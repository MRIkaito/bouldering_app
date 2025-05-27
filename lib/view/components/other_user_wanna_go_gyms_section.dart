import 'package:bouldering_app/view/components/gim_card.dart';
import 'package:bouldering_app/view_model/other_user_wanna_go_gyms_provider.dart';
import 'package:bouldering_app/view_model/utility/is_open.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ■ クラス
/// - 他のユーザーのイキタイジムを表示するクラス
class OtherUserWannaGoGymsSectrion extends ConsumerStatefulWidget {
  const OtherUserWannaGoGymsSectrion({super.key, required this.userId});
  final String userId;

  @override
  WannaGoGymsSectionState createState() => WannaGoGymsSectionState();
}

class WannaGoGymsSectionState
    extends ConsumerState<OtherUserWannaGoGymsSectrion> {
  /// ■ 初期化
  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(otherUserWannaGoRelationProvider(widget.userId).notifier)
          .fetchGymCards();
    });
  }

  @override
  Widget build(BuildContext context) {
    final gyms = ref.watch(otherUserWannaGoRelationProvider(widget.userId));
    final gymList = gyms.values.toList();

    return RefreshIndicator(
      onRefresh: () async {
        ref
            .read(otherUserWannaGoRelationProvider(widget.userId).notifier)
            .disposeOtherUserGymCards();
        await ref
            .read(otherUserWannaGoRelationProvider(widget.userId).notifier)
            .fetchGymCards();
      },
      child: ListView.builder(
        key: const PageStorageKey<String>('other_user_wanna_go_gyms_section'),
        itemCount: gymList.isEmpty ? 1 : gymList.length,
        itemBuilder: (context, index) {
          // 登録ジムがまだないケース
          if (gymList.isEmpty) {
            return const Center(
              child: Text(
                "登録されているジムがありません。",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final gym = gymList[index];

          final Map<String, String> gymOpenHours = {
            'sun_open': gym.sunOpen ?? '-',
            'sun_close': gym.sunClose ?? '-',
            'mon_open': gym.monOpen ?? '-',
            'mon_close': gym.monClose ?? '-',
            'tue_open': gym.tueOpen ?? '-',
            'tue_close': gym.tueClose ?? '-',
            'wed_open': gym.wedOpen ?? '-',
            'wed_close': gym.wedClose ?? '-',
            'thu_open': gym.thuOpen ?? '-',
            'thu_close': gym.thuClose ?? '-',
            'fri_open': gym.friOpen ?? '-',
            'fri_close': gym.friClose ?? '-',
            'sat_open': gym.satOpen ?? '-',
            'sat_close': gym.satClose ?? '-',
          };

          // TODO：gymPhotosを渡す仕様に変更する
          return GimCard(
            gymId: gym.gymId.toString(),
            gymName: gym.gymName,
            gymPrefecture: gym.prefecture,
            ikitaiCount: gym.ikitaiCount,
            boulCount: gym.boulCount,
            minimumFee: gym.minimumFee,
            isBoulderingGym: gym.isBoulderingGym,
            isSpeedGym: gym.isSpeedGym,
            isLeadGym: gym.isLeadGym,
            isOpened: isOpen(gymOpenHours),
          );
        },
      ),
    );
  }
}
