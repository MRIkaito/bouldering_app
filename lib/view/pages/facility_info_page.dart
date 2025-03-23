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
    final asyncGymInfo = ref.watch(facilityInfoProvider(gymId));
    // ログイン状態を取得
    final isLoggedIn = ref.watch(authProvider);
    // ジム施設のツイート
    final specificGymTweetsState = ref.watch(specificGymTweetsProvider);
    final specificGymTweets = specificGymTweetsState.specificGymTweets;
    final _hasMoreSpecificGymTweets = specificGymTweetsState.hasMore;
    // イキタイジム情報を取得
    final wannaGoGymState = ref.read(wannaGoRelationProvider);
    bool isRegisteredGym = wannaGoGymState.containsKey(int.parse(gymId));

    return asyncGymInfo.when(
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
