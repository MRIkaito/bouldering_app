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
    if (_isLoading || !_hasMore) {
      print(
          "🟡 [DEBUG] fetchTweets() skipped. isLoading: $_isLoading, hasMore: $_hasMore");
      return;
    }

    // 🟢 デバッグ用：関数が呼ばれたことを確認
    print(
        "🟢 [DEBUG] fetchTweets() started. isLoading: $_isLoading, hasMore: $_hasMore");

    // ツイート取得開始
    _isLoading = true;

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
      print("🔵 [DEBUG] Fetching tweets from: $url");

      final response = await http.get(url);
      print("🟣 [DEBUG] Response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        print("🟢 [DEBUG] Response body: $jsonData");

        final List<BoulLogTweet> newTweets = jsonData
            .map((tweet) => BoulLogTweet(
                  tweetId: (tweet['tweet_id'] as int?) ?? 0,
                  tweetContents: tweet['tweet_contents'],
                  visitedDate: DateTime.tryParse(tweet['visited_date'] ?? '') ??
                      DateTime.now(),
                  tweetedDate: DateTime.tryParse(tweet['tweeted_date'] ?? '') ??
                      DateTime.now(),
                  likedCount: (tweet['liked_count'] as int?) ?? 0,
                  movieUrl: tweet['movie_url'] ?? '',
                  userId: tweet['user_id'] ?? '',
                  userName: tweet['user_name'] ?? '',
                  gymId: (tweet['gym_id'] as int?) ?? 0,
                  gymName: tweet['gym_name'] ?? '',
                  prefecture: tweet['prefecture'] ?? '',
                ))
            .toList();

        // 🟡 デバッグ用：受け取ったツイートの内容を一部表示
        if (newTweets.isNotEmpty) {
          print(
              "🟡 [DEBUG] First tweet: ${newTweets.first.tweetContents}, ID: ${newTweets.first.tweetId}");
        } else {
          print("🟡 [DEBUG] No new tweets found.");
        }

        /// ✅ `copyWith` を使って `state` を更新
        state = List.from(state)
          ..addAll(newTweets.map((tweet) => tweet.copyWith()));

        if (newTweets.length < 20) {
          _hasMore = false;
        } else {
          print(
              "🟡 [DEBUG] Before updating state, tweet count: ${state.length}");
          state = [...state, ...newTweets];
          print(
              "🟢 [DEBUG] After updating state, tweet count: ${state.length}");
        }
      } else {
        print(
            "❌ [ERROR] Failed to fetch tweets. Status: ${response.statusCode}");
        print("❌ [ERROR] Response body: ${response.body}");
      }
    } catch (error) {
      print("❌ [ERROR] Exception in _fetchTweets(): $error");
    } finally {
      print("🟡 [DEBUG] Before setting isLoading to false, value: $_isLoading");
      _isLoading = false;
      print("🟢 [DEBUG] isLoading is now: $_isLoading");
    }
  }
}

final myTweetsProvider =
    StateNotifierProvider<MyTweetsNotifier, List<BoulLogTweet>>((ref) {
  return MyTweetsNotifier();
});
