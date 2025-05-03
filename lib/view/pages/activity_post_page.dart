import 'package:bouldering_app/model/gym_info.dart';
import 'package:bouldering_app/view/pages/gym_search_page.dart';
import 'package:bouldering_app/view_model/gym_info_provider.dart';
import 'package:bouldering_app/view_model/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis/storage/v1.dart' as gcs;
import 'package:googleapis_auth/auth_io.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;

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
  String? selectedGym; // 選択されたジム名を保持するState
  int? gymId; // 選択されたジム名を保持するselectedGymのジムID(gymId)
  List<File> _mediaFiles = []; // アップロードする写真・動画を保持する変数
  List<String> _uploadedUrls = []; // アップロード完了した写真・動画のURLを保持する変数(リスト)
  FilePickerResult? result;

  bool fromFacilityInfoPage = false; // 施設情報ページから遷移してきたかを判別する変数

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
  void getGymIdFromSelectedGym(String? selectedGym, Map<int, GymInfo> gymRef) {
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
  ///
  /// 返り値
  /// - GoogleCloudStorageに保存した写真の公開URLを返す
  Future<String?> uploadFileToGCS(File file) async {
    // GCS保存先情報
    final jsonString =
        await rootBundle.loadString('assets/keys/service_account.json');
    final credentials =
        ServiceAccountCredentials.fromJson(jsonDecode(jsonString));
    final client = await clientViaServiceAccount(
        credentials, [gcs.StorageApi.devstorageFullControlScope]);
    final storage = gcs.StorageApi(client);
    const bucketName = "boulderingapp_tweets_media";
    final fileName =
        "${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}";
    final media = gcs.Media(file.openRead(), file.lengthSync());

    // GCS保存処理
    await storage.objects.insert(
      gcs.Object()..name = fileName,
      bucketName,
      uploadMedia: media,
    );
    client.close();

    // GCSの公開URL
    return "https://storage.googleapis.com/$bucketName/$fileName";
  }

  /// ■ メソッド
  /// - GCS保存する写真を選択する
  Future<void> _pickMultipleImages() async {
    result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );

    if (result != null && result!.files.isNotEmpty) {
      setState(() {
        final selectedFiles = result!.paths.map((path) => File(path!)).toList();

        _mediaFiles.addAll(selectedFiles);
        if (_mediaFiles.length > 5) {
          _mediaFiles = _mediaFiles.sublist(0, 5); // 5枚の制限
        }
      });
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
  Future<int?> _insertBoulLogTweet(
    String userId,
    int gymId,
    String visitedDate,
    String tweetContents,
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
    });

    try {
      // HTTP POST
      final response = await http.post(
        url,
        headers: {'content-type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final tweetId = responseBody['tweet_id'];
        return tweetId;
      } else {
        print("エラー:${response.statusCode}");
      }
    } catch (error) {
      print("例外発生: $error");
      return null;
    }

    return null;
  }

  /// ■ メソッド
  /// ツイートに紐づいた写真・動画をDBに保存する処理
  ///
  /// 引数
  /// - [tweetId] ツイートID
  /// - [mediaUrl] 写真・動画のURL
  /// - [mediaType] 'photo' または 'video'
  Future<void> _insertBoulLogTweetMedia(
    int tweetId,
    String mediaUrl,
    String mediaType,
  ) async {
    final url = Uri.parse(
            'https://us-central1-gcp-compute-engine-441303.cloudfunctions.net/getData')
        .replace(queryParameters: {
      'request_id': '7',
      'tweet_id': tweetId.toString(),
      'media_url': mediaUrl,
      'media_type': mediaType,
    });

    try {
      final response = await http.post(
        url,
        headers: {'content-type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print("メディア登録成功: $mediaUrl");
      } else {
        print("メディア登録失敗: ${response.statusCode}");
      }
    } catch (error) {
      print("例外発生: $error");
    }
  }

  /// ■ Widget build
  @override
  Widget build(BuildContext context) {
    // ジム情報参照
    // final gymRef = ref.read(gymProvider);
    final gymRef = ref.read(gymInfoProvider);
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
                    /* ジムID取得 */
                    getGymIdFromSelectedGym(selectedGym, gymRef);

                    if (gymId != null) {
                      /* ツイート内容のDB登録処理 */
                      final int? tweetId = await _insertBoulLogTweet(
                        userRef!.userId,
                        gymId!,
                        DateFormat('yyyy-MM-dd').format(_selectedDate),
                        _textController.text,
                      );

                      /* メディアをGCSへアップロードする, URLをDB保存する */
                      _uploadedUrls.clear(); // リセット
                      for (final file in _mediaFiles) {
                        // GCSへのアップロード
                        final uploadedUrl = await uploadFileToGCS(file);
                        if ((uploadedUrl != null) && (tweetId != null)) {
                          // GCSへアップロードしたメディアURLをDB保存
                          _insertBoulLogTweetMedia(
                            tweetId,
                            uploadedUrl,
                            'photo',
                          );
                          _uploadedUrls.add(uploadedUrl);
                        }
                      }
                      print("アップロード完了URL一覧: $_uploadedUrls");

                      /* 投稿ページ初期化 */
                      setState(() {
                        _selectedDate = DateTime.now();
                        selectedGym = null;
                        gymId = null;
                        _textController.clear();
                        _mediaFiles.clear();
                        _uploadedUrls.clear();
                      });

                      /* 施設情報から遷移して投稿する場合，投稿後に戻る処理 */
                      if (fromFacilityInfoPage) {
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 写真一覧
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          // children: _mediaFiles
                          //     .map((file) => Padding(
                          //           padding: const EdgeInsets.only(right: 8.0),
                          //           child: Image.file(file,
                          //               width: 100,
                          //               height: 100,
                          //               fit: BoxFit.cover),
                          //         ))
                          //     .toList(),

                          // 追加
                          children: [
                            ..._mediaFiles.asMap().entries.map((entry) {
                              final index = entry.key;
                              final file = entry.value;
                              return Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Image.file(file,
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover),
                                  ),

                                  // ✗ボタン
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _mediaFiles.removeAt(index);
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.close,
                                            size: 16, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ],
                          // 追加
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 写真追加ボタン
                      GestureDetector(
                        onTap: () {
                          // 写真を選択してアップロード
                          _pickMultipleImages();
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
