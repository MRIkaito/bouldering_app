import 'package:bouldering_app/model/gym_info.dart';
import 'package:bouldering_app/view/components/gim_card.dart';
import 'package:bouldering_app/view_model/utility/is_open.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SearchedGimListPage extends StatelessWidget {
  const SearchedGimListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final gyms = GoRouterState.of(context).extra as List<GymInfo>?;

    if (gyms == null || gyms.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("該当するジムはありません")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("検索結果"),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 16),
        children: [
          // ■ 上のUI（検索条件など）
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TODO
                // 250517記載：退会機能は後に実装予定
                /*
                // IconButton(
                //   icon: const Icon(Icons.tune),
                //   onPressed: () {},
                // ),
                // Container(
                //   padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
                //   child: const Text("神奈川県のジム施設"),  // TODO：検索対象の県名を出力するよう変更
                // ),
                // Container(
                //   height: 36,
                //   padding: const EdgeInsets.only(left: 16, right: 4),
                //   decoration: BoxDecoration(
                //     color: const Color(0xFFEEEEEE),
                //     borderRadius: BorderRadius.circular(8),
                //   ),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       const Text(
                //         "300件",
                //         style: TextStyle(
                //           fontSize: 16,
                //           fontWeight: FontWeight.w400,
                //         ),
                //       ),
                //       Row(
                //         children: [
                //           const Text(
                //             "↑↓",
                //             style: TextStyle(
                //               fontSize: 20,
                //               color: Colors.blue,
                //               fontWeight: FontWeight.w900,
                //             ),
                //           ),
                //           TextButton(
                //             onPressed: () {},
                //             child: const Text(
                //               "イキタイ多い順",
                //               style: TextStyle(
                //                 fontSize: 16,
                //                 color: Colors.blue,
                //                 fontWeight: FontWeight.w900,
                //               ),
                //             ),
                //           ),
                //         ],
                //       ),
                //     ],
                //   ),
                // ),
                */
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ■ ジムリスト（.mapで展開）
          ...gyms.map((gym) {
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

            return GimCard(
              gymId: gym.gymId.toString(),
              gymName: gym.gymName,
              gymPrefecture: gym.prefecture,
              ikitaiCount: gym.ikitaiCount,
              boulCount: gym.boulCount,
              minimumFee: gym.minimumFee,
              isBoulderingGym: gym.isBoulderingGym,
              isLeadGym: gym.isLeadGym,
              isSpeedGym: gym.isSpeedGym,
              isOpened: isOpen(gymOpenHours),
              gymPhotos: gym.gymPhotos ?? [],
            );
          }).toList(),
        ],
      ),
    );
  }
}
