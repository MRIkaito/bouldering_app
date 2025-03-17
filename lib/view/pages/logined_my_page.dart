import 'package:bouldering_app/model/boul_log_tweet.dart';
import 'package:bouldering_app/model/boulder.dart';
import 'package:bouldering_app/model/gym_info.dart';
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
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class LoginedMyPage extends ConsumerStatefulWidget {
  const LoginedMyPage({super.key});

  @override
  LoginedMyPageState createState() => LoginedMyPageState();
}

/// ■ クラス
/// - ログインした時のマイページ
class LoginedMyPageState extends ConsumerState<LoginedMyPage> {
  String? cachedBoulLogDuration;

  // スクロールを監視するコントローラ：ScrollController
  final ScrollController _scrollController = ScrollController();
  // 内部で状態として取得したツイートを管理する
  final List<BoulLogTweet> _tweets = [];
  // ロード中かを識別する
  bool _isLoading = false;
  // データをDBからまだ取得できるかを判別する
  bool _hasMore = true;

  // (イキタイジム)内部で状態として、取得したジム情報を管理する
  final List<GymInfo> _wannaGoGyms = [];
  // (イキタイジム)ロード中かを識別する
  bool _isGymCardLoading = false;

  // 初期化
  @override
  void initState() {
    super.initState();
    // _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose(); // ✅ メモリリーク防止
    super.dispose();
  }

