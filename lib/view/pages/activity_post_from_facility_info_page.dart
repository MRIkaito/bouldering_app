import 'package:bouldering_app/model/gym_info.dart';
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

class ActivityPostFromFacilityInfoPage extends ConsumerStatefulWidget {
  final String gymId;
  const ActivityPostFromFacilityInfoPage({Key? key, required this.gymId})
      : super(key: key);

  @override
  _ActivityPostFromFacilityInfoPage createState() =>
      _ActivityPostFromFacilityInfoPage();
}

class _ActivityPostFromFacilityInfoPage
    extends ConsumerState<ActivityPostFromFacilityInfoPage> {
  final TextEditingController _textController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String? selectedGym;
  int? gymId;
  List<File> _mediaFiles = [];
  List<String> _uploadedUrls = [];
  FilePickerResult? result;
  bool fromFacilityInfoPage = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final gymRef = ref.read(gymInfoProvider);
    final int parsedId = int.tryParse(widget.gymId) ?? 0;
    final gymInfo = gymRef[parsedId];
    if (gymInfo != null) {
      setState(() {
        selectedGym = gymInfo.gymName;
        gymId = parsedId;
      });
    }
  }

  void getGymIdFromSelectedGym(String? selectedGym, Map<int, GymInfo> gymRef) {
    if (selectedGym == null) return;
    for (var entry in gymRef.entries) {
      if (entry.value.gymName == selectedGym) {
        gymId = entry.key;
        print("選択されたジムID：$gymId");
        break;
      }
    }
  }

  Future<String?> uploadFileToGCS(File file) async {
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

    await storage.objects.insert(
      gcs.Object()..name = fileName,
      bucketName,
      uploadMedia: media,
    );
    client.close();

    return "https://storage.googleapis.com/$bucketName/$fileName";
  }

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
          _mediaFiles = _mediaFiles.sublist(0, 5);
        }
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime today = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: today,
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<int?> _insertBoulLogTweet(String userId, int gymId, String visitedDate,
      String tweetContents) async {
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
      final response =
          await http.post(url, headers: {'content-type': 'application/json'});
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

  Future<void> _insertBoulLogTweetMedia(
      int tweetId, String mediaUrl, String mediaType) async {
    final url = Uri.parse(
            'https://us-central1-gcp-compute-engine-441303.cloudfunctions.net/getData')
        .replace(queryParameters: {
      'request_id': '7',
      'tweet_id': tweetId.toString(),
      'media_url': mediaUrl,
      'media_type': mediaType,
    });

    try {
      final response =
          await http.post(url, headers: {'content-type': 'application/json'});
      if (response.statusCode == 200) {
        print("メディア登録成功: $mediaUrl");
      } else {
        print("メディア登録失敗: ${response.statusCode}");
      }
    } catch (error) {
      print("例外発生: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    final gymRef = ref.read(gymInfoProvider);
    final userRef = ref.watch(userProvider);

    return (userRef?.userId == null)
        ? const Center(child: Text("投稿機能の利用は，ログインユーザーのみ可能です"))
        : Scaffold(
            appBar: AppBar(
              title: const Text('ボル活投稿'),
              actions: [
                TextButton(
                  onPressed: () async {
                    getGymIdFromSelectedGym(selectedGym, gymRef);
                    if (gymId != null) {
                      final int? tweetId = await _insertBoulLogTweet(
                        userRef!.userId,
                        gymId!,
                        DateFormat('yyyy-MM-dd').format(_selectedDate),
                        _textController.text,
                      );
                      _uploadedUrls.clear();
                      for (final file in _mediaFiles) {
                        final uploadedUrl = await uploadFileToGCS(file);
                        if ((uploadedUrl != null) && (tweetId != null)) {
                          _insertBoulLogTweetMedia(
                              tweetId, uploadedUrl, 'photo');
                          _uploadedUrls.add(uploadedUrl);
                        }
                      }
                      print("アップロード完了URL一覧: $_uploadedUrls");
                      setState(() {
                        _selectedDate = DateTime.now();
                        selectedGym = null;
                        gymId = null;
                        _textController.clear();
                        _mediaFiles.clear();
                        _uploadedUrls.clear();
                      });
                      if (fromFacilityInfoPage) {
                        context.pop();
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
                  TextField(
                    readOnly: true,
                    enabled: false,
                    decoration: InputDecoration(
                      hintText: selectedGym ?? "ジムを選択してください",
                      suffixIcon: const Icon(Icons.lock_outline),
                    ),
                  ),
                  const SizedBox(height: 16),
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
                  TextField(
                    controller: _textController,
                    maxLength: 400,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText: '今日登ったレベル，時間など好きなことを書きましょう。',
                      border: InputBorder.none,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
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
                        ),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: _pickMultipleImages,
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
                              Text('写真を追加',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12)),
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
