import 'package:bouldering_app/view/components/boul_log.dart';
import 'package:bouldering_app/view/components/gim_card.dart';
import 'package:bouldering_app/view/components/button.dart';
import 'package:bouldering_app/view/components/this_month_boul_log.dart';
import 'package:bouldering_app/view/components/user_logo_and_name.dart';
import 'package:bouldering_app/view_model/gym_provider.dart';
import 'package:bouldering_app/view_model/my_tweets_provider.dart';
import 'package:bouldering_app/view_model/user_provider.dart';
import 'package:bouldering_app/view_model/utility/calc_bouldering_duration.dart';
import 'package:bouldering_app/view_model/utility/show_gym_name.dart';
import 'package:bouldering_app/view_model/wanna_go_relation_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class LoginedMyPage extends ConsumerStatefulWidget {
  const LoginedMyPage({super.key});

  @override
  LoginedMyPageState createState() => LoginedMyPageState();
}

/// ■ クラス
/// - ログインした時のマイページ
class LoginedMyPageState extends ConsumerState<LoginedMyPage> {
  // ボル活統計情報データ(キャッシュ)
  String? cachedBoulLogDuration;

  // スクロールを監視するコントローラ：ScrollController
  final ScrollController _scrollController = ScrollController();

  // (イキタイジム)内部で状態として、取得したジム情報を管理する
  // final List<GymInfo> _wannaGoGyms = [];
  // (イキタイジム)ロード中かを識別する
  // bool _isGymCardLoading = false;

  /// ■ 初期化
  @override
  void initState() {
    super.initState();

    // ツイート情報を取得
    // userIdは必ず取得されてから遷移するので強制案ラップ
    ref
        .read(myTweetsProvider.notifier)
        .fetchTweets(ref.read(userProvider)!.userId);

    // 自身のイキタイジム情報を取得
    // userIdは必ず取得されてから遷移するので強制アンラップ
    ref
        .read(wannaGoRelationProvider.notifier)
        .fetchWannaGoGymCards(ref.read(userProvider)!.userId);

    // TODO：現在デバッグのためコメントアウト
    // _scrollController.addListener(_onScroll);
  }

  /// ■ 破棄
  @override
  void dispose() {
    _scrollController.dispose(); // ✅ メモリリーク防止
    super.dispose();
  }

  /// ■ メソッド
  /// - ツイートを取得する処理
  Future<void> fetchTweets() async {
    // ユーザーID
    final userId = ref.read(userProvider)?.userId;
    print("🟡 [DEBUG] user_id before request: $userId");

    // ユーザーID取得できていない時、実行しない
    if (userId == null) {
      print("❌ [ERROR] user_id is null! API リクエストをスキップ");
      return;
    }

    // ツイート取得処理
    await ref.read(myTweetsProvider.notifier).fetchTweets(userId);
  }

  // TODO：デバッグ中につきコメントアウト
  // スクロールがif文の条件を満たしたとき, _fetchTweets() を実行
  // void _onScroll() {
  //   if (_scrollController.position.pixels >= // 現在のスクロール位置(上から何ピクセル下にスクロールしたか)
  //       _scrollController.position.maxScrollExtent - 100) {
  //     // スクロールできる最大位置 - 100ピクセル手前
  //     _fetchTweets();
  //   }
  // }

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

  // 現在時刻において、営業中か否かを判別する
  bool isOpen(Map<String, String> hours) {
    DateTime now = DateTime.now();
    String currentDay = DateFormat('EEE').format(now).toString().toLowerCase();
    String currentTime = DateFormat('HH:mm:ss').format(now); // 現在の時刻を表す

    // 営業時間を取得
    String openTime = hours['${currentDay}_open']!;
    String closeTime = hours['${currentDay}_close']!;

    if (openTime == '-' || closeTime == '-') {
      return false;
    } else {
      // 営業中か否かを判別
      return ((currentTime.compareTo(openTime) >= 0) &&
          (currentTime.compareTo(closeTime)) <= 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncUser = ref.watch(asyncUserProvider);
    final gymRef = ref.read(gymProvider);

    // 自分のツイート情報
    final tweets = ref.watch(myTweetsProvider);
    final hasMore = ref.watch(myTweetsProvider.notifier).hasMore;

    // 自分のイキタイ登録しているジム情報
    final gymCards = ref.watch(wannaGoRelationProvider);

    // TODO：デバッグ中につきコメントアウト
    // ref.listen<AsyncValue<Boulder?>>(asyncUserProvider, (previous, next) {
    //   if (next is AsyncData && next.value != null && _tweets.isEmpty) {
    //     print("🟢 [DEBUG] user_id が取得できたので _fetchTweets() を実行！");
    //     _fetchTweets();
    //   }
    // });

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
              if (user != null) {
                setState(() {
                  cachedBoulLogDuration = calcBoulderingDuration(user);
                });
              }

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
                              UserLogoAndName(
                                userName: user?.userName ?? "名無し",
                                userLogo: user?.userIconUrl,
                              ),
                              const SizedBox(height: 16),

                              // ボル活
                              ThisMonthBoulLog(
                                userId: user?.userId,
                                monthsAgo: 0,
                              ),
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
                                  Text(cachedBoulLogDuration ?? " - 年 - か月"),
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
                      tweets.isEmpty
                          ? const Center(child: CircularProgressIndicator())
                          :
                          // 自分のツイート
                          ListView.builder(
                              controller: _scrollController,
                              itemCount: tweets.length + (hasMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == tweets.length) {
                                  return const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Center(
                                        child: CircularProgressIndicator()),
                                  );
                                }

                                final tweet = tweets[index];

                                return BoulLog(
                                  userName: ref.read(userProvider)?.userName ??
                                      ' 取得できませんでした ',
                                  visitedDate: tweet.visitedDate
                                      .toLocal()
                                      .toIso8601String()
                                      .split('T')[0],
                                  // DateTime.parse(tweet.visitedDate.toString()).toLocal().toString().split(' ')[0],
                                  gymName: tweet.gymName,
                                  prefecture: tweet.prefecture,
                                  tweetContents: tweet.tweetContents,
                                );
                              },
                            ),

                      // お気に入り(イキタイ)登録しているジム
                      ListView.builder(
                        itemBuilder: (context, index) {
                          if (index == gymCards.length) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          final gymCard = gymCards[index];

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

                          // TODO：gymPhotosを渡す仕様に変更
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
