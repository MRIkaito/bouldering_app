import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:bouldering_app/model/boul_log_tweet.dart';

class GeneralTweetsState {
  final List<BoulLogTweet> generalTweets;
  final bool hasMore;

  GeneralTweetsState({
    required this.generalTweets,
    required this.hasMore,
  });
}

class GeneralTweetsNotifier extends StateNotifier<GeneralTweetsState> {
  // コンストラクタ
  GeneralTweetsNotifier()
      : super(GeneralTweetsState(generalTweets: [], hasMore: true)) {
    _fetchMoreGeneralTweets();
  }

  // プロパティ
  bool _isLoading = false;

  /// ■ メソッド
  /// - 総合ツイートを取得するメソッド
  Future<void> _fetchMoreGeneralTweets() async {
    if (_isLoading || !state.hasMore) return;

    _isLoading = true;

    final String? cursor = state.generalTweets.isNotEmpty
        ? state.generalTweets.last.tweetedDate.toString()
        : null;

    final url = Uri.parse(
            'https://us-central1-gcp-compute-engine-441303.cloudfunctions.net/getData')
        .replace(queryParameters: {
      'request_id': '2',
      'limit': '20',
      if (cursor != null) 'cursor': cursor,
    });

    try {
      // HTTP GETリクエスト
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // レスポンスボディをJSONとしてデコードする
        final List<dynamic> generalTweetsList = jsonDecode(response.body);

        final List<BoulLogTweet> newGeneralTweetsList = generalTweetsList
            .map((tweet) => BoulLogTweet(
                  tweetId: tweet['tweet_id'] ?? 0,
                  tweetContents: tweet['tweet_contents'] ?? '',
                  visitedDate: tweet['visited_date'] != null
                      ? DateTime.parse(tweet['visited_date'])
                      : DateTime(1990, 1, 1),
                  tweetedDate: tweet['tweeted_date'] != null
                      ? DateTime.parse(tweet['tweeted_date'])
                      : DateTime(1990, 1, 1),
                  likedCount: tweet['liked_count'] ?? 0,
                  movieUrl: tweet['movie_url'] ?? '',
                  userId: tweet['user_id'] ?? '',
                  userName: tweet['user_name'] ?? '',
                  gymId: tweet['gym_id'] ?? 0,
                  gymName: tweet['gym_name'] ?? '',
                  prefecture: tweet['prefecture'] ?? '',
                ))
            .toList();

        state = GeneralTweetsState(
          generalTweets: [...state.generalTweets, ...newGeneralTweetsList],
          hasMore: newGeneralTweetsList.length >= 20,
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
    _fetchMoreGeneralTweets();
  }
}

// StateNotifierProviderの定義
final generalTweetsProvider =
    StateNotifierProvider<GeneralTweetsNotifier, GeneralTweetsState>(
  (ref) => GeneralTweetsNotifier(),
);