  Future<void> _fetchTweets() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);
    print(
        "🟢 [DEBUG] _fetchTweets() called. isLoading: $_isLoading, hasMore: $_hasMore");

    // ✅ 🌟 user_id が null でないことを確認
    final userId = ref.watch(userProvider)?.userId;
    print("🟡 [DEBUG] user_id before request: $userId");

    if (userId == null) {
      print("❌ [ERROR] user_id is null! API リクエストをスキップ");
      setState(() => _isLoading = false);
      return;
    }

    final String? cursor =
        _tweets.isNotEmpty ? _tweets.last.tweetedDate.toString() : null;
    final url = Uri.parse(
            'https://us-central1-gcp-compute-engine-441303.cloudfunctions.net/getData')
        .replace(queryParameters: {
      'request_id': '12',
      'limit': '20',
      if (cursor != null) 'cursor': cursor,
      'user_id': userId,
    });

    try {
      final response = await http.get(url);
      print("🟣 [DEBUG] Response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        print("🟢 [DEBUG] Response body: $jsonData");

        final List<BoulLogTweet> newTweets = jsonData
            .map((tweet) => BoulLogTweet(
                  tweetId: tweet['tweet_id'],
                  tweetContents: tweet['tweet_contents'],
                  visitedDate: DateTime.tryParse(tweet['visited_date'] ?? '') ??
                      DateTime.now(),
                  tweetedDate: DateTime.tryParse(tweet['tweeted_date'] ?? '') ??
                      DateTime.now(),
                  likedCount: tweet['liked_count'],
                  movieUrl: tweet['movie_url'],
                  userId: tweet['user_id'],
                  userName: tweet['user_name'],
                  gymId: tweet['gym_id'],
                  gymName: tweet['gym_name'],
                  prefecture: tweet['prefecture'],
                ))
            .toList();

        if (mounted) {
          setState(() {
            _tweets.addAll(newTweets);
            _hasMore = newTweets.length >= 20;
          });
        }
      } else {
        print(
            "❌ [ERROR] Failed to fetch tweets. Status: ${response.statusCode}");
        print("❌ [ERROR] Response body: ${response.body}");
      }
    } catch (error) {
      print("❌ [ERROR] Exception in _fetchTweets(): $error");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      print("🟢 [DEBUG] _fetchTweets() finished. isLoading: $_isLoading");
    }
  }

  // スクロールがif文の条件を満たしたとき, _fetchTweets() を実行
  // void _onScroll() {
  //   if (_scrollController.position.pixels >= // 現在のスクロール位置(上から何ピクセル下にスクロールしたか)
  //       _scrollController.position.maxScrollExtent - 100) {
  //     // スクロールできる最大位置 - 100ピクセル手前
  //     _fetchTweets();
  //   }
  // }

  Future<void> _fetchGymCards() async {
    if (_isGymCardLoading) return;

    setState(() => _isGymCardLoading = true);
    print(
        "[DEBUG] _fetchGymCards() called. isGymCardLoading: $_isGymCardLoading");

    final url = Uri.parse(
            'https://us-central1-gcp-compute-engine-441303.cloudfunctions.net/getData')
        .replace(queryParameters: {
      'request_id': '23',
      'user_id': ref.watch(userProvider)?.userId, // 追加（重要）
    });

    print("[DEBUG] Fetching gym cards from: $url");

    try {
      final response = await http.get(url);
      print("[DEBUG] Response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        print("[DEBUG] Gym cards fetched: $jsonData");

        final List<GymInfo> newGymCards = jsonData
            .map((gymCard) => GymInfo(
                  gymId: int.tryParse(gymCard['gym_id']) ?? 0,
                  gymName: gymCard['gym_name'] ?? '',
                  hpLink: gymCard['hp_link'] ?? '',
                  prefecture: gymCard['prefecture'] ?? '',
                  city: gymCard['city'] ?? '',
                  addressLine: gymCard['address_line'] ?? '',
                  latitude:
                      double.tryParse(gymCard['latitude'].toString()) ?? 0.0,
                  longitude:
                      double.tryParse(gymCard['longitude'].toString()) ?? 0.0,
                  telNo: gymCard['tel_no'] ?? '',
                  fee: gymCard['fee'] ?? '',
                  minimumFee: int.tryParse(gymCard['minimum_fee']) ?? 0,
                  equipmentRentalFee: gymCard['equipment_rental_fee'] ?? '',
                  ikitaiCount: int.tryParse(gymCard['ikitai_count']) ?? 0,
                  boulCount: int.tryParse(gymCard['boul_count']) ?? 0,
                  isBoulderingGym: gymCard['is_bouldering_gym'] == 'true',
                  isLeadGym: gymCard['is_lead_gym'] == 'true',
                  isSpeedGym: gymCard['is_speed_gym'] == 'true',
                  sunOpen: gymCard['sun_open'] ?? '-',
                  sunClose: gymCard['sun_close'] ?? '-',
                  monOpen: gymCard['mon_open'] ?? '-',
                  monClose: gymCard['mon_close'] ?? '-',
                  tueOpen: gymCard['tue_open'] ?? '-',
                  tueClose: gymCard['tue_close'] ?? '-',
                  wedOpen: gymCard['wed_open'] ?? '-',
                  wedClose: gymCard['wed_close'] ?? '-',
                  thuOpen: gymCard['thu_open'] ?? '-',
                  thuClose: gymCard['thu_close'] ?? '-',
                  friOpen: gymCard['fri_open'] ?? '-',
                  friClose: gymCard['fri_close'] ?? '-',
                  satOpen: gymCard['sat_open'] ?? '-',
                  satClose: gymCard['sat_close'] ?? '-',
                ))
            .toList();

        setState(() {
          _wannaGoGyms.addAll(newGymCards);
        });

        print("[DEBUG] Gym cards fetched. Total count: ${_wannaGoGyms.length}");
      } else {
        print(
            "[ERROR] Failed to fetch gym cards. Status: ${response.statusCode}");
        print("[ERROR] Response body: ${response.body}");
      }
    } catch (error) {
      print("[ERROR] Exception in _fetchGymCards(): $error");
    } finally {
      setState(() => _isGymCardLoading = false);
      print(
          "[DEBUG] _fetchGymCards() finished. isGymCardLoading: $_isGymCardLoading");
    }
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

    ref.listen<AsyncValue<Boulder?>>(asyncUserProvider, (previous, next) {
      if (next is AsyncData && next.value != null && _tweets.isEmpty) {
        print("🟢 [DEBUG] user_id が取得できたので _fetchTweets() を実行！");
        _fetchTweets();
      }
    });

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

              if (user != null && _tweets.isEmpty) {
                print("🟢 [DEBUG] 初回の _fetchTweets() を実行！");
                _fetchTweets();
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
                      _tweets.isEmpty
                          ? const Center(child: CircularProgressIndicator())
                          :
                          // 自分のツイート
                          ListView.builder(
                              controller: _scrollController,
                              itemCount: _tweets.length + (_hasMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == _tweets.length) {
                                  return const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Center(
                                        child: CircularProgressIndicator()),
                                  );
                                }

                                final tweet = _tweets[index];

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
                          if (index == _wannaGoGyms.length) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          final gymCard = _wannaGoGyms[index];

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
