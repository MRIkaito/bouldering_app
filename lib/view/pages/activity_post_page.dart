import 'package:bouldering_app/model/gym.dart';
import 'package:bouldering_app/view/pages/gym_search_page.dart';
import 'package:bouldering_app/view_model/gym_provider.dart';
import 'package:bouldering_app/view_model/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
  // ツイート内容
  final TextEditingController _textController = TextEditingController();
  // ジム訪問日
  DateTime _selectedDate = DateTime.now();
  // 画像取得クラス
  final ImagePicker _picker = ImagePicker();
  File? _mediaFile;
  String? _uploadedFileUrl;
  // TODO：GCSのバケット名を指定(Google Cloud、の設定に合わせて変更する)
  final String bucketName = "your-gcs-bucket-name";
  // 施設情報ページから遷移してきたかを判別する変数
  bool fromFacilityInfoPage = false;
  // 選択されたジム名を保持するState
  String? selectedGym;
  // 選択されたジム名を保持するselectedGymのジムID(gymId)
  int? gymId;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
    fromFacilityInfoPage = extra?['fromPager1'] ?? false;
  }

  /// ■ メソッド
  /// - ジム名からジムIDを取得する
  ///
  /// 引数
  /// - [selectedGym]選ばれたジム名
  ///
  /// 返り値
  /// - なし
  void getGymIdFromSelectedGym(String? selectedGym, Map<int, Gym> gymRef) {
    if (selectedGym == null) {
      // DO NOTHING
    } else {
      // gymRefのGym中のgymNameとselectedGymが一致すれば，その時のkeyをgymIdに代入する
      for (var entry in gymRef.entries) {
        if (entry.value.gymName == selectedGym) {
          gymId = entry.key;
          print("選択されたジムID：$gymId");
          break;
        }
      }
    }

    return;
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
      setState(() {
        _mediaFile = File(pickedFile.path);
      });

      // GCSへアップロード
      // String? url = await _uploadToGCS(_mediaFile!);
      // if (url != null) {
      //   setState(() {
      //     _uploadedFileUrl = url;
      //   });
      // }
    }
  }

  /// ■ メソッド
  /// - ジムを訪問した日を選択するメソッド
  ///
  /// 引数
  /// - [context] ウィジェットツリーの情報
  Future<void> _selectDate(BuildContext context) async {
    final DateTime today = DateTime.now();

    // 初期値：当日
    // 選択開始年：2000年
    // 選択終了年：当年
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: today,
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
    // List<String> photoUrls,
    // List<String> movieUrls,
  ) async {
    // 送信先URL
    final url = Uri.parse(
            'https://us-central1-gcp-compute-engine-441303.cloudfunctions.net/getData')
        .replace(queryParameters: {
      'request_id': '8',
      'user_id': userId.toString(),
      'visited_date': visitedDate,
      'gym_id': gymId.toString(),
      'tweet_contents': tweetContents,
      // 'photosUrl': photoUrls,
      // 'moviesUrl': movieUrls,
    });

    try {
      // HTTP POST
      final response = await http.post(
        url,
        headers: {'content-type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print("アップロード成功");
      } else {
        print("エラー:${response.statusCode}");
      }
    } catch (error) {
      print("例外発生: $error");
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
    // ジム情報参照
    final gymRef = ref.read(gymProvider);
    // ユーザー情報を取得して、ログイン状態にあるかを確認
    final userRef = ref.watch(userProvider);

    return (userRef?.userId == null)
        // 未ログイン
        ? const Center(child: Text("投稿機能の利用は，ログインユーザーのみ可能です"))
        // ログイン状態
        : Scaffold(
            appBar: AppBar(
              title: const Text('ボル活投稿'),
              actions: [
                TextButton(
                  onPressed: () async {
                    print("投稿するボタンが押されました");

                    // 投稿処理
                    getGymIdFromSelectedGym(selectedGym, gymRef);
                    if (gymId != null) {
                      await _insertBoulLogTweet(
                        userRef!.userId,
                        gymId!,
                        DateFormat('yyyy-MM-dd').format(_selectedDate),
                        _textController.text,
                        // ["http"], // TODO：写真URLを配列にする実装
                        // ["http"], // TODO：動画URLを配列にする実装
                      );

                      if (fromFacilityInfoPage) {
                        // 施設情報ページから遷移してきた場合，popして戻る
                        context.pop();
                      } else {
                        // DO NOTHING
                      }
                    } else {
                      print("ジムを選択してください．");
                    }
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
                  // ジム選択フィールド
                  TextField(
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: selectedGym ?? "ジムを選択してください",
                        suffixIcon: const Icon(Icons.arrow_drop_down),
                      ),
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const GymSearchPage()),
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
                            "ジム訪問日：${DateFormat('yyyy.MM.dd').format(_selectedDate)}",
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
                      // 写真表示部分
                      _mediaFile != null
                          ? Image.file(
                              _mediaFile!,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            )
                          : const SizedBox.shrink(),
                      // 写真追加ボタン
                      GestureDetector(
                        onTap: () {
                          // TODO：写真を追加する処理を実装する
                          print("写真を追加");
                          // 写真を選択してアップロード
                          _pickMedia(true);
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
                              // if (_mediaFile != null)
                              //   Image.file(
                              //     _mediaFile!,
                              //     width: 100,
                              //     height: 100,
                              //     fit: BoxFit.cover,
                              //   ),
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
