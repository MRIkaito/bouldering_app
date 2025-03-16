// import 'package:bouldering_app/view_model/auth_provider.dart';
// import 'package:bouldering_app/view_model/user_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:bouldering_app/view/components/boul_log.dart';
// import 'package:bouldering_app/view/components/switcher_tab.dart';
// import 'package:bouldering_app/view_model/boul_log_tweet_view_model.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_svg/svg.dart';

// /// ■ クラス
// /// - View
// /// - ボル活ページを表示する
// // class BoulLogPage extends StatelessWidget {
// class BoulLogPage extends ConsumerWidget {
//   const BoulLogPage({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // インスタンス化
//     final BoulLogTweetViewModel boulLogTweet = BoulLogTweetViewModel();
//     // ログイン状態を監視
//     final isLoggedIn = ref.watch(authProvider);
//     // ユーザー情報を取得
//     final userId = isLoggedIn ? ref.read(userProvider)?.userId : null;
//     // TODO：↑このコードを修正して，ref.readだと，一度読み込んだら終いになってしまう．
//     // そうではなく，これを更新してお気に入りユーザーをひょおお応じするようにする必要がある．

//     print("isLoggedIn: ${isLoggedIn}");
//     print("userId: ${userId}");

//     return DefaultTabController(
//       length: 2,
//       child: Scaffold(
//           body: SafeArea(
//         child: Column(
//           children: [
//             // タブバー
//             const SwitcherTab(leftTabName: "みんなのボル活", rightTabName: "お気に入り"),
//             // タブの中身
//             Expanded(
//               child: TabBarView(
//                 children: [
//                   // (タブ1)みんなのボル活
//                   FutureBuilder<List<dynamic>>(
//                     future: boulLogTweet.fetchDataTweet(),
//                     builder: (BuildContext context,
//                         AsyncSnapshot<List<dynamic>> snapshot) {
//                       // ツイートデータ取得中
//                       if (snapshot.connectionState == ConnectionState.waiting) {
//                         return const Center(child: CircularProgressIndicator());
//                         // ツイート取得失敗
//                       } else if (snapshot.hasError) {
//                         return Center(
//                             child: Text("Errorが発生しました： ${snapshot.error}"));
//                         // ツイート取得成功
//                       } else if (snapshot.hasData) {
//                         final data = snapshot.data!;
//                         return ListView.builder(
//                           itemCount: data.length,
//                           itemBuilder: (context, index) {
//                             final tweet = data[index];
//                             final String userName = tweet['user_name'];
//                             final String gymName = tweet['gym_name'];
//                             final String prefecture = tweet['prefecture'];
//                             // visited_dateをYYYY-MM-DDにフォーマット
//                             final String date =
//                                 DateTime.parse(tweet['visited_date'])
//                                     .toLocal()
//                                     .toString()
//                                     .split(' ')[0];
//                             final String activity = tweet['tweet_contents'];

//                             return BoulLog(
//                               userName: userName,
//                               date: date,
//                               gymName: gymName,
//                               prefecture: prefecture,
//                               activity: activity,
//                             );
//                           },
//                         );
//                       } else {
//                         return const Center(child: Text("データが見つかりませんでした．"));
//                       }
//                     },
//                   ),

//                   // (タブ2)
//                   // ログイン状態(isLoggedIn = true)：お気に入りユーザーのツイートのみ表示
//                   // ログイン状態(isLoggedIn = false)：「イワノボリタイに登録しよう」画面を表示
//                   FutureBuilder<List<dynamic>>(
//                       future: boulLogTweet.fetchDataFavoriteTweet(userId),
//                       builder: isLoggedIn
//                           ? (context, snapshot) {
//                               print("trueです!");
//                               print("userId(boul_log_page.dart): ${userId}");
//                               if (snapshot.connectionState ==
//                                   ConnectionState.waiting) {
//                                 return const Center(
//                                     child: CircularProgressIndicator());
//                               } else if (snapshot.hasError) {
//                                 return Center(
//                                     child: Text(
//                                         "Errorが発生しました: ${snapshot.error}"));
//                               } else if (snapshot.hasData) {
//                                 final favoriteUserData = snapshot.data!;

