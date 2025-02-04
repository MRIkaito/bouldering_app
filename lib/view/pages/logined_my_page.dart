import 'package:bouldering_app/view/components/boul_log.dart';
import 'package:bouldering_app/view/components/gim_card.dart';
import 'package:bouldering_app/view/components/button.dart';
import 'package:bouldering_app/view/components/this_month_boul_log.dart';
import 'package:bouldering_app/view/components/user_logo_and_name.dart';
import 'package:bouldering_app/view_model/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

/// ■ クラス
/// - ログインした時のマイページ
class LoginedMyPage extends ConsumerWidget {
  // コンストラクタ
  const LoginedMyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ユーザー情報を取得
    final user = ref.read(userProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          // 【必須】戻るボタンを非表示
          automaticallyImplyLeading: false,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: IconButton(
                  icon: const Icon(Icons.settings, size: 32.0),
                  onPressed: () {
                    context.push('/Setting');
                  }),
            ),
          ],
        ),
        body: SafeArea(
          child: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ユーザ欄
                        // ↓下記、URLを渡す処理をUserLogoAndNameに追加する
                        // 新規追加：UserLogoAndName(userName: user!.userName),
                        const UserLogoAndName(userName: 'ログインユーザ名'),
                        const SizedBox(height: 16),

                        // ボル活
                        // TODO 1：ログインしているユーザーのツイート情報を渡す必要がある
                        // TODO 2：ThisMonthBoulLogに、ユーザーのツイート情報をもらう処理を実装する
                        // TODO 3：SQLで、ツイートを取得する処理を実装する必要がある
                        const ThisMonthBoulLog(),
                        const SizedBox(height: 8),

                        // お気に入り・お気にいられ欄
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Button(
                              onPressedFunction: () => {
                                context.push('/FavoriteUser/favorite'),
                              },
                              buttonName: "お気に入り",
                              buttonWidth:
                                  ((MediaQuery.of(context).size.width) / 2) -
                                      24,
                              buttonHeight: 36,
                              buttonColorCode: 0xFFE3DCE4,
                              buttonTextColorCode: 0xFF000000,
                            ),
                            Button(
                              onPressedFunction: () =>
                                  {context.push("/FavoriteUser/favoredBy")},
                              buttonName: "お気に入られ",
                              buttonWidth:
                                  ((MediaQuery.of(context).size.width) / 2) -
                                      24,
                              buttonHeight: 36,
                              buttonColorCode: 0xFFE3DCE4,
                              buttonTextColorCode: 0xFF000000,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // 自己紹介文
                        Container(
                          width: double.infinity,
                          child: Text(
                            // "今はまだ5級しか登れませんが，将来は1級を登れるようになることが目標です！！よろしくお願いします！",
                            "$user!.self_introduce", // TODO：null値でないことを確認する+null値の時のエラーハンドリングを実装する
                            textAlign: TextAlign.left,
                            softWrap: true,
                            overflow: TextOverflow.visible,
                            maxLines: null,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                              letterSpacing: -0.50,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // 好きなジム欄
                        const Text(
                          "好きなジム",
                          style: TextStyle(
                            color: Color(0xFF8D8D8D),
                            fontSize: 16,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.bold,
                            height: 1.4,
                            letterSpacing: -0.50,
                          ),
                        ),
                        const SizedBox(height: 8),
                        //
                        Container(
                          width: double.infinity,
                          child: Text(
//                             """
// ・Folkボルダリングジム
// ・Dボルダリング綱島
//                             """,
                            user!
                                .favoriteGyms, // TODO：null値でないことを確認する+null値の時のエラーハンドリングを実装する
                            textAlign: TextAlign.left,
                            softWrap: true,
                            overflow: TextOverflow.visible,
                            maxLines: null,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                              letterSpacing: -0.50,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // ボル活歴
                        // boulStartDateから、何年何か月かを計算する処理が必要
                        Row(
                          children: [
                            SvgPicture.asset('lib/view/assets/date_range.svg'),
                            const SizedBox(width: 8),
                            const Text("1年2ヶ月"),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // ホームジム
                        // TODO：utilityに、ジムIDから、なんという名前のジムなのか知る処理を定義する必要がある。
                        Row(
                          children: [
                            SvgPicture.asset(
                                'lib/view/assets/home_gim_icon.svg'),
                            const SizedBox(width: 8),
                            const Text("Folkボルダリングジム"),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                // ボル活・イキタイタブ
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverAppBarDelegate(
                    const TabBar(
                      tabs: [
                        Tab(text: "ボル活"),
                        Tab(text: "イキタイ"),
                      ],
                      labelStyle: TextStyle(
                        color: Color(0xFF0056FF),
                        fontSize: 20,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w900,
                        height: 1.4,
                        letterSpacing: -0.50,
                      ),
                    ),
                  ),
                ),
              ];
            },
            // タブの中に表示する画面
            body: TabBarView(
              children: [
                ListView.builder(
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    return const BoulLog();
                  },
                ),
                ListView.builder(
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    return const GimCard();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: const Color(0xFFFEF7FF),
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
