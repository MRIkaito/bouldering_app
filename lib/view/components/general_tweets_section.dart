import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bouldering_app/view/components/boul_log.dart';
import 'package:bouldering_app/view_model/general_tweets_provider.dart';

class GeneralTweetsSection extends ConsumerStatefulWidget {
  const GeneralTweetsSection({super.key});

  @override
  GeneralTweetsSectionState createState() => GeneralTweetsSectionState();
}

class GeneralTweetsSectionState extends ConsumerState<GeneralTweetsSection> {
  // ボル活ページのスクロールを監視するコントローラ
  final ScrollController _generalTweetsScrollController = ScrollController();

  // 初期化
  @override
  void initState() {
    super.initState();
    _generalTweetsScrollController.addListener(_onGeneralTweetsScroll);
  }

  @override
  void dispose() {
    _generalTweetsScrollController.dispose();
    super.dispose();
  }

  void _onGeneralTweetsScroll() {
    if (_generalTweetsScrollController.position.pixels >
        _generalTweetsScrollController.position.maxScrollExtent - 100) {
      ref.read(generalTweetsProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final generalTweets = ref.watch(generalTweetsProvider).generalTweets;
    final _hasMoreGeneralTweets = ref.watch(generalTweetsProvider).hasMore;

    return ListView.builder(
      controller: _generalTweetsScrollController,
      itemCount: generalTweets.length + (_hasMoreGeneralTweets ? 1 : 0),
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
          gymName: generalTweet.gymName,
          prefecture: generalTweet.prefecture,
          tweetContents: generalTweet.tweetContents,
        );
      },
    );
  }
}
