import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:bouldering_app/model/boul_log_tweet.dart';

/// ■ クラス
/// - お気に入りユーザーのツイートを定義するクラス
class FavoriteUserTweetsState {
  final List<BoulLogTweet> favoriteUserTweets;
  final bool hasMore;
  final bool isFirstFetch;

  FavoriteUserTweetsState({
    required this.favoriteUserTweets,
    required this.hasMore,
    required this.isFirstFetch,
  });
}

/// ■ クラス
/// - お気に入りユーザーのツイートを状態管理するクラス
class FavoriteUserTweetsNotifier
    extends StateNotifier<FavoriteUserTweetsState> {
  // プロパティ
  bool _isLoading = false;
  final String userId;

  /// ■ コンストラクタ
  FavoriteUserTweetsNotifier(this.userId)
      : super(FavoriteUserTweetsState(
          favoriteUserTweets: [],
          hasMore: true,
          isFirstFetch: true,
        )) {
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
                .map((tweet) => BoulLogTweet.fromJson(tweet))
                .toList()
              ..sort((a, b) => b.visitedDate.compareTo(a.visitedDate));

        state = FavoriteUserTweetsState(
          favoriteUserTweets: [
            ...state.favoriteUserTweets,
            ...newFavoriteUserTweetsList
          ],
          hasMore: newFavoriteUserTweetsList.length >= 20,
          isFirstFetch: false, // 最初の取得完了後は常にfalseにする
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
  /// - ツイート一覧を初期化して再取得
  /// - Pull-to-Refresh対応
  Future<void> refreshTweets() async {
    if (_isLoading) return;

    state = FavoriteUserTweetsState(
      favoriteUserTweets: [],
      hasMore: true,
      isFirstFetch: false, // 最初の取得完了後は常にfalse状態
    );
    await _fetchMoreFavoriteUserTweets();
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
