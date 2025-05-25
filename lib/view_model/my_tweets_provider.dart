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
  /// 自身の保持しているツイートを破棄する
  ///
  /// 備考
  /// - リフレッシュ時に保持しているツイート情報をすべて破棄する処理として実装
  /// - fetchTweetsに状態通知の処理が既に実装されているため、当処理では状態通知(=copyWith)不要
  void disposeMyTweets() {
    _hasMore = true;
    state = [];
  }

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
      return;
    }

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
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final List<BoulLogTweet> newTweets =
            jsonData.map((tweet) => BoulLogTweet.fromJson(tweet)).toList();

        // copyWith を使って state を更新
        state = List.from(state)
          ..addAll(newTweets.map((tweet) => tweet.copyWith()));
        if (newTweets.length < 20) {
          _hasMore = false;
        } else {
          // DO NOTHING
        }
      } else {
        // ❌ [ERROR] Failed to fetch tweets
        // DO NOTHING
      }
    } catch (error) {
      // ❌ [ERROR] Exception in _fetchTweets()
      // DO NOTHING
    } finally {
      _isLoading = false;
    }
  }
}

final myTweetsProvider =
    StateNotifierProvider<MyTweetsNotifier, List<BoulLogTweet>>((ref) {
  return MyTweetsNotifier();
});
