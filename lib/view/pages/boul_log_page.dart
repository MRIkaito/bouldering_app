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
//                               visitedDate: date,
//                               gymName: gymName,
//                               prefecture: prefecture,
//                               tweetContents: activity,
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
//                     future: boulLogTweet.fetchDataFavoriteTweet(userId),
//                     builder: isLoggedIn
//                         ? (context, snapshot) {
//                             print("trueです!");
//                             print("userId(boul_log_page.dart): ${userId}");
//                             if (snapshot.connectionState ==
//                                 ConnectionState.waiting) {
//                               return const Center(
//                                   child: CircularProgressIndicator());
//                             } else if (snapshot.hasError) {
//                               return Center(
//                                   child:
//                                       Text("Errorが発生しました: ${snapshot.error}"));
//                             } else if (snapshot.hasData) {
//                               final favoriteUserData = snapshot.data!;

//                               return ListView.builder(
//                                   itemCount: favoriteUserData.length,
//                                   itemBuilder: (context, index) {
//                                     final favoriteUserTweet =
//                                         favoriteUserData[index];
//                                     final String favoriteUserName =
//                                         favoriteUserTweet['user_name'];
//                                     final String favoriteGymName =
//                                         favoriteUserTweet['gym_name'];
//                                     final String favoritePrefecture =
//                                         favoriteUserTweet['prefecture'];
//                                     final String favoriteDate = DateTime.parse(
//                                             favoriteUserTweet['visited_date'])
//                                         .toLocal()
//                                         .toString()
//                                         .split(' ')[0];
//                                     final String favoriteActivity =
//                                         favoriteUserTweet['tweet_contents'];

//                                     return BoulLog(
//                                         userName: favoriteUserName,
//                                         visitedDate: favoriteDate,
//                                         gymName: favoriteGymName,
//                                         prefecture: favoritePrefecture,
//                                         tweetContents: favoriteActivity);
//                                   });
//                             } else {
//                               print("データが見つかっていません！");
//                               return const Center(
//                                   child: Text("データが見つかりませんでした"));
//                             }
//                           }
//                         : (context, snapshot) {
//                             return Column(
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               children: [
//                                 const SizedBox(height: 32),

//                                 // ロゴ：イワノボリタイ
//                                 Center(
//                                   child: SizedBox(
//                                     width: 72,
//                                     height: 72,
//                                     child: SvgPicture.asset(
//                                       'lib/view/assets/app_main_icon.svg',
//                                     ),
//                                   ),
//                                 ),
//                                 const SizedBox(height: 16),

//                                 // タイトル："イワノボリタイに登録しよう"
//                                 const Center(
//                                   child: Text(
//                                     'イワノボリタイに\n登録しよう',
//                                     textAlign: TextAlign.center, // 真ん中揃え
//                                     style: TextStyle(
//                                       color: Color(0xFF0056FF),
//                                       fontSize: 32,
//                                       fontFamily: 'Roboto',
//                                       fontWeight: FontWeight.w700,
//                                       height: 1.2,
//                                       letterSpacing: -0.50,
//                                     ),
//                                   ),
//                                 ),
//                                 const SizedBox(height: 16),

//                                 // 説明文
//                                 const Text(
//                                   'ログインしてユーザーを\nお気に入り登録しよう!',
//                                   textAlign: TextAlign.center, // 左揃え
//                                   style: TextStyle(
//                                     color: Colors.black,
//                                     fontSize: 20,
//                                     fontFamily: 'Roboto',
//                                     fontWeight: FontWeight.w700,
//                                     height: 1.4,
//                                     letterSpacing: -0.50,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 16),

//                                 // 説明文
//                                 const Text(
//                                   'お気に入り登録したユーザーの\nツイートを見ることができます！',
//                                   textAlign: TextAlign.center, // 左揃え
//                                   style: TextStyle(
//                                     color: Colors.black,
//                                     fontSize: 20,
//                                     fontFamily: 'Roboto',
//                                     fontWeight: FontWeight.w700,
//                                     height: 1.4,
//                                     letterSpacing: -0.50,
//                                   ),
//                                 )
//                               ],
//                             );
//                           },
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       )),
//     );
//   }
// }

///////////////////////////////////////////////////////////////////////////////

import 'dart:core';
import 'package:bouldering_app/view/components/favorite_tweets_section.dart';
import 'package:bouldering_app/view/components/general_tweets_section.dart';
import 'package:flutter/material.dart';
import 'package:bouldering_app/view/components/switcher_tab.dart';

/// ■ クラス
/// - View
/// - ボル活ページを表示する
class BoulLogPage extends StatelessWidget {
  const BoulLogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 2,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // タブバー
              SwitcherTab(leftTabName: "みんなのボル活", rightTabName: "お気に入り"),

              // タブの中身
              Expanded(
                child: TabBarView(
                  children: [
                    // (タブ1) みんなのボル活
                    GeneralTweetsSection(),

                    // (タブ2) お気に入りユーザーのツイート
                    FavoriteTweetsSection(),
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
