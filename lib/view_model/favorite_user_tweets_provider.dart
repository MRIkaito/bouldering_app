import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:bouldering_app/model/boul_log_tweet.dart';

class FavoriteUserTweetsState {
  final List<BoulLogTweet> favoriteUserTweets;
  final bool hasMore;

  FavoriteUserTweetsState({
    required this.favoriteUserTweets,
    required this.hasMore,
  });
}

class FavoriteUserTweetsNotifier
    extends StateNotifier<FavoriteUserTweetsState> {
  // プロパティ
  bool _isLoading = false;
  final String userId;

  // コンストラクタ
  FavoriteUserTweetsNotifier(this.userId)
      : super(FavoriteUserTweetsState(favoriteUserTweets: [], hasMore: true)) {
    _fetchMoreFavoriteUserTweets();
  }

  /// ■ メソッド
  /// - お気に入りユーザーのツイートを取得するメソッド
  Future<void> _fetchMoreFavoriteUserTweets() async {
    if (_isLoading || !state.hasMore) return;

    _isLoading = true;

    final String? cursor = state.favoriteUserTweets.isNotEmpty
        ? state.favoriteUserTweets.last.tweetedDate.toString()
        : null;

    final url = Uri.parse(
            'https://us-central1-gcp-compute-engine-441303.cloudfunctions.net/getData')
        .replace(queryParameters: {
      'request_id': '6',
      'user_id': userId,
      'limit': '20',
      if (cursor != null) 'cursor': cursor,
    });

    try {
      // HTTP GETリクエスト
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // レスポンスボディをJSONとしてデコードする
        final List<dynamic> favoriteUserTweetsList = jsonDecode(response.body);

        final List<BoulLogTweet> newFavoriteUserTweetsList =
            favoriteUserTweetsList
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
                      userId: tweet['user_id'] ??
                          '', // このお気に入りユーザーツイートのuser_idとは，バックエンドのSQL文では"likee_user_id"のことを指す
                      userName: tweet['user_name'] ?? '',
                      gymId: tweet['gym_id'] ?? 0,
                      gymName: tweet['gym_name'] ?? '',
                      prefecture: tweet['prefecture'] ?? '',
                    ))
                .toList();

        state = FavoriteUserTweetsState(
          favoriteUserTweets: [
            ...state.favoriteUserTweets,
            ...newFavoriteUserTweetsList
          ],
          hasMore: newFavoriteUserTweetsList.length >= 20,
        );
      } else {
        print("[Debug] ${response.statusCode}");
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
    _fetchMoreFavoriteUserTweets();
  }
}

// StateNotifierProviderの定義
final favoriteUserTweetsProvider = StateNotifierProvider.family<
    FavoriteUserTweetsNotifier, FavoriteUserTweetsState, String>(
  // ↑ String = userIdの型
  (ref, userId) => FavoriteUserTweetsNotifier(userId),
);

// final favoriteUserTweetsProvider =
//     StateNotifierProvider<FavoriteUserTweetsNotifier, FavoriteUserTweetsState>(
//   (ref) => FavoriteUserTweetsNotifier(),
// );
