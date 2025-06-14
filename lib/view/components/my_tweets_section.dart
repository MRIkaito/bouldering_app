import 'package:bouldering_app/view/components/app_logo.dart';
import 'package:bouldering_app/view/components/boul_log.dart';
import 'package:bouldering_app/view_model/my_tweets_provider.dart';
import 'package:bouldering_app/view_model/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ■ クラス
/// - 自分が投稿したツイートを表示するクラス
class MyTweetsSection extends ConsumerStatefulWidget {
  const MyTweetsSection({super.key});

  @override
  MyTweetsSectionState createState() => MyTweetsSectionState();
}

class MyTweetsSectionState extends ConsumerState<MyTweetsSection> {
  // ■ プロパティ
  final ScrollController _scrollController = ScrollController();

  /// ■ 初期化
  @override
  void initState() {
    super.initState();
    // ツイートを取得する
    _fetchTweets();
    // 無限スクロール用リスナー
    _scrollController.addListener(_onScroll);
  }

  /// ■ dispose
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// ■ メソッド
  /// - ツイートを取得する処理
  Future<void> _fetchTweets() async {
    // ユーザーID
    final userId = ref.read(userProvider)?.userId;

    // ユーザーID取得できていない時、実行しない
    if (userId == null) {
      // ❌ [ERROR] user_id is null! API リクエストをスキップ
      return;
    }

    // ツイート取得処理
    await ref.read(myTweetsProvider.notifier).fetchTweets(userId);
  }

  // 一番下までスクロールしたときツイートを取得する
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 10) {
      // 🟢 [DEBUG] トリガー条件を満たしたのでfetchTweets呼び出し
      _fetchTweets();
    }
  }

  /// ■ メソッド
  /// - リフレッシュ開始
  /// - もらった引数を反映した状態
  Future<void> _refetchTweets() async {
    // 今持つツイート(状態)をすべて破棄する
    ref.read(myTweetsProvider.notifier).disposeMyTweets();

    // ツイートを新しく取得しなおす
    await _fetchTweets();
    return;
  }

  @override
  Widget build(BuildContext context) {
    final tweets = ref.watch(myTweetsProvider);
    final hasMore = ref.watch(myTweetsProvider.notifier).hasMore;

    return RefreshIndicator(
      onRefresh: _refetchTweets,
      child: tweets.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              shrinkWrap: true,
              children: const [
                SizedBox(height: 96),
                AppLogo(),
              ],
            )
          : ListView.builder(
              key: const PageStorageKey<String>('my_tweets_section'),
              controller: _scrollController,
              itemCount: tweets.length + (hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == tweets.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final tweet = tweets[index];

                return BoulLog(
                  userId: tweet.userId,
                  userName: ref.read(userProvider)?.userName ?? ' 取得できませんでした ',
                  userIconUrl: tweet.userIconUrl,
                  visitedDate: tweet.visitedDate
                      .toLocal()
                      .toIso8601String()
                      .split('T')[0],
                  // DateTime.parse(tweet.visitedDate.toString()).toLocal().toString().split(' ')[0],
                  gymId: tweet.gymId.toString(),
                  gymName: tweet.gymName,
                  prefecture: tweet.prefecture,
                  tweetId: tweet.tweetId,
                  tweetContents: tweet.tweetContents,
                  tweetImageUrls: tweet.mediaUrls,
                );
              },
            ),
    );
  }
}
