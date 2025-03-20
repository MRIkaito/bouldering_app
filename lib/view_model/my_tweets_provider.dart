import 'package:bouldering_app/model/boul_log_tweet.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// ■ クラス
/// - 自分のツイート情報を保持するクラス
/// - ログイン時，最初にかならず20件のツイートを取得する処理が呼ばれる
class MyTweetsNotifier extends StateNotifier<List<BoulLogTweet>> {
  /// ■コンストラクタ
  MyTweetsNotifier() : super([]);

  /// ■ プロパティ
  bool _isLoading = false;
  bool _hasMore = true;

  /// ■ ゲッター
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

  /// ■ メソッド
  /// 自身のツイートを取得する関数
  ///
  /// 引数
  /// - [userId] ユーザーID
  ///
  /// 返り値
  /// もらったカーソル(日付)よりもさらに古いツイートがあるかを返す
  Future<void> fetchTweets(String userId) async {
    // すでにローディング中の時、またはすべてツイート取得済みの時は実行しない
    if (_isLoading || !_hasMore) return;

    // ツイート取得開始
    _isLoading = true;
    print(
        "🟢 [DEBUG] fetchTweets() called. isLoading: $_isLoading, hasMore: $_hasMore");

    final String? cursor =
        state.isNotEmpty ? state.last.tweetedDate.toString() : null;

    final url = Uri.parse(
            'https://us-central1-gcp-compute-engine-441303.cloudfunctions.net/getData')
        .replace(queryParameters: {
      'request_id': '12',
      'limit': '20',
      if (cursor != null) 'cursor': cursor,
      'user_id': userId,
    });

    try {
      final response = await http.get(url);
      print("🟣 [DEBUG] Response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        print("🟢 [DEBUG] Response body: $jsonData");

        final List<BoulLogTweet> newTweets = jsonData
            .map((tweet) => BoulLogTweet(
                  tweetId: tweet['tweet_id'],
                  tweetContents: tweet['tweet_contents'],
                  visitedDate: DateTime.tryParse(tweet['visited_date'] ?? '') ??
                      DateTime.now(),
                  tweetedDate: DateTime.tryParse(tweet['tweeted_date'] ?? '') ??
                      DateTime.now(),
                  likedCount: tweet['liked_count'],
                  movieUrl: tweet['movie_url'],
                  userId: tweet['user_id'],
                  userName: tweet['user_name'],
                  gymId: tweet['gym_id'],
                  gymName: tweet['gym_name'],
                  prefecture: tweet['prefecture'],
                ))
            .toList();

        if (newTweets.length < 20) {
          _hasMore = false;
        } else {
          state = [...state, ...newTweets];
        }
      } else {
        print(
            "❌ [ERROR] Failed to fetch tweets. Status: ${response.statusCode}");
        print("❌ [ERROR] Response body: ${response.body}");
      }
    } catch (error) {
      print("❌ [ERROR] Exception in _fetchTweets(): $error");
    } finally {
      _isLoading = false;
      print("🟢 [DEBUG] fetchTweets() finished. isLoading: $_isLoading");
    }
  }
}

final myTweetsProvider =
    StateNotifierProvider<MyTweetsNotifier, List<BoulLogTweet>>((ref) {
  return MyTweetsNotifier();
});
