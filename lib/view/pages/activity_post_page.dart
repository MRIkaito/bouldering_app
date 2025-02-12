import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 日付フォーマット用のパッケージ
import 'package:http/http.dart' as http;
import 'dart:convert';

/// ■ クラス
/// - View
/// - ボル活(ツイート)を投稿するページ
/// - StatefulWidget
/// - 状態：テキストの長さ
class ActivityPostPage extends StatefulWidget {
  @override
  _ActivityPostPageState createState() => _ActivityPostPageState();
}

/// ■ クラス
/// - -View
/// - ボル活(ツイート)を投稿するページの状態を定義したもの
class _ActivityPostPageState extends State<ActivityPostPage> {
  final TextEditingController _textController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  int _currentTextLength = 0;

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      setState(() {
        _currentTextLength = _textController.text.length;
      });
    });
  }

  // 日付選択のメソッド
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  /// ■メソッド
  /// - 投稿内容をPOSTする処理
  ///
  /// 引数
  /// - [userId] ログイン中のユーザーID
  /// - [gymId] 訪問したジムのID
  /// - [visitedDate] 訪問した日
  /// - [photoUrls] 写真のURL
  /// - [movieUrls]動画のURL
  Future<void> _insertBoulLogTweet(
      String userId,
      int gymId,
      String visitedDate,
      String tweetContents,
      List<String> photoUrls,
      List<String> movieUrls) async {
    // 送信先URL
    final url = Uri.parse(
        'https://us-central1-gcp-compute-engine-441303.cloudfunctions.net/getData');

    // リクエスト
    final Map<String, dynamic> requestBody = {
      'gym_id': gymId.toString(),
      'user_id': userId.toString(),
      'visited_date': visitedDate,
      'tweet_content': tweetContents,
      'photosUrl': photoUrls,
      'moviesUrl': movieUrls
    }.map(
        (key, value) => MapEntry(key, value is List ? value.join(',') : value));

    try {
      // HTTP POST
      final response = await http.post(url,
          headers: {'content-type': 'application/json'},
          body: jsonEncode(requestBody));

      // レスポンスを確認
      if (response.statusCode == 200) {
        print("ここにアップロード成功時のメッセージ");
      } else {
        // 400/ 500エラー：何らかの問題発生
        print("ここにエラー発生時のメッセージ");
      }
    } catch (error) {
      print("例外発生");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ボル活投稿'),
        actions: [
          TextButton(
            onPressed: () {
              // 投稿処理
              print("投稿するボタンが押されました");
            },
            child: const Text(
              '投稿する',
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ジム名
            const Text(
              'フォークボルダリングジム',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // 日付選択ボタン
            Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.grey[600]),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      DateFormat('yyyy.MM.dd').format(_selectedDate),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // テキスト入力フィールド
            TextField(
              controller: _textController,
              maxLength: 400,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: '今日登ったレベル，時間など好きなことを書きましょう。',
                border: InputBorder.none,
              ),
            ),

            // カウンターと写真追加ボタン
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 写真追加ボタン
                GestureDetector(
                  onTap: () {
                    print("写真を追加");
                  },
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: const [
                        Icon(Icons.image, size: 30, color: Colors.grey),
                        SizedBox(height: 8),
                        Text(
                          '写真を追加',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