//                                 return ListView.builder(
//                                     itemCount: favoriteUserData.length,
//                                     itemBuilder: (context, index) {
//                                       final favoriteUserTweet =
//                                           favoriteUserData[index];
//                                       final String favoriteUserName =
//                                           favoriteUserTweet['user_name'];
//                                       final String favoriteGymName =
//                                           favoriteUserTweet['gym_name'];
//                                       final String favoritePrefecture =
//                                           favoriteUserTweet['prefecture'];
//                                       final String favoriteDate =
//                                           DateTime.parse(favoriteUserTweet[
//                                                   'visited_date'])
//                                               .toLocal()
//                                               .toString()
//                                               .split(' ')[0];
//                                       final String favoriteActivity =
//                                           favoriteUserTweet['tweet_contents'];

//                                       return BoulLog(
//                                           userName: favoriteUserName,
//                                           date: favoriteDate,
//                                           gymName: favoriteGymName,
//                                           prefecture: favoritePrefecture,
//                                           activity: favoriteActivity);
//                                     });
//                               } else {
//                                 print("データが見つかっていません！");
//                                 return const Center(
//                                     child: Text("データが見つかりませんでした"));
//                               }
//                             }
//                           : (context, snapshot) {
//                               return Column(
//                                 crossAxisAlignment: CrossAxisAlignment.center,
//                                 children: [
//                                   const SizedBox(height: 32),

//                                   // ロゴ：イワノボリタイ
//                                   Center(
//                                     child: SizedBox(
//                                       width: 72,
//                                       height: 72,
//                                       child: SvgPicture.asset(
//                                         'lib/view/assets/app_main_icon.svg',
//                                       ),
//                                     ),
//                                   ),
//                                   const SizedBox(height: 16),

//                                   // タイトル："イワノボリタイに登録しよう"
//                                   const Center(
//                                     child: Text(
//                                       'イワノボリタイに\n登録しよう',
//                                       textAlign: TextAlign.center, // 真ん中揃え
//                                       style: TextStyle(
//                                         color: Color(0xFF0056FF),
//                                         fontSize: 32,
//                                         fontFamily: 'Roboto',
//                                         fontWeight: FontWeight.w700,
//                                         height: 1.2,
//                                         letterSpacing: -0.50,
//                                       ),
//                                     ),
//                                   ),
//                                   const SizedBox(height: 16),

//                                   // 説明文
//                                   const Text(
//                                     'ログインしてユーザーを\nお気に入り登録しよう!',
//                                     textAlign: TextAlign.center, // 左揃え
//                                     style: TextStyle(
//                                       color: Colors.black,
//                                       fontSize: 20,
//                                       fontFamily: 'Roboto',
//                                       fontWeight: FontWeight.w700,
//                                       height: 1.4,
//                                       letterSpacing: -0.50,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 16),

//                                   // 説明文
//                                   const Text(
//                                     'お気に入り登録したユーザーの\nツイートを見ることができます！',
//                                     textAlign: TextAlign.center, // 左揃え
//                                     style: TextStyle(
//                                       color: Colors.black,
//                                       fontSize: 20,
//                                       fontFamily: 'Roboto',
//                                       fontWeight: FontWeight.w700,
//                                       height: 1.4,
//                                       letterSpacing: -0.50,
//                                     ),
//                                   )
//                                 ],
//                               );
//                             }),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       )),
//     );
//   }
// }

import 'dart:core';
import 'package:bouldering_app/view_model/favorite_user_tweets_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bouldering_app/view/components/boul_log.dart';
import 'package:bouldering_app/view/components/switcher_tab.dart';
import 'package:bouldering_app/view_model/user_provider.dart';
import 'package:bouldering_app/view_model/auth_provider.dart';
import 'package:bouldering_app/view_model/general_tweets_provider.dart';

class BoulLogPage extends ConsumerStatefulWidget {
  const BoulLogPage({super.key});

  @override
  BoulLogPageState createState() => BoulLogPageState();
}

/// ■ クラス
/// - View
/// - ボル活ページを表示する
class BoulLogPageState extends ConsumerState<BoulLogPage> {
  /* ボル活ページ */
  // ボル活ページのスクロールを監視するコントローラ
  final ScrollController _generalTweetsScrollController = ScrollController();

  /* お気に入りユーザ */
  // お気に入りユーザページのスクロールを監視するコントローラ
  final ScrollController _favoriteTweetsScrollController = ScrollController();

