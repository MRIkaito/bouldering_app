import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:bouldering_app/model/boul_log_tweet.dart';

class SpecificGymTweetsState {
  final List<BoulLogTweet> specificGymTweets;
  final bool hasMore;

  SpecificGymTweetsState({
    required this.specificGymTweets,
    required this.hasMore,
  });
}

class SpecificGymTweetsNotifier extends StateNotifier<SpecificGymTweetsState> {
  // コンストラクタ
  SpecificGymTweetsNotifier()
      : super(SpecificGymTweetsState(specificGymTweets: [], hasMore: true)) {
    _fetchMoreSpecificGymTweets();
  }

  // プロパティ
  bool _isLoading = false;

  /// ■ メソッド
  /// - 特定のジムのツイートを取得するメソッド
  Future<void> _fetchMoreSpecificGymTweets() async {
    if (_isLoading || !state.hasMore) return;

    _isLoading = true;

    final String? cursor = state.specificGymTweets.isNotEmpty
        ? state.specificGymTweets.last.tweetedDate.toString()
        : null;

    final url = Uri.parse(
            'https://us-central1-gcp-compute-engine-441303.cloudfunctions.net/getData')
        .replace(queryParameters: {
      'request_id': '24',
      'limit': '20',
      if (cursor != null) 'cursor': cursor,
    });

    try {
      // HTTP GETリクエスト
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // レスポンスボディをJSONとしてデコードする
        final List<dynamic> specificGymTweetsList = jsonDecode(response.body);

        final List<BoulLogTweet> newSpecificGymTweetsList =
            specificGymTweetsList
                .map((tweet) => BoulLogTweet(
                      tweetId: tweet['tweet_id'],
                      tweetContents: tweet['tweet_contents'],
                      visitedDate: tweet['visited_date'],
                      tweetedDate: tweet['tweeted_date'],
                      likedCount: tweet['liked_count'],
                      movieUrl: tweet['movie_url'],
                      userId: tweet['user_id'],
                      userName: tweet['user_name'],
                      gymId: tweet['gym_id'],
                      gymName: tweet['gym_name'],
                      prefecture: tweet['prefecture'],
                    ))
                .toList();

        state = SpecificGymTweetsState(
          specificGymTweets: [
            ...state.specificGymTweets,
            ...newSpecificGymTweetsList
          ],
          hasMore: newSpecificGymTweetsList.length >= 20,
        );
      } else {
        throw Exception("ツイート取得に失敗しました");
      }
    } catch (error) {
      print('エラーメッセージ:$error');
    } finally {
      _isLoading = false;
    }
  }

  /// ■ メソッド
  /// - 総合ツイートを追加で取得するメソッド
  /// - ページネーションでさらにツイートを取得する
  void loadMore() {
    _fetchMoreSpecificGymTweets();
  }
}

// StateNotifierProviderの定義
final specificGymTweetsProvider =
    StateNotifierProvider<SpecificGymTweetsNotifier, SpecificGymTweetsState>(
  (ref) => SpecificGymTweetsNotifier(),
);
