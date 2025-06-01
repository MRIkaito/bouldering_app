import 'package:bouldering_app/model/gym_info.dart';
import 'package:bouldering_app/view/components/app_logo.dart';
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
  // ツイートを編集するとき，すでにあるデータを受け取るための変数
  final Map<String, dynamic>? initialData;
  const ActivityPostPage({
    Key? key,
    this.initialData,
  }) : super(key: key);

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

  // 編集時に利用する変数
  int? editingTweetId;
  bool isEditMode = false;
  String? originalText; // 編集前のツイート本文
  DateTime? originalDate; // 編集前のジム訪問日
  List<String> originalUrls = []; // 編集前の写真URL

  // 投稿処理中か判定する変数
  bool _isPosting = false;

  @override
  void initState() {
    super.initState();

    // 編集機能によって呼び出されたかを判定する
    final data = widget.initialData;
    if (data != null) {
      // 編集モード判定 trueへ変更
      isEditMode = true;
      editingTweetId = data['tweetId'];
      _textController.text = data['tweetContents'] ?? '';
      selectedGym = data['gymName'];
      gymId = int.tryParse(data['gymId'] ?? '');
      _selectedDate =
          DateTime.tryParse(data['visitedDate'] ?? '') ?? DateTime.now();
      _uploadedUrls = List<String>.from(data['mediaUrls'] ?? []);
      originalText = _textController.text;
      originalDate = _selectedDate;
      originalUrls = List<String>.from(_uploadedUrls);
    }
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   // TODO：ジムからのページ遷移化を確認するやつ：使わないと思う
  //   // final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
  //   // fromFacilityInfoPage = extra?['fromPager1'] ?? false;
  // }

  /// ■ メソッド
  /// - 選択されたジム名から，ジムIDを取得する
  /// - 選択されたジムがまだ何もないとき，押下されても何もしない
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

        // 現在の枚数(既存写真+追加写真)を合算
        int totalSelectedCount = _uploadedUrls.length + _mediaFiles.length;
        final availableSlots = 5 - totalSelectedCount;

        if (availableSlots <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('写真は最大5枚までです')),
          );
          return;
        }

        final filesToAdd = selectedFiles.take(availableSlots).toList();
        _mediaFiles.addAll(filesToAdd);

        if (filesToAdd.length < selectedFiles.length) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('写真は最大5枚までです')),
          );
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

    await http.post(url, headers: {'content-type': 'application/json'});

    /* 下記デバッグ用 */
    // try {
    //   final response = await http.post(
    //     url,
    //     headers: {'content-type': 'application/json'},
    //   );

    //   if (response.statusCode == 200) {
    //     print("メディア登録成功: $mediaUrl");
    //   } else {
    //     print("メディア登録失敗: ${response.statusCode}");
    //   }
    // } catch (error) {
    //   print("例外発生: $error");
    // }
  }

  /// ■ メソッド
  /// ツイートを更新する関数
  ///
  /// 引数：
  /// - tweetId：更新対象のツイートID（必須）
  /// - userId：ログイン中のユーザーID（ログ使用などに使うなら）
  /// - gymId：ジムのID
  /// - visitedDate：ジムに行った日
  /// - tweetContents：更新後のツイート内容
  /// - ※ movieUrl や画像URLは別関数で更新（必要であれば）
  ///
  /// 返り値：
  /// - 成功時：true
  /// - 失敗時：false
  Future<bool> updateTweet(
    int tweetId,
    String userId,
    int gymId,
    String visitedDate, // 形式：yyyy-MM-dd
    String tweetContents,
  ) async {
    final url = Uri.parse(
      'https://us-central1-gcp-compute-engine-441303.cloudfunctions.net/getData',
    ).replace(queryParameters: {
      'request_id': '29',
      'tweet_id': tweetId.toString(),
      'tweet_contents': tweetContents,
      'visited_date': visitedDate,
      'gym_id': gymId.toString(),
    });

    try {
      final response = await http.post(url, headers: {
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        print("ツイート更新成功");
        return true;
      } else {
        print("ツイート更新失敗: ${response.statusCode}, ${response.body}");
        return false;
      }
    } catch (e) {
      print("更新リクエスト中の例外: $e");
      return false;
    }
  }

  /// ■ メソッド
  /// - GCSに登録した画像URLを管理しているテーブルから，削除したい画像URL
  /// - (とその画像URLに紐づくツイートID) を受け取り，その画像URLを削除する処理
  ///
  /// 引数：
  /// - [tweetId] ツイートID. 画像URLに紐づいたツイートのIDを受け取る
  /// - [mediaUrl] 画像のURL
  Future<void> deleteSingleTweetMedia(int tweetId, String mediaUrl) async {
    final url = Uri.parse(
      'https://us-central1-gcp-compute-engine-441303.cloudfunctions.net/getData',
    ).replace(queryParameters: {
      'request_id': '30',
      'tweet_id': tweetId.toString(),
      'media_url': mediaUrl,
    });

    await http.delete(url);

    /* 下記デバッグ用 */
    // try {
    //   final response = await http.delete(url);
    //   if (response.statusCode == 200) {
    //     print("既存メディア削除成功");
    //   } else {
    //     print("削除失敗: ${response.statusCode}, ${response.body}");
    //   }
    // } catch (e) {
    //   print("削除リクエストエラー: $e");
    // }
  }

  /// ■ Widget build
  @override
  Widget build(BuildContext context) {
    // ジム情報参照
    final gymRef = ref.read(gymInfoProvider);
    // ユーザー情報を取得して、ログイン状態にあるかを確認
    final userRef = ref.watch(userProvider);

    return (userRef?.userId == null)
        // 未ログイン
        ? const Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 余白
              SizedBox(height: 128),

              // ロゴ
              Center(child: AppLogo()),
              SizedBox(height: 16),

              Text(
                'イワノボリタイに登録しよう',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF0056FF),
                  fontSize: 20,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                  letterSpacing: -0.50,
                ),
              ),
              SizedBox(height: 16),

              Text(
                'ログインして日々の\nボル活を投稿しよう！',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                  letterSpacing: -0.50,
                ),
              ),
              SizedBox(height: 16),

              Text(
                'ジムで登った記録や\n感想を残しましょう！',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                  letterSpacing: -0.50,
                ),
              ),
            ],
          )

        // ログイン状態
        : Scaffold(
            appBar: AppBar(
              title: const Text('ボル活投稿'),
              backgroundColor: const Color(0xFFFEF7FF),
              surfaceTintColor: const Color(0xFFFEF7FF),
              actions: [
                TextButton(
                  onPressed: _isPosting
                      ? null
                      : () async {
                          // 投稿(編集)処理開始
                          setState(() => _isPosting = true);

                          // ジムID取得
                          getGymIdFromSelectedGym(selectedGym, gymRef);

                          if (gymId == null) {
                            /* ジムIDが選択されていないときの処理 */
                            // ジム選択を促すメッセージのSnackBarを表示
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('ジムを選択してください')),
                            );
                          } else {
                            /* ジムIDが取得されているときの処理：「編集」と「新規投稿」で別れている */
                            if (isEditMode && editingTweetId != null) {
                              /* 編集モード */
                              // 変更があったかを確認する
                              final isSameText =
                                  (originalText == _textController.text);
                              final isSameDate = (originalDate ==
                                  DateFormat('yyyy-MM-dd')
                                      .format(_selectedDate));
                              final isSameMedia = Set.from(originalUrls)
                                      .containsAll(_uploadedUrls) &&
                                  Set.from(_uploadedUrls)
                                      .containsAll(originalUrls);

                              // すべて変更がない状態で投稿するが押下されたときは何もせずに終了・前の画面へ戻る
                              if (isSameText && isSameDate && isSameMedia) {
                                // 変更がなければSnackBar表示のみで戻る
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('編集は完了しました')),
                                );
                                context.pop();
                                return;
                              }

                              // 編集API呼び出し(ツイート本文，ジム，日付の更新)
                              await updateTweet(
                                editingTweetId!,
                                userRef!.userId,
                                gymId!,
                                DateFormat('yyyy-MM-dd').format(_selectedDate),
                                _textController.text,
                              );

                              // 差分で削除する：originalUrls にあって _uploadedUrls にないものだけを削除
                              for (final url in originalUrls) {
                                if (!_uploadedUrls.contains(url)) {
                                  // このURLは削除されたとみなす → Cloud Functionで個別削除処理を作って呼ぶ
                                  await deleteSingleTweetMedia(
                                      editingTweetId!, url);
                                }
                              }

                              // 新規画像をアップロードし、アップロード成功URLは _uploadedUrls に追加
                              for (final file in _mediaFiles) {
                                final uploadedUrl = await uploadFileToGCS(file);
                                if (uploadedUrl != null) {
                                  await _insertBoulLogTweetMedia(
                                      editingTweetId!, uploadedUrl, 'photo');
                                  _uploadedUrls
                                      .add(uploadedUrl); // 既存も新規もこの配列で管理
                                }
                              }

                              // 編集完了のSnackBarを表示
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('編集が完了しました')),
                              );

                              print("画像更新完了: $_uploadedUrls");
                              context.pop();
                            } else {
                              /* 新規投稿モード */
                              // ツイート内容のDB登録処理
                              final int? tweetId = await _insertBoulLogTweet(
                                userRef!.userId,
                                gymId!,
                                DateFormat('yyyy-MM-dd').format(_selectedDate),
                                _textController.text,
                              );

                              // メディアをGCSへアップロードする, URLをDB保存する
                              _uploadedUrls.clear(); // 初期化・リセット
                              for (final file in _mediaFiles) {
                                // GCSへのアップロード
                                final uploadedUrl = await uploadFileToGCS(file);
                                // GCSへアップロードしたメディアURLをDB保存
                                if ((uploadedUrl != null) &&
                                    (tweetId != null)) {
                                  _insertBoulLogTweetMedia(
                                    tweetId,
                                    uploadedUrl,
                                    'photo',
                                  );
                                  _uploadedUrls.add(uploadedUrl);
                                }
                              }
                              print("アップロード完了URL一覧: $_uploadedUrls");

                              // 投稿ページ初期化
                              setState(() {
                                _selectedDate = DateTime.now();
                                selectedGym = null;
                                gymId = null;
                                _textController.clear();
                                _mediaFiles.clear();
                                _uploadedUrls.clear();
                              });

                              // 投稿完了のSnackBarを表示
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('投稿が完了しました')),
                              );
                            }
                          }

                          // 投稿(編集)処理終了
                          setState(() => _isPosting = false);

                          return;
                        },
                  child: _isPosting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.blue,
                          ),
                        )
                      : const Text(
                          '投稿する',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ジム選択フィールド
                    TextField(
                        readOnly: true,
                        enabled: !isEditMode, // 編集モードにある場合はタップ不可能にする
                        decoration: InputDecoration(
                          hintText: selectedGym ?? "ジムを選択してください",
                          hintStyle: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
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
                      maxLines: 10,
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
                            children: [
                              // 編集モード時：既存画像を表示
                              if (_uploadedUrls.isNotEmpty)
                                ..._uploadedUrls.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final url = entry.value;

                                  return Stack(
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: Image.network(
                                          url,
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _uploadedUrls.removeAt(index);
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
                                }),

                              // 新規画像を表示（✗ボタン付き）
                              ..._mediaFiles.asMap().entries.map((entry) {
                                final index = entry.key;
                                final file = entry.value;
                                return Stack(
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: Image.file(
                                        file,
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
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
                              }),
                            ],
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
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // 写真枚数カウンター
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            '${_uploadedUrls.length + _mediaFiles.length} / 5枚',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
