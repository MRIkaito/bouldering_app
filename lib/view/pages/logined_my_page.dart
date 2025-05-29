import 'package:bouldering_app/view/components/my_tweets_section.dart';
import 'package:bouldering_app/view/components/user_profile_section.dart';
import 'package:bouldering_app/view/components/wanna_go_gyms_section.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// ■ クラス
/// - ログインした時のマイページ
class LoginedMyPage extends StatelessWidget {
  const LoginedMyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFFEF7FF),
        appBar: AppBar(
          // 【必須】戻るボタンを非表示
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFFFEF7FF),
          surfaceTintColor: const Color(0xFFFEF7FF),
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
                const UserProfileSection(),

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
                MyTweetsSection(),
                WannaGoGymsSectrion(),
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
