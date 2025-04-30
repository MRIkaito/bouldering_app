import 'package:bouldering_app/view/components/boul_log.dart';
import 'package:bouldering_app/view_model/my_tweets_provider.dart';
import 'package:bouldering_app/view_model/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyTweetsSection extends ConsumerStatefulWidget {
  const MyTweetsSection({super.key});

  @override
  MyTweetsSectionState createState() => MyTweetsSectionState();
}

class MyTweetsSectionState extends ConsumerState<MyTweetsSection> {
  final ScrollController _scrollController = ScrollController();
  bool _showNoTweetsText = false;

  /// ■ 初期化
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // 5病後に「ツイートなし表示」に切り替える
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showNoTweetsText = true;
        });
      }
    });
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
    print("🟡 [DEBUG] user_id before request: $userId");

    // ユーザーID取得できていない時、実行しない
    if (userId == null) {
      print("❌ [ERROR] user_id is null! API リクエストをスキップ");
      return;
    }

    // ツイート取得処理
    await ref.read(myTweetsProvider.notifier).fetchTweets(userId);
  }

  // 一番下までスクロールしたときツイートを取得する
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 10) {
      print("🟢 [DEBUG] トリガー条件を満たしたのでfetchTweetsを呼びます！");
      _fetchTweets();
    }
  }

  // 1. リフレッシュ開始
  Future<void> _refetchTweets() async {
    // 2. ツイート取得状態を初期状態(false)に戻す
    // 3. 今持っているツイートをすべて破棄する
    ref.read(myTweetsProvider.notifier).disposeMyTweets();

    // 4. 新しく取得しなおす
    await _fetchTweets();

    return;
  }

  @override
  Widget build(BuildContext context) {
    final tweets = ref.watch(myTweetsProvider);
    final hasMore = ref.watch(myTweetsProvider.notifier).hasMore;

    print("🟡 [DEBUG] UI tweets length: ${tweets.length}");

    return tweets.isEmpty
        ? Center(
            child: _showNoTweetsText
                ? const Text("ツイートがありません") // 👈 5秒後にこれが出る
                : const CircularProgressIndicator(), // 👈 それまではこれ
          )
        :
        // 自分のツイート
        RefreshIndicator(
            onRefresh: _refetchTweets,
            child: ListView.builder(
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
                  visitedDate: tweet.visitedDate
                      .toLocal()
                      .toIso8601String()
                      .split('T')[0],
                  // DateTime.parse(tweet.visitedDate.toString()).toLocal().toString().split(' ')[0],
                  gymId: tweet.gymId.toString(),
                  gymName: tweet.gymName,
                  prefecture: tweet.prefecture,
                  tweetContents: tweet.tweetContents,
                );
              },
            ),
          );
  }
}
