import 'package:bouldering_app/view/components/other_user_profile_section.dart';
import 'package:bouldering_app/view/components/other_user_tweets_section.dart';
import 'package:bouldering_app/view/components/other_user_wanna_go_gyms_section.dart';
import 'package:flutter/material.dart';

/// ■ クラス
/// - ログインした時のマイページ
class OtherUserPage extends StatelessWidget {
  const OtherUserPage({super.key, required this.userId});

  // プロパティ
  final String userId;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(),
        body: SafeArea(
          child: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return [
                OtherUserProfileSection(userId: userId),

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
            body: const TabBarView(
              children: [
                const Text("テスト1"),
                const Text("テスト2"),
                // OtherUserTweetsSection(),
                // OtherUserWannaGoGymsSectrion(),
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
