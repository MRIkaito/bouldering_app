// import 'package:bouldering_app/view/components/boul_log.dart';
// import 'package:bouldering_app/view/components/gim_category.dart';
// import 'package:bouldering_app/view/components/switcher_tab.dart';
// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';

// class FacilityInfoPage extends StatelessWidget {
//   const FacilityInfoPage({Key? key}) : super(key: key);

//   Future<void> _launchUrl(String url) async {
//     if (await canLaunch(url)) {
//       await launch(url);
//     } else {
//       throw 'Could not launch $url';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 2,
//       child: Scaffold(
//         appBar: AppBar(
//           elevation: 0,
//           backgroundColor: Colors.white,
//           foregroundColor: Colors.black,
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back),
//             onPressed: () {
//               Navigator.pop(context);
//             },
//           ),
//         ),
//         body: Stack(
//           children: [
//             // SwitcherTabの下に中身のスクロール部分を配置
//             Positioned(
//               top: 0, // SwitcherTabのheight分を調整
//               left: 0,
//               right: 0,
//               child: Container(
//                 color: Colors.white,
//                 child: const SwitcherTab(
//                     leftTabName: "施設情報",
//                     rightTabName: "ボル活",
//                     colorCode: 0xFFFFFFFF),
//               ),
//             ),

//             // コンテンツ部分
//             Padding(
//               padding: const EdgeInsets.only(
//                   top: kToolbarHeight), // AppBarとSwitherTabの高さを加味した値
//               child: TabBarView(children: [
//                 SingleChildScrollView(
//                   padding:
//                       const EdgeInsets.fromLTRB(16, 16, 16, 80), // 下部に余白を追加
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // タイトルとタグ
//                       const Text(
//                         'Folkボルダリングジム',
//                         style: TextStyle(
//                             fontSize: 24, fontWeight: FontWeight.bold),
//                       ),

//                       const Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           GimCategory(
//                             gimCategory: 'ボルダリング',
//                             colorCode: 0xFFF44336,
//                           ),
//                           SizedBox(height: 8),
//                           GymIkitaiBoullogCount(
//                               ikitaiCount: '200', boullogCount: '400'),
//                         ],
//                       ),
//                       const SizedBox(height: 8),

//                       // ギャラリー
//                       SizedBox(
//                         height: 100, // ギャラリーの高さ
//                         child: ListView.builder(
//                           scrollDirection: Axis.horizontal, // 横スクロール
//                           itemCount: 5, // 画像の枚数←外部DBから取得した枚数にする
//                           itemBuilder: (context, index) {
//                             return Padding(
//                               padding: const EdgeInsets.only(right: 8),
//                               child: _buildImage(
//                                   'lib/view/assets/gym_facilitation.png'),
//                             );
//                           },
//                         ),
//                       ),
//                       const SizedBox(height: 16),

//                       // 基本情報
//                       const Text(
//                         '基本情報',
//                         style: TextStyle(
//                             fontSize: 20, fontWeight: FontWeight.bold),
//                       ),
//                       _buildInfoRow('住所', '神奈川県横浜市港北新羽町５７６－１'),
//                       _buildInfoRow('TEL', 'ー'),
//                       _buildInfoRow(
//                         'HP',
//                         'https://folkboulderinggym.com/',
//                         isLink: true,
//                         onTap: () =>
//                             _launchUrl('https://folkboulderinggym.com/'),
//                       ),
//                       _buildInfoRow('定休日', 'なし'),
//                       _buildInfoRow(
//                         '営業時間',
//                         '月曜日 14:00〜22:30\n火曜日 14:00〜22:30\n水曜日 14:00〜22:30\n木曜日 18:00〜22:30\n金曜日 14:00〜22:30\n土曜日 10:00〜20:00\n日曜日 10:00〜20:00',
//                       ),
//                       const SizedBox(height: 16),

//                       // 支払い方法
//                       _buildSectionTitle('支払い方法'),
//                       const Text('◯ 現金\n◯ クレジットカード\n◯ 電子マネー（Paypay）'),

//                       const SizedBox(height: 16),

