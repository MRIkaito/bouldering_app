import 'package:bouldering_app/model/boul_log_tweet.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// ■ クラス
/// - 他ユーザーのツイート情報を保持するクラス
class OtherUserTweetsNotifier extends StateNotifier<List<BoulLogTweet>> {
  /// コンストラクタ
  OtherUserTweetsNotifier(this.userId) : super([]);

  /// プロパティ
  final String userId;
  bool _isLoading = false;
  bool _hasMore = true;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

  /// ■ メソッド
  /// - 自身の保持しているツイートを破棄する
  void disposeOtherUserTweets() {
    _hasMore = true;
    state = [];
  }

  /// ■ メソッド
  /// - ツイートを取得する処理
  Future<void> fetchTweets() async {
    // ローディング状態にない，または取得するツイートがこれ以上ない時に取得処理に遷移せずに終了
    if (_isLoading || !_hasMore) {
      // [DEBUG] fetchTweets() skipped.
      return;
    }

    _isLoading = true;

    final String? cursor =
        state.isNotEmpty ? state.last.tweetedDate.toString() : null;

    final url = Uri.parse(
            'https://us-central1-gcp-compute-engine-441303.cloudfunctions.net/getData')
        .replace(queryParameters: {
      'request_id': '12',
      'limit': '20',
      'user_id': userId,
      if (cursor != null) 'cursor': cursor,
    });

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        final List<BoulLogTweet> newTweets = jsonData
            .map((tweet) => BoulLogTweet.fromJson(tweet))
            .toList()
          ..sort((a, b) => b.tweetedDate.compareTo(a.tweetedDate));

        state = List.from(state)
          ..addAll(newTweets.map((tweet) => tweet.copyWith()));

        if (newTweets.length < 20) {
          _hasMore = false;
        }
      } else {
        // ❌ [ERROR] Failed to fetch tweets.
        // DO NOTHING
      }
    } catch (error) {
      // ❌ [ERROR] Exception in fetchTweets();
      // DO NOTHING
    } finally {
      // [DEBUG] isLoading set to false
      _isLoading = false;
    }
  }
}

/// ■ プロバイダ
/// userIdを渡す形にして、ユーザーごとに独立して管理
final otherUserTweetsProvider = StateNotifierProvider.family<
    OtherUserTweetsNotifier, List<BoulLogTweet>, String>(
  (ref, userId) => OtherUserTweetsNotifier(userId),
);
