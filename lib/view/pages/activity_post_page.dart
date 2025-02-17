import 'package:bouldering_app/view/pages/gym_search_page.dart';
import 'package:bouldering_app/view_model/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis/storage/v1.dart' as gcs;
import 'package:googleapis_auth/auth_io.dart';
import 'dart:convert';
import 'dart:io';

/// ■ クラス
/// - View
/// - ボル活(ツイート)を投稿するページ
/// - StatefulWidget
/// - 状態：テキストの長さ
class ActivityPostPage extends ConsumerStatefulWidget {
  @override
  _ActivityPostPageState createState() => _ActivityPostPageState();
}

/// ■ クラス
/// - -View
/// - ボル活(ツイート)を投稿するページの状態を定義したもの
class _ActivityPostPageState extends ConsumerState<ActivityPostPage> {
  final TextEditingController _textController =
      TextEditingController(); // ツイート内容
  DateTime _selectedDate = DateTime.now(); // ジム訪問日
  final ImagePicker _picker = ImagePicker(); // 画像取得クラス
  File? _mediaFile;
  String? _uploadedFileUrl;
  final String bucketName =
      "your-gcs-bucket-name"; // TODO：GCSのバケット名を指定(Google Cloud、の設定に合わせて変更する)
  // 選択したジム
  String? selectedGym;

  // 初期化
  @override
  void initState() {
    super.initState();
  }

  /// ■ メソッド
  /// - GCSへ画像をアップロードする処理
  ///
  /// 引数
  /// - [file] アップロードするファイル
  Future<String?> _uploadToGCS(File file) async {
    final credentials = ServiceAccountCredentials.fromJson(r'''{
      "type": "service_account",
      "project_id": "your-project-id",
      "private_key_id": "your-private-key-id",
      "private_key": "your-private-key",
      "client_email": "your-client-email",
      "client_id": "your-client-id",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "your-cert-url"
    }''');

    final client = await clientViaServiceAccount(
        credentials, [gcs.StorageApi.devstorageFullControlScope]);
    final storage = gcs.StorageApi(client);

    final media = gcs.Media(file.openRead(), file.lengthSync());
    final fileName = file.path.split('/').last;

    await storage.objects.insert(
      gcs.Object()..name = fileName,
      bucketName,
      uploadMedia: media,
    );

    client.close();
    return "https://storage.googleapis.com/$bucketName/$fileName"; // GCSの公開URL
  }

  /// ■ メソッド
  /// - 画像・動画取得して、GCSヘアップロードする処理
  ///
  /// 引数
  /// - [isImage] 画像であるかを判別するフラグ
  Future<void> _pickMedia(bool isImage) async {
    final XFile? pickedFile = isImage
        ? await _picker.pickImage(source: ImageSource.gallery)
        : await _picker.pickVideo(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState() {
        _mediaFile = File(pickedFile.path);
      }

      // GCSへアップロード
      String? url = await _uploadToGCS(_mediaFile!);
      if (url != null) {
        setState() {
          _uploadedFileUrl = url;
        }
      }
    }
  }

  /// ■ メソッド
  /// - ジムを訪問した日を選択するメソッド
  ///
  /// 引数
  /// - [context] ウィジェットツリーの情報
  Future<void> _selectDate(BuildContext context) async {
    // 初期値：当日
    // 選択開始年：2000年
    // 選択終了年：当年
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(DateTime.now().year, 12, 31),
    );
    // nullでない かつ 選択された日が当日以外の日でtrue
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
  /// - [movieUrls] 動画のURL
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

  /*
    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("メディアアップロード")),
      body: Column(
        children: [
          _mediaFile != null
              ? (_mediaFile!.path.endsWith(".mp4")
                  ? Text("動画が選択されました")
                  : Image.file(_mediaFile!))
              : Text("メディアなし"),

          SizedBox(height: 20),

          ElevatedButton(onPressed: () => _pickMedia(true), child: Text("画像を選択")),
          ElevatedButton(onPressed: () => _pickMedia(false), child: Text("動画を選択")),

          SizedBox(height: 20),

          _uploadedFileUrl != null
              ? Column(
                  children: [
                    Text("アップロード完了"),
                    SelectableText(_uploadedFileUrl!),
                  ],
                )
              : Container(),
        ],
      ),
    );
  }
  */

  /// ■ Widget build
  @override
  Widget build(BuildContext context) {
    // ユーザー情報を取得 / ログイン状態にあるかを確認
    final userRef = ref.watch(userProvider);

    // ログイン状態にないと、投稿できないようにする
    return (userRef?.userId == null)
        // 未ログイン
        ? Center(child: const Text("ログインしないと、投稿はできません"))

        // ログイン状態
        : Scaffold(
            appBar: AppBar(
              title: const Text('ボル活投稿'),
              actions: [
                TextButton(
                  onPressed: () {
                    // 投稿処理
                    print("投稿するボタンが押されました");
                    // TODO：上記消去予定/ 下記実装予定
                    /*
                    _insertBoulLogTweet(
                      user!.userId,
                      1, // TODO：現在はリテラルで置いているがここはジム情報取得して代入するようにする
                      DateFormat('yyyy-MM-DD').format(_selectedDate),
                      _textController.text,
                      ["http"], // TODO：写真URLを配列にする実装
                      ["http"], // TODO：動画URLを配列にする実装
                    );
                    */
                  },
                  child: const Text(
                    '投稿する',
                    style: TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.bold),
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
                  TextField(
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: selectedGym ?? "ジムを選択してください",
                        suffixIcon: Icon(Icons.arrow_drop_down),
                      ),
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => GymSearchPage()),
                        );

                        if (result != null) {
                          setState(() {
                            selectedGym = result as String;
                          });
                        }
                      }),
                  const SizedBox(height: 16),

                  // 日付選択ボタン
                  Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _selectDate(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
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
                          // テスト ---------------------------

                          // ---------------------------
                          print("写真を追加");
                        },
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Column(
                            children: [
                              Icon(Icons.image, size: 30, color: Colors.grey),
                              SizedBox(height: 8),
                              Text(
                                '写真を追加',
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 12),
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
