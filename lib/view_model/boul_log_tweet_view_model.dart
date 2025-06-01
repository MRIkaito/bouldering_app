import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// ■ クラス
/// - ボル活ツイートをDBから取得するクラス
class BoulLogTweetViewModel {
  /// ■ メソッド
  /// 自分のツイートを最新順から取得する関数
  ///
  /// 使用ページ
  /// - マイページ
  ///
  /// 返り値
  /// - ツイートをdynamic型(= Map(String: dynamic))で，それをList形式で返す
  Future<List<dynamic>> fetchDataTweet() async {
    int requestId = 2;

    final url = Uri.parse(
            'https://us-central1-gcp-compute-engine-441303.cloudfunctions.net/getData')
        .replace(queryParameters: {'request_id': requestId.toString()});

    try {
      // HTTP GETリクエスト
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // レスポンスボディをJSONとしてデコードする
        final List<dynamic> data = jsonDecode(response.body);
        print(data);
        return data;
      } else {
        throw Exception("Failed to fetch data");
      }
    } catch (e) {
      print('リクエスト中にErrorが発生しました');
      throw e;
    }
  }

  /// ■ メソッド
  /// 自分のツイートを最新順から取得する処理
  ///
  /// 使用ページ
  /// - マイページ
  ///
  /// 返り値
  ///
  Future<List<dynamic>> fetchDataMyOwnTweet(String userId) async {
    // TODO：下記、IDを新たに新設する
    int requestId = 2;

    final url = Uri.parse(
            'https://us-central1-gcp-compute-engine-441303.cloudfunctions.net/getData')
        .replace(queryParameters: {
      'request_id': requestId.toString(),
      'user_id': userId.toString()
    });

    try {
      // HTTP GETリクエスト
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // レスポンスボディをJSONとしてデコードする
        final List<dynamic> data = jsonDecode(response.body);

        return data;
      } else {
        throw Exception("Failed to fetch data");
      }
    } catch (e) {
      print('リクエスト中にErrorが発生しました');
      throw e;
    }
  }

  /// ■ メソッド
  /// ツイートを最新順から取得する関数
  /// お気に入り登録しているユーザーのツイートを取得する
  ///
  /// 使用ページ
  /// - ボル活ページ
  ///
  /// 返り値
  /// - ツイートをdynamic型(= Map(String: dynamic))で，それをList形式で返す
  // Future<List<dynamic>> fetchDataFavoriteTweet(String? userId) async {
  Future<List<dynamic>> fetchDataFavoriteTweet(String? userId) async {
    int requestId = 6;

    // userIdがnullの場合(ログインしていない)，からのリストを返す
    if (userId == null) {
      return [];
    }

    // お気に入りユーザーのツイートを返す処理を呼び出す
    final url = Uri.parse(
            'https://us-central1-gcp-compute-engine-441303.cloudfunctions.net/getData')
        .replace(queryParameters: {
      'request_id': requestId.toString(),
      'user_id': userId.toString()
    });

    try {
      // HTTP GETリクエスト
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // レスポンスボディをJSONとしてデコードする
        final List<dynamic> data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception("Failed to fetch data");
      }
    } catch (error) {
      print("リクエスト中にErrorが発生しました");
      throw error;
    }
  }
}

/// みんなのツイートを取得する FutureProvider
final boulLogTweetProvider = FutureProvider((ref) async {
  final viewModel = BoulLogTweetViewModel();
  return await viewModel.fetchDataTweet();
});

/// お気に入りユーザーのツイートを取得する FutureProvider
final boulLogFavoriteTweetProvider = FutureProvider.autoDispose
    .family<List<dynamic>, String?>((ref, userId) async {
  if (userId == null) return []; // ログインしていない場合は空のリスト
  final viewModel = BoulLogTweetViewModel();
  return await viewModel.fetchDataFavoriteTweet(userId);
});
