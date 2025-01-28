import 'package:bouldering_app/view/components/boul_log.dart';
import 'package:bouldering_app/view/components/switcher_tab.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BoulLogPage extends StatelessWidget {
  const BoulLogPage({super.key});

  // データを非同期で取得する関数
  Future<List<String>> fetchData(String tab) async {
    await Future.delayed(const Duration(seconds: 3)); // 擬似的な遅延，ここでデータ取得を実現

    if (tab == "みんなのボル活") {
      return List.generate(2, (index) => "みんなのボル活データ $index");
    } else {
      return List.generate(5, (index) => "お気に入りデータ $index");
    }
  }

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

  Future<List<dynamic>> fetchDataFavoriteTweet() async {
    int requestId = 6;

    final url = Uri.parse(
            'https://us-central1-gcp-compute-engine-441303.cloudfunctions.net/getData')
        .replace(queryParameters: {
      'request_id': requestId.toString(),
      // 'user_id': user_id.toStrint()  // ここに、ログインしていた時のグローバル情報を投げる必要がある。
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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          body: SafeArea(
        child: Column(
          children: [
            // タブバー部分
            const SwitcherTab(leftTabName: "みんなのボル活", rightTabName: "お気に入り"),
            Expanded(
              child: TabBarView(
                children: [
                  // タブ1：みんなのボル活
                  // FutureBuilder<List<String>>(
                  // future: fetchData("みんなのボル活"),
                  FutureBuilder<List<dynamic>>(
                    future: fetchDataTweet(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                            child: Text("Errorが発生しました： ${snapshot.error}"));
                      } else if (snapshot.hasData) {
                        final data = snapshot.data!;
                        return ListView.builder(
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            final tweet = data[index];
                            final String userName = tweet['user_name'];
                            final String gymName = tweet['gym_name'];
                            final String prefecture = tweet['prefecture'];
                            final String date =
                                DateTime.parse(tweet['visited_date'])
                                        .toLocal()
                                        .toString()
                                        .split(' ')[
                                    0]; // visited_dateをYYYY-MM-DDにフォーマット
                            final String activity = tweet['tweet_contents'];

                            return BoulLog(
                              userName: userName,
                              date: date,
                              gymName: gymName,
                              prefecture: prefecture,
                              activity: activity,
                            );
                          },
                        );
                      } else {
                        return const Center(child: Text("データが見つかりませんでした．"));
                      }
                    },
                  ),

                  // タブ2：お気に入り
                  FutureBuilder<List<String>>(
                    future: fetchData("お気に入り"),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                            child: Text("Errorが発生しました： ${snapshot.error}"));
                      } else if (snapshot.hasData) {
                        final data = snapshot.data!;
                        return ListView.builder(
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            return BoulLog();
                          },
                        );
                      } else {
                        return const Center(child: Text("データが見つかりませんでした．"));
                      }
                    },
                  ),

                  // タブ3：お気に入りユーザーのみを表示する
                  FutureBuilder<List<dynamic>>(
                      future: fetchDataFavoriteTweet(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text("Errorが発生しました: ${snapshot.error}"));
                        } else if (snapshot.hasData) {
                          final data = snapshot.data!;
                          return ListView.builder(
                              itemCount: data.length,
                              itemBuilder: (context, index) {
                                final tweet = data[index];
                                final String userName = tweet['user_name'];
                                final String gymName = tweet['gym_name'];
                                final String prefecture = tweet['prefecture'];
                                final String date =
                                    DateTime.parse(tweet['visited_date'])
                                        .toLocal()
                                        .toString()
                                        .split(' ')[0];
                                final String activity = tweet['tweet_contents'];

                                return BoulLog(
                                    userName: userName,
                                    date: date,
                                    gymName: gymName,
                                    prefecture: prefecture,
                                    activity: activity);
                              });
                        } else {
                          return const Center(child: Text("データが見つかりませんでした"));
                        }
                      }),
                ],
              ),
            ),
          ],
        ),
      )),
    );
  }
}
