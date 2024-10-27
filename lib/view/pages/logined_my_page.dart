import 'package:bouldering_app/view/components/boul_log.dart';
import 'package:bouldering_app/view/components/gim_card.dart';
import 'package:bouldering_app/view/components/button.dart';
import 'package:bouldering_app/view/components/this_month_boul_log.dart';
import 'package:bouldering_app/view/components/user_logo_and_name.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class LoginedMyPage extends StatelessWidget {
  const LoginedMyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // タブの数(SwitcherTab内のタブ数と一致する)
      child: Scaffold(
        appBar: AppBar(),
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
                        const UserLogoAndName(
                            userName: 'ログインユーザ名'), // 取得したユーザ名を表示
                        const SizedBox(height: 16),

                        // ボル活
                        const ThisMonthBoulLog(), // 各ユーザのボル活を下に計算して表示
                        const SizedBox(height: 8),

                        // お気に入り・お気に入られ
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Button(
                              buttonName: "お気に入り",
                              buttonWidth: 196,
                              buttonHeight: 36,
                              buttonTextColorCode: 0xFF000000,
                            ),
                            Button(
                              buttonName: "お気に入られ",
                              buttonWidth: 196,
                              buttonHeight: 36,
                              buttonTextColorCode: 0xFF000000,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // 自己紹介文
                        // Containerを使用して幅制約を設ける
                        Container(
                          width: double.infinity,
                          child: const Text(
                            // 各ユーザーの紹介文を取得して表示
                            "今はまだ5級しか登れませんが，将来は1級を登れるようになることが目標です！！よろしくお願いします！",
                            textAlign: TextAlign.left,
                            softWrap: true,
                            overflow: TextOverflow.visible,
                            maxLines: null,
                            style: TextStyle(
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
                        Container(
                          width: double.infinity,
                          child: const Text(
                            // 各ユーザーの好きなジムをそのまま表示する
                            """
・Folkボルダリングジム
・Dボルダリング綱島
                            """,
                            textAlign: TextAlign.left,
                            softWrap: true,
                            overflow: TextOverflow.visible,
                            maxLines: null,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                              letterSpacing: -0.50,
                            ),
                          ),
                        ),

                        // ボル活歴
                        Row(children: [
                          SvgPicture.asset(
                            'lib/view/assets/date_range.svg',
                          ),
                          const SizedBox(width: 8),
                          const Text("1年2ヶ月"), // ユーザのボル活歴を取得
                        ]),

                        const SizedBox(height: 8),
                        // ホームジム
                        Row(children: [
                          SvgPicture.asset(
                            'lib/view/assets/home_gim_icon.svg',
                          ),
                          const SizedBox(width: 8),
                          const Text("Folkボルダリングジム") // ユーザのホームジムを取得
                        ]),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
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
            body: TabBarView(
              children: [
                // ボル活タブのコンテンツ例
                // ListView.builder(
                //   itemCount: 20,
                //   itemBuilder: (context, index) {
                //     return ListTile(
                //       title: Text('ボル活のアイテム ${index + 1}'),
                //     );
                //   },
                // ),
                ListView.builder(
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    return const BoulLog();
                  },
                ),
                // イキタイタブのコンテンツ
                // const Center(
                //   child: Text("イキタイのコンテンツがここに表示されます。"),
                // ),

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
      color: Color(0xFFFEF7FF),
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
