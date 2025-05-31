import 'package:bouldering_app/view_model/wanna_go_relation_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bouldering_app/view/components/boul_log.dart';
import 'package:bouldering_app/view/components/gim_category.dart';
import 'package:bouldering_app/view/components/switcher_tab.dart';
import 'package:bouldering_app/view_model/auth_provider.dart';
import 'package:bouldering_app/view_model/specific_gym_tweets_provider.dart';
import 'package:bouldering_app/view_model/user_provider.dart';
import 'package:bouldering_app/view_model/facility_info_provider.dart';

class FacilityInfoPage extends ConsumerStatefulWidget {
  const FacilityInfoPage({
    Key? key,
    required this.gymId,
  }) : super(key: key);
  final String gymId;

  @override
  FacilityInfoPageState createState() => FacilityInfoPageState(gymId: gymId);
}

class FacilityInfoPageState extends ConsumerState<FacilityInfoPage> {
  /// ■ プロパティ
  final String gymId;
  final ScrollController _scrollController = ScrollController();
  bool _isWannaGoRegistered = false;

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

    /// initStateでイキタイ登録状態を取得して変数に代入
    Future.microtask(() {
      final wannaGoGymState = ref.read(wannaGoRelationProvider);
      final isRegistered = wannaGoGymState.containsKey(int.parse(gymId));
      setState(() {
        _isWannaGoRegistered = isRegistered;
      });
    });
  }

  /// ■ 内部メソッド
  /// - スクロール時に最下部まで行くと、次のツイートを呼び出す処理を実行する
  void _onScroll() {
    if (_scrollController.position.pixels >
        _scrollController.position.maxScrollExtent - 100) {
      ref.read(specificGymTweetsProvider(gymId).notifier).loadMore();
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
    final asyncGymInfo = ref.watch(facilityInfoProvider(gymId));
    // ログイン状態を取得
    final isLoggedIn = ref.watch(authProvider);
    // ジム施設のツイート
    final specificGymTweetsState = ref.watch(specificGymTweetsProvider(gymId));
    final specificGymTweets = specificGymTweetsState.specificGymTweets;
    final _hasMoreSpecificGymTweets = specificGymTweetsState.hasMore;

    return asyncGymInfo.when(
        // ロード中
        loading: () => Scaffold(
              backgroundColor: const Color(0xFFFEF7FF),
              appBar: AppBar(
                backgroundColor: const Color(0xFFFEF7FF),
                surfaceTintColor: const Color(0xFFFEF7FF),
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              body: const Center(
                child: CircularProgressIndicator(
                  color: Colors.purple,
                ),
              ),
            ),

        // エラー
        error: (error, stack) => Scaffold(
              backgroundColor: const Color(0xFFFEF7FF),
              appBar: AppBar(
                backgroundColor: const Color(0xFFFEF7FF),
                surfaceTintColor: const Color(0xFFFEF7FF),
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              body: const Center(child: Text("このジムデータはありません")),
            ),
        /*
        // 下記デバッグ用の
        // error: (error, stack) => Center(child: Text('エラー発生:$error')),
        */

        // データ読み込み
        data: (gymInfo) {
          return DefaultTabController(
            length: 2,
            child: Scaffold(
              backgroundColor: const Color(0xFFFEF7FF),
              appBar: AppBar(
                elevation: 0,
                backgroundColor: const Color(0xFFFEF7FF),
                surfaceTintColor: const Color(0xFFFEF7FF),
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
                      child: const SwitcherTab(
                        leftTabName: "施設情報",
                        rightTabName: "ボル活",
                        colorCode: 0xFFFEF7FF,
                      ),
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
                              gymInfo.gymName,
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ),

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (gymInfo.isBoulderingGym)
                                  const Padding(
                                    padding: EdgeInsets.only(right: 8.0),
                                    child: GimCategory(
                                      gimCategory: 'ボルダリング',
                                      colorCode: 0xFFFF0F00,
                                    ),
                                  ),
                                if (gymInfo.isLeadGym)
                                  const Padding(
                                    padding: EdgeInsets.only(right: 8.0),
                                    child: GimCategory(
                                      gimCategory: 'リード',
                                      colorCode: 0xFF00A24C,
                                    ),
                                  ),
                                if (gymInfo.isSpeedGym)
                                  const Padding(
                                    padding: EdgeInsets.only(right: 8.0),
                                    child: GimCategory(
                                      gimCategory: 'スピード',
                                      colorCode: 0xFF0057FF,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            GymIkitaiBoullogCount(
                              ikitaiCount: gymInfo.ikitaiCount.toString(),
                              boullogCount: gymInfo.boulCount.toString(),
                            ),
                            const SizedBox(height: 12),

                            // ギャラリー
                            // TODO：値をもらう箇所 + 写真オブジェクトを取得して表示するように実装する必要が（前段階で）ある
                            SizedBox(
                              height: 100, // ギャラリーの高さ
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal, // 横スクロール可
                                itemCount: 5, // 画像の枚数 // TODO：外部DBから取得した枚数にする
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
                            _buildInfoRow('住所',
                                '${gymInfo.prefecture}${gymInfo.city}${gymInfo.addressLine}'),
                            _buildInfoRow('TEL', gymInfo.telNo),
                            _buildInfoRow(
                              'HP',
                              gymInfo.hpLink,
                              isLink: true,
                              onTap: () => _launchUrl(gymInfo.hpLink),
                            ),
                            _buildInfoRow('定休日', 'なし'),
                            _buildInfoRow(
                              '営業時間',
                              '月曜日 ${gymInfo.monOpen}〜${gymInfo.monClose}\n火曜日 ${gymInfo.tueOpen}〜${gymInfo.tueClose}\n水曜日 ${gymInfo.wedOpen}〜${gymInfo.wedClose}\n木曜日 ${gymInfo.thuOpen}〜${gymInfo.thuClose}\n金曜日 ${gymInfo.friOpen}〜${gymInfo.friClose}\n土曜日 ${gymInfo.satOpen}〜${gymInfo.satClose}\n日曜日 ${gymInfo.sunOpen}〜${gymInfo.sunClose}',
                            ),
                            const SizedBox(height: 16),

                            // 料金情報
                            _buildSectionTitle('料金'),
                            Text('${gymInfo.fee}'
                                '\n\n'
                                '■レンタル'
                                '\n'
                                '${gymInfo.equipmentRentalFee}'),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),

                      // 表示ジム施設のツイート(時系列順に表示)
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
                            userId: specificGymTweet.userId,
                            userName: specificGymTweet.userName,
                            userIconUrl: specificGymTweet.userIconUrl,
                            visitedDate: specificGymTweet.visitedDate
                                .toLocal()
                                .toIso8601String()
                                .split('T')[0],
                            // DateTime.parse(tweet.visitedDate.toString()).toLocal().toString().split(' ')[0],
                            gymId: specificGymTweet.gymId.toString(),
                            gymName: specificGymTweet.gymName,
                            prefecture: specificGymTweet.prefecture,
                            tweetContents: specificGymTweet.tweetContents,
                            tweetImageUrls: specificGymTweet.mediaUrls,
                          );
                        },
                      ),
                    ]),
                  ),

                  // 下部固定のボタン
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
                                /// キタイボタンの見た目と動作を変数で制御
                                OutlinedButton(
                                  onPressed: () async {
                                    final userId =
                                        ref.read(userProvider)!.userId;
                                    if (_isWannaGoRegistered) {
                                      await ref
                                          .read(
                                              wannaGoRelationProvider.notifier)
                                          .deleteWannaGoGym(userId, gymId);
                                    } else {
                                      await ref
                                          .read(
                                              wannaGoRelationProvider.notifier)
                                          .registerWannaGoGym(userId, gymId);
                                    }
                                    setState(() {
                                      _isWannaGoRegistered =
                                          !_isWannaGoRegistered;
                                    });
                                  },
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: _isWannaGoRegistered
                                        ? Colors.blue
                                        : Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 32),
                                    side: BorderSide(
                                      color: _isWannaGoRegistered
                                          ? Colors.blue
                                          : Colors.grey,
                                    ),
                                  ),
                                  child: Text(
                                    'イキタイ',
                                    style: TextStyle(
                                      color: _isWannaGoRegistered
                                          ? Colors.white
                                          : Colors.blue,
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    await context.push(
                                        '/FacilityInfo/${gymInfo.gymId}/ActivityPostFromFacilityInfo');
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