//                       // 料金情報
//                       _buildSectionTitle('料金'),
//                       const Text(
//                         '20歳以上 会員登録：1,500円\n20歳以上2時間：1,700円\n20歳以上1日利用：1,900円\n\n'
//                         '中学生〜19歳会員登録：1,500円\n中学生〜19歳2時間：1,500円\n中学生〜19歳1日：1,700円\n\n'
//                         '4歳から小学生会員登録：1,500円\n4歳から小学生2時間：1,000円\n4歳から小学生1日：1,500円\n\n'
//                         'その他\n4歳から小学生1時間体験利用：1,200円\n※4歳から小学生限定プラン\n※レンタルシューズ代込み\n\n'
//                         'OYAKO体験利用：2,500円/1時間\n※大人1名+子ども1名\n※大人追加+1,300円/1時間\n※利用時間の延長はできません\n\n'
//                         'キッズスクール：12,000円(30DAYS)\n※小学生のみ\n※毎週、月・水・金 17:00〜18:00のクライミングスクール\n'
//                         '30DAYS PASS付き\n※人数上限があるため、気になる方はお問い合わせください。\n\n'
//                         '30DAYS PASS\n一般：14,000円\n※7日以内の更新で、更新ごとに1,000円OFF。割引額最大12,000円\n'
//                         '中学生〜19歳：12,000円\n4歳〜小学生：10,000円\n\n'
//                         'PUNCH TICKET\n購入日から半年間有効の10回利用回数券。シェアOK\n一般：17,000円\n中学生〜19歳：15,000円\n\n'
//                         'レンタル\nシューズ：400円\n※靴下の着用が必要となります\nチョーク：200円\n\n'
//                         'その他\n会員カード再発行：500円\n',
//                       ),
//                       const SizedBox(height: 16),

//                       // 設備情報
//                       _buildSectionTitle('設備'),
//                       const Text('◯ 駐車場（1台）'),
//                     ],
//                   ),
//                 ),

//                 // 施設名と同じ名称のボル活を時系列順に表示する予定
//                 ListView.builder(
//                   itemCount: 5,
//                   itemBuilder: (context, index) {
//                     return const BoulLog();
//                   },
//                 ),
//               ]),
//             ),

//             // 下部固定のボタン
//             Positioned(
//               bottom: 0,
//               left: 0,
//               right: 0,
//               child: Container(
//                 padding: const EdgeInsets.all(16),
//                 color: Colors.transparent,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     OutlinedButton(
//                       onPressed: () {
//                         // イキタイボタンの処理
//                       },
//                       style: OutlinedButton.styleFrom(
//                         backgroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(horizontal: 32),
//                         side: const BorderSide(color: Colors.blue),
//                       ),
//                       child: const Text('イキタイ',
//                           style: TextStyle(
//                             color: Colors.blue,
//                           )),
//                     ),
//                     ElevatedButton(
//                       onPressed: () {
//                         // ボル活投稿ボタンの処理
//                       },
//                       style: ElevatedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(horizontal: 32),
//                         backgroundColor: Colors.blue,
//                       ),
//                       child: const Text('ボル活投稿',
//                           style: TextStyle(color: Colors.white)),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // 各種ウィジェットビルドメソッド
//   Widget _buildTab(String title, bool isSelected) {
//     return Column(
//       children: [
//         Text(
//           title,
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             color: isSelected ? Colors.blue : Colors.black,
//           ),
//         ),
//         if (isSelected)
//           const Divider(
//             thickness: 2,
//             color: Colors.blue,
//           ),
//       ],
//     );
//   }

//   Widget _buildTag(String text, {Color color = Colors.grey}) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: color,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Text(
//         text,
//         style:
//             const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//       ),
//     );
//   }

//   Widget _buildCounter(String label, String count) {
//     return Row(
//       children: [
//         Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
//         const SizedBox(width: 4),
//         Text(count,
//             style: const TextStyle(
//                 color: Colors.blue, fontWeight: FontWeight.bold)),
//       ],
//     );
//   }

