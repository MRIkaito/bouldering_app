import 'package:bouldering_app/view/components/boul_log.dart';
import 'package:bouldering_app/view/components/gim_card.dart';
import 'package:bouldering_app/view/components/button.dart';
import 'package:bouldering_app/view/components/this_month_boul_log.dart';
import 'package:bouldering_app/view/components/user_logo_and_name.dart';
import 'package:bouldering_app/view_model/gym_provider.dart';
import 'package:bouldering_app/view_model/user_provider.dart';
import 'package:bouldering_app/view_model/utility/calc_bouldering_duration.dart';
import 'package:bouldering_app/view_model/utility/show_gym_name.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class LoginedMyPage extends ConsumerStatefulWidget {
  const LoginedMyPage({super.key});

  @override
  LoginedMyPageState createState() => LoginedMyPageState();
}

/// ■ クラス
/// - ログインした時のマイページ
class LoginedMyPageState extends ConsumerState<LoginedMyPage> {
  String? cachedBoulLogDuration;

  // 初期化
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final asyncUser = ref.watch(asyncUserProvider);
    final gymRef = ref.read(gymProvider);

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
        body: asyncUser.when(
            error: (err, stack) => const Text("エラーが発生しました"),
            loading: () => const Center(child: CircularProgressIndicator()),
            data: (user) {
              // ボル活歴をキャッシュ
              cachedBoulLogDuration ??= calcBoulderingDuration(user);

              return SafeArea(
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
                              // ユーザ写真・名前欄
                              // TODO：下記、URLを渡す処理をUserLogoAndNameに追加する
                              UserLogoAndName(
                                  userName: user?.userName ?? "名無し"),
                              const SizedBox(height: 16),

                              // ボル活
                              ThisMonthBoulLog(
                                userId: user!.userId,
                                monthsAgo: 0,
                              ), // TODO:nullチェックを確認
                              const SizedBox(height: 8),

                              // お気に入り・お気にいられ欄
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Button(
                                    onPressedFunction: () => {
                                      context.push('/FavoriteUser/favorite'),
                                    },
                                    buttonName: "お気に入り",
                                    buttonWidth:
                                        ((MediaQuery.of(context).size.width) /
                                                2) -
                                            24,
                                    buttonHeight: 36,
                                    buttonColorCode: 0xFFE3DCE4,
                                    buttonTextColorCode: 0xFF000000,
                                  ),
                                  Button(
                                    onPressedFunction: () => {
                                      context.push("/FavoriteUser/favoredBy")
                                    },
                                    buttonName: "お気に入られ",
                                    buttonWidth:
                                        ((MediaQuery.of(context).size.width) /
                                                2) -
                                            24,
                                    buttonHeight: 36,
                                    buttonColorCode: 0xFFE3DCE4,
                                    buttonTextColorCode: 0xFF000000,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // 自己紹介文
                              SizedBox(
                                width: double.infinity,
                                child: Text(
                                  user?.userIntroduce == null
                                      ? " - "
                                      : user!.userIntroduce,
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
                              SizedBox(
                                width: double.infinity,
                                child: Text(
                                  user?.favoriteGym == null
                                      ? " - "
                                      : user!.favoriteGym,
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
                              Row(
                                children: [
                                  SvgPicture.asset(
                                      'lib/view/assets/date_range.svg'),
                                  const SizedBox(width: 8),
                                  const Text("ボルダリング歴："),
                                  Text(cachedBoulLogDuration!),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // ホームジム
                              Row(
                                children: [
                                  SvgPicture.asset(
                                      'lib/view/assets/home_gim_icon.svg'),
                                  const SizedBox(width: 8),
                                  const Text("ホームジム："),
                                  Text(showGymName(user, gymRef)),
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
              );
            }),
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
