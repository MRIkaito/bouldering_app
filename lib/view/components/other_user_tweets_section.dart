import 'package:bouldering_app/view/components/app_logo.dart';
import 'package:bouldering_app/view/components/boul_log.dart';
import 'package:bouldering_app/view_model/other_user_tweets_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OtherUserTweetsSection extends ConsumerStatefulWidget {
  const OtherUserTweetsSection({super.key, required this.userId});
  final String userId;

  @override
  MyTweetsSectionState createState() => MyTweetsSectionState();
}

class MyTweetsSectionState extends ConsumerState<OtherUserTweetsSection> {
  final ScrollController _scrollController = ScrollController();

  /// ■ 初期化
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // 初回ツイート取得
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(otherUserTweetsProvider(widget.userId).notifier).fetchTweets();
    });
  }

  /// ■ dispose
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // 一番下までスクロールしたときツイートを取得する
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 10) {
      ref.read(otherUserTweetsProvider(widget.userId).notifier).fetchTweets();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tweets = ref.watch(otherUserTweetsProvider(widget.userId));
    final hasMore =
        ref.watch(otherUserTweetsProvider(widget.userId).notifier).hasMore;

    return RefreshIndicator(
      onRefresh: () async {
        ref
            .read(otherUserTweetsProvider(widget.userId).notifier)
            .disposeOtherUserTweets();
        await ref
            .read(otherUserTweetsProvider(widget.userId).notifier)
            .fetchTweets();
      },
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
              key: const PageStorageKey<String>('other_user_tweets_section'),
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(), // ← 追加
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
                  userName: tweet.userName,
                  userIconUrl: tweet.userIconUrl,
                  visitedDate: tweet.visitedDate
                      .toLocal()
                      .toIso8601String()
                      .split('T')[0],
                  // DateTime.parse(tweet.visitedDate.toString()).toLocal().toString().split(' ')[0],
                  gymId: tweet.gymId.toString(),
                  gymName: tweet.gymName,
                  prefecture: tweet.prefecture,
                  tweetContents: tweet.tweetContents,
                  tweetImageUrls: tweet.mediaUrls,
                );
              },
            ),
    );
  }
}
