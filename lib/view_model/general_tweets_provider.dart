import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:bouldering_app/model/boul_log_tweet.dart';

class GeneralTweetsState {
  final List<BoulLogTweet> generalTweets;
  final bool hasMore;
  final bool isFirstFetch;

  GeneralTweetsState({
    required this.generalTweets,
    required this.hasMore,
    required this.isFirstFetch,
  });
}

class GeneralTweetsNotifier extends StateNotifier<GeneralTweetsState> {
  // コンストラクタ
  GeneralTweetsNotifier()
      : super(GeneralTweetsState(
          generalTweets: [],
          hasMore: true,
          isFirstFetch: true,
        )) {
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
            .map((tweet) => BoulLogTweet.fromJson(tweet))
            .toList()
          ..sort((a, b) => b.visitedDate.compareTo(a.visitedDate));

        state = GeneralTweetsState(
          generalTweets: [...state.generalTweets, ...newGeneralTweetsList],
          hasMore: newGeneralTweetsList.length >= 20,
          isFirstFetch: false, // 最初の取得完了後は常にfalseにする
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
  /// - Pull-to-Refresh対応：ツイート一覧を初期化して再取得
  Future<void> refreshTweets() async {
    if (_isLoading) return;

    state = GeneralTweetsState(
      generalTweets: [],
      hasMore: true,
      isFirstFetch: false, // 最初の取得完了後は常にfalse状態
    );
    await _fetchMoreGeneralTweets();
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