//   Widget _buildImage(String imagePath) {
//     return Container(
//       width: 150,
//       height: 100,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(8),
//         image: DecorationImage(
//           image: AssetImage(imagePath),
//           fit: BoxFit.cover,
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoRow(String label, String value,
//       {bool isLink = false, VoidCallback? onTap}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//               width: 80,
//               child: Text(label,
//                   style: const TextStyle(fontWeight: FontWeight.bold))),
//           const SizedBox(width: 8),
//           Expanded(
//             child: GestureDetector(
//               onTap: isLink ? onTap : null,
//               child: Text(
//                 value,
//                 style: TextStyle(color: isLink ? Colors.blue : Colors.black),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSectionTitle(String title) {
//     return Text(
//       title,
//       style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//     );
//   }
// }

// class GymIkitaiBoullogCount extends StatelessWidget {
//   final String ikitaiCount;
//   final String boullogCount;

//   const GymIkitaiBoullogCount({
//     Key? key,
//     required this.ikitaiCount,
//     required this.boullogCount,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey),
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           // イキタイ部分
//           Text(
//             'イキタイ ',
//             style: const TextStyle(fontWeight: FontWeight.bold),
//           ),
//           Text(
//             ikitaiCount,
//             style: const TextStyle(
//               color: Colors.blue,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(width: 8),
//           // 区切り線
//           Container(
//             width: 1,
//             height: 16,
//             color: Colors.grey,
//           ),
//           const SizedBox(width: 8),
//           // ボル活部分
//           Text(
//             'ボル活 ',
//             style: const TextStyle(fontWeight: FontWeight.bold),
//           ),
//           Text(
//             boullogCount,
//             style: const TextStyle(
//               color: Colors.blue,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bouldering_app/view/components/boul_log.dart';
import 'package:bouldering_app/view/components/gim_category.dart';
import 'package:bouldering_app/view/components/switcher_tab.dart';
import 'package:bouldering_app/view_model/auth_provider.dart';
import 'package:bouldering_app/view_model/specific_gym_tweets_provider.dart';
import 'package:bouldering_app/view_model/user_provider.dart';
import 'package:bouldering_app/view_model/facility_info_provider.dart';

class FacilityInfoPage extends ConsumerStatefulWidget {
  final String gymId;
  const FacilityInfoPage({
    Key? key,
    required this.gymId,
  }) : super(key: key);

  @override
  FacilityInfoPageState createState() => FacilityInfoPageState(gymId: gymId);
}

class FacilityInfoPageState extends ConsumerState<FacilityInfoPage> {
  /// ■ プロパティ
  final String gymId;
  final ScrollController _scrollController = ScrollController();

  /// ■ コンストラクタ
  FacilityInfoPageState({
    Key? key,
    required this.gymId,
  });

  /// ■ 初期化
  @override
  void initState() {
    super.initState();

    // スクロール発生時,_onScroll()を実行するリスナを追加
    _scrollController.addListener(_onScroll);
  }

  /// ■ 内部メソッド
  /// - スクロール時に最下部まで行くと、次のツイートを呼び出す処理を実行する
  void _onScroll() {
    if (_scrollController.position.pixels >
        _scrollController.position.maxScrollExtent - 100) {
      ref.read(specificGymTweetsProvider.notifier).loadMore();
    }
  }

  /// ■ 内部メソッド
  /// - URLを押下時した時にそのページに遷移可能であれば開くメソッド
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    // ジム施設情報を取得
    final gymInfoAsync = ref.watch(facilityInfoProvider(gymId));
    // ログイン状態を取得
    final isLoggedIn = ref.watch(authProvider);
    // ジム施設のツイート
    final specificGymTweetsState = ref.watch(specificGymTweetsProvider);
    final specificGymTweets = specificGymTweetsState.specificGymTweets;
    final _hasMoreSpecificGymTweets = specificGymTweetsState.hasMore;
    // ログイン時のユーザーIDを取得
    final userId = ref.watch(userProvider)?.userId;

    return gymInfoAsync.when(
        // ロード中
        loading: () => const Center(child: CircularProgressIndicator()),
        // エラー
        error: (error, stack) => Center(child: Text('エラー発生:$error')),
        // データ読み込み
        data: (gymInfo) {
          return DefaultTabController(
            length: 2,
            child: Scaffold(
              appBar: AppBar(
                elevation: 0,
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              body: Stack(
                children: [
                  // SwitcherTabの下に中身のスクロール部分を配置
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      color: Colors.white,
                      child: const SwitcherTab(
                          leftTabName: "施設情報",
                          rightTabName: "ボル活",
                          colorCode: 0xFFFFFFFF),
                    ),
                  ),

                  // コンテンツ部分
                  Padding(
                    padding: const EdgeInsets.only(
                        top: kToolbarHeight), // AppBarとSwitherTabの高さを加味した値
                    child: TabBarView(children: [
                      SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // タイトルとタグ
                            Text(
                              // TODO：値をもらう箇所
                              gymInfo.gymName,
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (gymInfo.isBoulderingGym) ...[
                                  const GimCategory(
                                    // TODO：値をもらう箇所
                                    gimCategory: 'ボルダリング',
                                    colorCode: 0xFFF44336,
                                  ),
                                  const SizedBox(height: 8),
                                ],
                                if (gymInfo.isLeadGym) ...[
                                  const GimCategory(
                                    // TODO：値をもらう箇所
                                    gimCategory: 'リード',
                                    colorCode: 0xFFF44336,
                                  ),
                                  const SizedBox(height: 8),
                                ],
                                if (gymInfo.isSpeedGym) ...[
                                  const GimCategory(
                                    // TODO：値をもらう箇所
                                    gimCategory: 'スピード',
                                    colorCode: 0xFFF44336,
                                  ),
                                  const SizedBox(height: 8),
                                ],
                                GymIkitaiBoullogCount(
                                  // TODO：値をもらう箇所
                                  ikitaiCount: gymInfo.ikitaiCount.toString(),
                                  boullogCount: gymInfo.boulCount.toString(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // ギャラリー
                            // TODO：値をもらう箇所 + 写真オブジェクトを取得して表示するように実装する必要が（前段階で）ある
                            SizedBox(
                              height: 100, // ギャラリーの高さ
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal, // 横スクロール
                                itemCount: 5, // 画像の枚数←外部DBから取得した枚数にする
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: _buildImage(
                                        'lib/view/assets/gym_facilitation.png'),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 16),

                            // 基本情報
                            const Text(
                              '基本情報',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            // TODO：値をもらう箇所
                            _buildInfoRow('住所',
                                '${gymInfo.prefecture}${gymInfo.city}${gymInfo.addressLine}'),
                            _buildInfoRow('TEL', gymInfo.telNo), // TODO：値をもらう箇所
                            _buildInfoRow(
                              'HP',
                              gymInfo.hpLink, // TODO：値をもらう箇所
                              isLink: true,
                              onTap: () =>
                                  _launchUrl(gymInfo.hpLink), // TODO：値をもらう箇所
                            ),
                            _buildInfoRow('定休日', 'なし'), // TODO；値をもらう箇所
                            _buildInfoRow(
                              // TODO：値をもらう箇所
                              '営業時間',
                              '月曜日 ${gymInfo.monOpen}〜${gymInfo.monClose}\n火曜日 ${gymInfo.tueOpen}〜${gymInfo.tueClose}\n水曜日 ${gymInfo.wedOpen}〜${gymInfo.wedClose}\n木曜日 ${gymInfo.thuOpen}〜${gymInfo.thuClose}\n金曜日 ${gymInfo.friOpen}〜${gymInfo.friClose}\n土曜日 ${gymInfo.satOpen}〜${gymInfo.satClose}\n日曜日 ${gymInfo.sunOpen}〜${gymInfo.sunClose}',
                            ),
                            const SizedBox(height: 16),

                            // 支払い方法
                            // _buildSectionTitle('支払い方法'),
                            // const Text(
                            //     '◯ 現金\n◯ クレジットカード\n◯ 電子マネー（Paypay）'), // TODO：確か削除するやつ、確認する

                            // const SizedBox(height: 16),

                            // 料金情報
                            _buildSectionTitle('料金'),
                            Text(
                                // TODO：値をもらう箇所
                                // '20歳以上 会員登録：1,500円\n20歳以上2時間：1,700円\n20歳以上1日利用：1,900円\n\n'
                                // '中学生〜19歳会員登録：1,500円\n中学生〜19歳2時間：1,500円\n中学生〜19歳1日：1,700円\n\n'
                                // '4歳から小学生会員登録：1,500円\n4歳から小学生2時間：1,000円\n4歳から小学生1日：1,500円\n\n'
                                // 'その他\n4歳から小学生1時間体験利用：1,200円\n※4歳から小学生限定プラン\n※レンタルシューズ代込み\n\n'
                                // 'OYAKO体験利用：2,500円/1時間\n※大人1名+子ども1名\n※大人追加+1,300円/1時間\n※利用時間の延長はできません\n\n'
                                // 'キッズスクール：12,000円(30DAYS)\n※小学生のみ\n※毎週、月・水・金 17:00〜18:00のクライミングスクール\n'
                                // '30DAYS PASS付き\n※人数上限があるため、気になる方はお問い合わせください。\n\n'
                                // '30DAYS PASS\n一般：14,000円\n※7日以内の更新で、更新ごとに1,000円OFF。割引額最大12,000円\n'
                                // '中学生〜19歳：12,000円\n4歳〜小学生：10,000円\n\n'
                                // 'PUNCH TICKET\n購入日から半年間有効の10回利用回数券。シェアOK\n一般：17,000円\n中学生〜19歳：15,000円\n\n'
                                '${gymInfo.fee}'
                                '\n\n'
                                'レンタル'
                                '${gymInfo.equipmentRentalFee}'
                                // 'レンタル\nシューズ：400円\n※靴下の着用が必要となります\nチョーク：200円\n\n'
                                // 'その他\n会員カード再発行：500円\n',
                                ),
                            const SizedBox(height: 16),

                            // 設備情報
                            // _buildSectionTitle('設備'),
                            // const Text('◯ 駐車場（1台）'), // TODO：値をもらう箇所 ← このセクションは不要
                          ],
                        ),
                      ),

                      // 施設名と同じ名称のボル活を時系列順に表示する予定
                      ListView.builder(
                        controller: _scrollController,
                        itemCount: specificGymTweets.length +
                            (_hasMoreSpecificGymTweets ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == specificGymTweets.length) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          final specificGymTweet = specificGymTweets[index];

                          return BoulLog(
                            userName: specificGymTweet.userName,
                            visitedDate: specificGymTweet.visitedDate
                                .toLocal()
                                .toIso8601String()
                                .split('T')[0],
                            // DateTime.parse(tweet.visitedDate.toString()).toLocal().toString().split(' ')[0],
                            gymName: specificGymTweet.gymName,
                            prefecture: specificGymTweet.prefecture,
                            tweetContents: specificGymTweet.tweetContents,
                          ); // TODO：バックエンド処理をして値をもらったやつをここに入れる必要がある
                        },
                      ),
                    ]),
                  ),

                  // 下部固定のボタン
                  // TODO：ここはログイン状態であるときに、ボタンを表示するようにする必要がある。、
                  isLoggedIn
                      ? Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            color: Colors.transparent,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                OutlinedButton(
                                  onPressed: () {
                                    // TODO：イキタイボタンの処理
                                  },
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 32),
                                    side: const BorderSide(color: Colors.blue),
                                  ),
                                  child: const Text('イキタイ',
                                      style: TextStyle(
                                        color: Colors.blue,
                                      )),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    // TODO：ボル活投稿ボタンの処理

                                    // 投稿ページに遷移する
                                    // (投稿ページにて)投稿のバックエンド呼び出し処理を行う
                                    // 投稿が完了したら、(↓続く)
                                    // 本のジムページに戻る
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 32),
                                    backgroundColor: Colors.blue,
                                  ),
                                  child: const Text('ボル活投稿',
                                      style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ],
              ),
            ),
          );
        });
  }

  // 各種ウィジェットビルドメソッド
  Widget _buildTab(String title, bool isSelected) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.blue : Colors.black,
          ),
        ),
        if (isSelected)
          const Divider(
            thickness: 2,
            color: Colors.blue,
          ),
      ],
    );
  }

  Widget _buildTag(String text, {Color color = Colors.grey}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildCounter(String label, String count) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 4),
        Text(count,
            style: const TextStyle(
                color: Colors.blue, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildImage(String imagePath) {
    return Container(
      width: 150,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value,
      {bool isLink = false, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 80,
              child: Text(label,
                  style: const TextStyle(fontWeight: FontWeight.bold))),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: isLink ? onTap : null,
              child: Text(
                value,
                style: TextStyle(color: isLink ? Colors.blue : Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }
}

class GymIkitaiBoullogCount extends StatelessWidget {
  final String ikitaiCount;
  final String boullogCount;

  const GymIkitaiBoullogCount({
    Key? key,
    required this.ikitaiCount,
    required this.boullogCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // イキタイ部分
          const Text(
            'イキタイ ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            ikitaiCount,
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          // 区切り線
          Container(
            width: 1,
            height: 16,
            color: Colors.grey,
          ),
          const SizedBox(width: 8),
          // ボル活部分
          const Text(
            'ボル活 ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            boullogCount,
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
