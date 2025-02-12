import 'package:bouldering_app/model/boulder.dart';
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

class LoginedMyPage extends ConsumerStatefulWidget {
  const LoginedMyPage({super.key});

  @override
  LoginedMyPageState createState() => LoginedMyPageState();
}

/// ■ クラス
/// - ログインした時のマイページ
class LoginedMyPageState extends ConsumerState<LoginedMyPage> {
  // TODO：コンストラクタは消去していいのか？確認する
  // コンストラクタ
  // const LoginedMyPage({super.key});

  // 1. 初期化
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // ユーザー情報を取得
    // final user = ref.read(userProvider);
    final asyncUser = ref.watch(asyncUserProvider);

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
          error: (err, stack) => Text("エラーが発生しました"),
          loading: () => Center(child: const CircularProgressIndicator()),
          data: (user) => SafeArea(
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
                              user?.selfIntroduce == null
                                  ? "データが有りません．"
                                  : user!.selfIntroduce,
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
                              user?.favoriteGyms != null
                                  ? user!.favoriteGyms
                                  : "データが有りません",
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
                              SvgPicture.asset(
                                  'lib/view/assets/date_range.svg'),
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
// ------------------------------------------------------------

// import 'package:bouldering_app/model/my_own_tweet.dart';
// import 'package:bouldering_app/view/components/boul_log.dart';
// import 'package:bouldering_app/view/components/gim_card.dart';
// import 'package:bouldering_app/view/components/button.dart';
// import 'package:bouldering_app/view/components/this_month_boul_log.dart';
// import 'package:bouldering_app/view/components/user_logo_and_name.dart';
// import 'package:bouldering_app/view_model/user_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:go_router/go_router.dart';

// import 'package:http/http.dart' as http;
// import 'dart:convert';

// // TODO：当月分のツイートを取得するproviderを定義する
// // ↑そのproviderから、今月分のツイートを取得してきて、それを統計コンポーネントに渡すようにする
// // ↑(つづき)定義したら、そのプロバイダからrefで参照して、それを相手のコンポーネントに渡すようにする

// /// ■ クラス
// /// - ログインページを状態持ちで表示する(ConsumerStatefulWidget)
// class LoginedMyPage extends ConsumerStatefulWidget {
//   const LoginedMyPage({super.key});

//   @override
//   LoginedMyPageState createState() => LoginedMyPageState();
// }

// /// ■ クラス
// /// - ログインした時のマイページ
// class LoginedMyPageState extends ConsumerState<LoginedMyPage> {
//   // 自分のツイート
//   List<MyOwnTweets> allOfMyOwnTweets = [];
//   // ツイートをDBから取得する回数
//   int fetchCount = 0;

//   // 初期化
//   // 1. 一番最初にここの処理が実行される
//   @override
//   void initState() {
//     super.initState();
//     fetchMyOwnTweet();
//   }

//   // 破棄
//   @override
//   // 3. 画面を破棄する処理を記述する
//   // 別のページに遷移する時にここの処理が実行される
//   void dispose() {}

//   Future<void> fetchMyOwnTweet() async {
//     // 手順
//     // DBアクセスしてデータを取得する
//     // 取得したデータを displayMyOwnTweet に代入する
//     // 方針：まずはここに処理をすべて書いてしまって、それを後で別のファイルなどに記載する
//     int requestId = 12;
//     final url = Uri.parse(
//             'https://us-central1-gcp-compute-engine-441303.cloudfunctions.net/getData')
//         .replace(queryParameters: {
//       'request_id': requestId.toString(),
//       'user_id': ref.read(userProvider)!.userId,
//     });

//     try {
//       // HTTP GETリクエスト
//       final response = await http.get(url);

//       // レスポンスボディをJSONとしてDecodeする
//       final List<dynamic> tweetSomeData = jsonDecode(response.body);
//       // デバッグ
//       print(tweetSomeData);
//       final numTweetSomeData = tweetSomeData.length;

//       for (int i = 0; i < numTweetSomeData; i++) {
//         MyOwnTweets oneOfMyOwnTweet = MyOwnTweets();
//         oneOfMyOwnTweet.tweetId = tweetSomeData[i]['tweet_id'];
//         oneOfMyOwnTweet.tweetContents = tweetSomeData[i]['tweet_contents'];
//         oneOfMyOwnTweet.visitedDate =
//             DateTime.parse(tweetSomeData[i]['visited_date'])
//                 .toLocal()
//                 .toString()
//                 .split(' ')[0];
//         oneOfMyOwnTweet.tweetedDate =
//             DateTime.parse(tweetSomeData[i]['tweeted_date'])
//                 .toLocal()
//                 .toString()
//                 .split(' ')[0];
//         oneOfMyOwnTweet.likedCount = tweetSomeData[i]['liked_count'];
//         oneOfMyOwnTweet.movieUrl = tweetSomeData[i]['movie_url'];
//         oneOfMyOwnTweet.userId = tweetSomeData[i]['user_id'];
//         oneOfMyOwnTweet.userName = tweetSomeData[i]['user_name'];
//         oneOfMyOwnTweet.userIconUrl = tweetSomeData[i]['user_icon_url'];
//         oneOfMyOwnTweet.gymId = tweetSomeData[i]['gym_id'];
//         oneOfMyOwnTweet.gymName = tweetSomeData[i]['gym_name'];
//         oneOfMyOwnTweet.prefecture = tweetSomeData[i]['prefecture'];

//         allOfMyOwnTweets.add(oneOfMyOwnTweet);
//       }
//     } catch (error) {
//       print("Errorが発生しました");
//       print(error);
//       throw error;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // ユーザー情報を取得
//     final user = ref.read(userProvider);
//     // ツイート情報を取得
//     // final mypageTweet = ref.read(tweetProvider);

//     return DefaultTabController(
//       length: 2,
//       child: Scaffold(
//         appBar: AppBar(
//           // 戻るボタンを非表示(※外さない)
//           automaticallyImplyLeading: false,
//           actions: [
//             Padding(
//               padding: const EdgeInsets.only(right: 12),
//               child: IconButton(
//                   icon: const Icon(Icons.settings, size: 32.0),
//                   onPressed: () {
//                     context.push('/Setting');
//                   }),
//             ),
//           ],
//         ),
//         body: SafeArea(
//           child: FutureBuilder(
//             // TODO ユーザー情報を取得する、及びツイートを取得するという処理を定義してここに記述する
//             future: null,
//             builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
//               // データ取得
//               if (snapshot.hasData) {
//                 return NestedScrollView(
//                   headerSliverBuilder:
//                       (BuildContext context, bool innerBoxIsScrolled) {
//                     return [
//                       SliverToBoxAdapter(
//                         child: Padding(
//                           padding: const EdgeInsets.all(16.0),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               // TODO：
//                               // ユーザ欄
//                               // ↓下記、URLを渡す処理をUserLogoAndNameに追加する
//                               // 新規追加：UserLogoAndName(userName: user!.userName),
//                               const UserLogoAndName(userName: 'ログインユーザ名'),
//                               const SizedBox(height: 16),

//                               // ボル活
//                               // TODO 1：ログインしているユーザーのツイート情報を渡す必要がある
//                               // TODO 2：ThisMonthBoulLogに、ユーザーのツイート情報をもらう処理を実装する
//                               // TODO 3：SQLで、ツイートを取得する処理を実装する必要がある
//                               const ThisMonthBoulLog(),
//                               const SizedBox(height: 8),

//                               // お気に入り・お気にいられ欄
//                               Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Button(
//                                     onPressedFunction: () => {
//                                       context.push('/FavoriteUser/favorite'),
//                                     },
//                                     buttonName: "お気に入り",
//                                     buttonWidth:
//                                         ((MediaQuery.of(context).size.width) /
//                                                 2) -
//                                             24,
//                                     buttonHeight: 36,
//                                     buttonColorCode: 0xFFE3DCE4,
//                                     buttonTextColorCode: 0xFF000000,
//                                   ),
//                                   Button(
//                                     onPressedFunction: () => {
//                                       context.push("/FavoriteUser/favoredBy")
//                                     },
//                                     buttonName: "お気に入られ",
//                                     buttonWidth:
//                                         ((MediaQuery.of(context).size.width) /
//                                                 2) -
//                                             24,
//                                     buttonHeight: 36,
//                                     buttonColorCode: 0xFFE3DCE4,
//                                     buttonTextColorCode: 0xFF000000,
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(height: 8),

//                               // 自己紹介文
//                               Container(
//                                 width: double.infinity,
//                                 child: Text(
//                                   // TODO：状態として持つ必要があるか？
//                                   // TODO：null値でないことを確認する+null値の時のエラーハンドリングを実装する
//                                   "$user!.self_introduce",
//                                   textAlign: TextAlign.left,
//                                   softWrap: true,
//                                   overflow: TextOverflow.visible,
//                                   maxLines: null,
//                                   style: const TextStyle(
//                                     color: Colors.black,
//                                     fontSize: 16,
//                                     fontFamily: 'Roboto',
//                                     fontWeight: FontWeight.w500,
//                                     height: 1.4,
//                                     letterSpacing: -0.50,
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(height: 12),

//                               // 好きなジム欄
//                               const Text(
//                                 "好きなジム",
//                                 style: TextStyle(
//                                   color: Color(0xFF8D8D8D),
//                                   fontSize: 16,
//                                   fontFamily: 'Roboto',
//                                   fontWeight: FontWeight.bold,
//                                   height: 1.4,
//                                   letterSpacing: -0.50,
//                                 ),
//                               ),
//                               const SizedBox(height: 8),
//                               Container(
//                                 width: double.infinity,
//                                 // TODO：null値でないことを確認する + null値の時のエラーハンドリングを実装する
//                                 child: Text(
//                                   user!.favoriteGyms, // 好きなジムを表示
//                                   textAlign: TextAlign.left,
//                                   softWrap: true,
//                                   overflow: TextOverflow.visible,
//                                   maxLines: null,
//                                   style: const TextStyle(
//                                     color: Colors.black,
//                                     fontSize: 16,
//                                     fontFamily: 'Roboto',
//                                     fontWeight: FontWeight.w500,
//                                     height: 1.4,
//                                     letterSpacing: -0.50,
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(height: 8),

//                               // ボル活歴
//                               // boulStartDateから、何年何か月かを計算する処理が必要
//                               Row(
//                                 children: [
//                                   SvgPicture.asset(
//                                       'lib/view/assets/date_range.svg'),
//                                   const SizedBox(width: 8),
//                                   const Text("1年2ヶ月"),
//                                 ],
//                               ),
//                               const SizedBox(height: 8),

//                               // ホームジム
//                               // TODO：utilityに、ジムIDから、なんという名前のジムなのか知る処理を定義する必要がある。
//                               // ↑ 一番最初のアプリを起動したときに、ジム名を取得する処理を実装してアプリ内部にジム名を保持しておく処理
//                               // があると、検索時にスムーズに検索ができていいと思う。
//                               Row(
//                                 children: [
//                                   SvgPicture.asset(
//                                       'lib/view/assets/home_gim_icon.svg'),
//                                   const SizedBox(width: 8),
//                                   // TODO：ジム名を以下、取得したものを代入する
//                                   const Text("Folkボルダリングジム"),
//                                 ],
//                               ),
//                               const SizedBox(height: 16),
//                             ],
//                           ),
//                         ),
//                       ),

//                       // ボル活・イキタイタブ
//                       SliverPersistentHeader(
//                         pinned: true,
//                         delegate: _SliverAppBarDelegate(
//                           const TabBar(
//                             tabs: [
//                               Tab(text: "ボル活"),
//                               Tab(text: "イキタイ"),
//                             ],
//                             labelStyle: TextStyle(
//                               color: Color(0xFF0056FF),
//                               fontSize: 20,
//                               fontFamily: 'Roboto',
//                               fontWeight: FontWeight.w900,
//                               height: 1.4,
//                               letterSpacing: -0.50,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ];
//                   },

//                   // タブの中に表示する画面
//                   body: TabBarView(
//                     children: [
//                       RefreshIndicator(
//                         onRefresh: () async {},
//                         child: ListView.builder(
//                           itemCount: 4,
//                           itemBuilder: (context, index) {
//                             return const BoulLog();
//                           },
//                         ),
//                       ),
//                       RefreshIndicator(
//                         onRefresh: () async {},
//                         child: ListView.builder(
//                           itemCount: 4,
//                           itemBuilder: (context, index) {
//                             return const GimCard();
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                 );

//                 // データ取得中
//               } else if (snapshot.connectionState == ConnectionState.waiting) {
//                 return CircularProgressIndicator();
//                 // エラー発生
//               } else if (snapshot.hasError) {
//                 return Center(child: Text("Errorが発生しました:${snapshot.error}"));
//                 // データなし
//               } else {
//                 return const Center(
//                     child: Text("データを見つけられませんでした\nもう一度ログインし直してください"));
//               }
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
//   _SliverAppBarDelegate(this._tabBar);

//   final TabBar _tabBar;

//   @override
//   double get minExtent => _tabBar.preferredSize.height;

//   @override
//   double get maxExtent => _tabBar.preferredSize.height;

//   @override
//   Widget build(
//       BuildContext context, double shrinkOffset, bool overlapsContent) {
//     return Container(
//       // TODO：色を変更する(背景色と同じ色へ)
//       color: const Color(0xFFFEF7FF),
//       child: _tabBar,
//     );
//   }

//   @override
//   bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
//     return false;
//   }
// }