  // 初期化
  @override
  void initState() {
    super.initState();

    //　スクロール発生時、_onScroll()を実行するリスナーを追加
    _generalTweetsScrollController.addListener(_onGeneralTweetsScroll);
    _favoriteTweetsScrollController.addListener(_onFavoriteUserTweetsScroll);
  }

  void _onGeneralTweetsScroll() {
    if (_generalTweetsScrollController.position.pixels >
        _generalTweetsScrollController.position.maxScrollExtent - 100) {
      ref.read(generalTweetsProvider.notifier).loadMore();
    }
  }

  void _onFavoriteUserTweetsScroll() {
    if (_favoriteTweetsScrollController.position.pixels >
        _favoriteTweetsScrollController.position.maxScrollExtent - 100) {
      ref.read(favoriteUserTweetsProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    // ログイン状態を監視
    final isLoggedIn = ref.watch(authProvider);
    // ユーザー情報を取得
    final userId = ref.watch(userProvider)?.userId;

    // デバッグ
    print("isLoggedIn: $isLoggedIn");
    print("userId: $userId");

    // 総合ツイート
    // final generalTweets = ref.watch(generalTweetsProvider);
    final generalTweetsState = ref.watch(generalTweetsProvider);
    final generalTweets = generalTweetsState.generalTweets;
    final _hasMoreGeneralTweets = generalTweetsState.hasMore;

    // お気に入りユーザーツイート

    final favoriteUserTweetsState = ref.watch(favoriteUserTweetsProvider);
    final favoriteUserTweets = favoriteUserTweetsState.favoriteUserTweets;
    final _hasMoreFavoriteUserTweets = favoriteUserTweetsState.hasMore;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // タブバー
              const SwitcherTab(leftTabName: "みんなのボル活", rightTabName: "お気に入り"),

              // タブの中身
              Expanded(
                child: TabBarView(
                  children: [
                    // (タブ1) みんなのボル活
                    ListView.builder(
                      controller: _generalTweetsScrollController,
                      itemCount: generalTweets.length +
                          (_hasMoreGeneralTweets ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == generalTweets.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final generalTweet = generalTweets[index];

                        return BoulLog(
                          userName: generalTweet.userName,
                          visitedDate: generalTweet.visitedDate
                              .toLocal()
                              .toIso8601String()
                              .split('T')[0],
                          // DateTime.parse(tweet.visitedDate.toString()).toLocal().toString().split(' ')[0],
                          gymName: generalTweet.gymName,
                          prefecture: generalTweet.prefecture,
                          tweetContents: generalTweet.tweetContents,
                        );
                      },
                    ),

                    // (タブ2) お気に入りユーザーのツイート
                    isLoggedIn
                        ? ListView.builder(
                            controller: _favoriteTweetsScrollController,
                            itemCount: favoriteUserTweets.length +
                                (_hasMoreFavoriteUserTweets ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == favoriteUserTweets.length) {
                                return const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(
                                      child: CircularProgressIndicator()),
                                );
                              }

                              final favoriteUserTweet =
                                  favoriteUserTweets[index];

                              return BoulLog(
                                userName: favoriteUserTweet.userName,
                                visitedDate: favoriteUserTweet.visitedDate
                                    .toLocal()
                                    .toIso8601String()
                                    .split('T')[0],
                                // DateTime.parse(favoriteUserTweet.visitedDate.toString()).toLocal().toString().split(' ')[0],
                                gymName: favoriteUserTweet.gymName,
                                prefecture: favoriteUserTweet.prefecture,
                                tweetContents: favoriteUserTweet.tweetContents,
                              );
                            },
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 32),
                              Center(
                                child: SizedBox(
                                  width: 72,
                                  height: 72,
                                  child: SvgPicture.asset(
                                      'lib/view/assets/app_main_icon.svg'),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Center(
                                child: Text(
                                  'イワノボリタイに\n登録しよう',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFF0056FF),
                                    fontSize: 32,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w700,
                                    height: 1.2,
                                    letterSpacing: -0.50,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'ログインしてユーザーを\nお気に入り登録しよう!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w700,
                                  height: 1.4,
                                  letterSpacing: -0.50,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'お気に入り登録したユーザーの\nツイートを見ることができます！',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w700,
                                  height: 1.4,
                                  letterSpacing: -0.50,
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
