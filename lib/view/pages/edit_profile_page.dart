import 'package:bouldering_app/view_model/gym_info_provider.dart';
import 'package:bouldering_app/view/pages/select_home_gym_dialog_page.dart';
import 'package:bouldering_app/view/pages/show_date_selection_dialog_page.dart';
import 'package:bouldering_app/view/pages/gender_selection_dialog_page.dart';
import 'package:bouldering_app/view/pages/edit_username_page.dart';
import 'package:bouldering_app/view/pages/edit_user_introduce_favorite_gym_page.dart';
import 'package:bouldering_app/view/components/edit_setting_item.dart';
import 'package:bouldering_app/view_model/user_provider.dart';
import 'package:bouldering_app/view/pages/confirmed_dialog_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis/storage/v1.dart' as gcs;
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:crypto/crypto.dart';
import 'dart:io';
import 'dart:convert';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  /// ■ プロパティ
  File? _imageFile; // ユーザーアイコンの写真ファイル

  /// ■ 初期化
  @override
  void initState() {
    super.initState();
  }

  /// ■ メソッド
  /// アイコン画像をギャラリーから選択して設定する
  ///
  /// 引数：なし
  ///
  /// 返り値：
  /// - true : 写真選択
  /// - false : 写真未選択
  Future<bool> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _imageFile = File(result.files.single.path!);
      });
      return true;
    } else {
      return false;
    }
  }

  /// ■ メソッド
  /// Google Cloud Storageにユーザーアイコン写真をアップロードする
  ///
  /// 引数
  /// - [file] 写真
  ///
  /// 返り値
  /// - GoogleCloudStorageに保存したユーザーアイコン写真の公開URLを返す
  Future<String?> _uploadToCloudStorage(File file) async {
    // GCS保存先情報
    final jsonString =
        await rootBundle.loadString('assets/keys/service_account.json');
    final credentials =
        ServiceAccountCredentials.fromJson(jsonDecode(jsonString));
    final client = await clientViaServiceAccount(
        credentials, [gcs.StorageApi.devstorageFullControlScope]);
    final storage = gcs.StorageApi(client);
    const bucketName = "boulderingapp_tweets_media";

    // ファイルの中身を読み込み，ハッシュ値を作成する
    final bytes = await file.readAsBytes();
    final digest = sha256.convert(bytes);

    // ファイル名作成(prefix + ハッシュ値)
    final fileName =
        "user_icon_url_${digest.toString()}${path.extension(file.path)}";

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

  @override
  Widget build(BuildContext context) {
    final userRef = ref.watch(userProvider);
    final gymRef = ref.watch(gymInfoProvider);
    final String gender;

    if (userRef?.gender == null) {
      gender = "未回答";
    } else {
      switch (userRef!.gender) {
        case 0:
          gender = '未回答';
        case 1:
          gender = '男性';
        case 2:
          gender = '女性';
        default:
          gender = '未回答';
      }
    }

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // アイコン
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage: (ref.watch(userProvider) != null) &&
                                // ignore: unnecessary_null_comparison
                                (ref.watch(userProvider)!.userIconUrl !=
                                    null) &&
                                (ref
                                    .watch(userProvider)!
                                    .userIconUrl
                                    .startsWith('https://'))
                            ? NetworkImage(ref.watch(userProvider)!.userIconUrl)
                            : null,
                        child: (ref.watch(userProvider) == null) ||
                                // ignore: unnecessary_null_comparison
                                (ref.watch(userProvider)!.userIconUrl ==
                                    null) ||
                                (!ref
                                    .watch(userProvider)!
                                    .userIconUrl
                                    .startsWith('https://'))
                            ? Icon(Icons.camera_alt,
                                size: 40, color: Colors.grey.shade700)
                            : null,
                      ),
                      onTap: () async {
                        // 画像選択
                        final isPickedImage = await _pickImage();

                        if ((isPickedImage == true) && (_imageFile != null)) {
                          // CloudStorageに保存
                          final _uploadedImageUrl =
                              await _uploadToCloudStorage(_imageFile!);

                          // 画像URLをDB保存 + 状態変更
                          final userId = ref.read(userProvider)!.userId;
                          final result = await ref
                              .read(userProvider.notifier)
                              .updateUserIconUrl(_uploadedImageUrl!, userId);

                          if (context.mounted) {
                            confirmedDialog(context, result);
                          }
                        } else {
                          return;
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'アイコンを編集する',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ニックネーム
              InkWell(
                onTap: () => {
                  // ページ遷移
                  editUsernamePage(context),
                },
                child: EditSettingItem(
                  title: 'ニックネーム',
                  subtitle: (userRef?.userName == null)
                      ? '名前を取得できませんでした'
                      : userRef!.userName,
                ),
              ),

              // 自己紹介
              InkWell(
                onTap: () => {
                  // ページ遷移
                  showSelfIntroduceFavoriteGim(context, "自己紹介"),
                },
                child: EditSettingItem(
                  title: '自己紹介',
                  subtitle: (userRef?.userIntroduce == null)
                      ? '未設定'
                      : userRef!.userIntroduce,
                ),
              ),

              // 好きなジム
              InkWell(
                onTap: () => {
                  // ページ遷移
                  showSelfIntroduceFavoriteGim(context, "好きなジム"),
                },
                child: EditSettingItem(
                  title: '好きなジム',
                  subtitle: (userRef?.favoriteGym == null)
                      ? '未設定'
                      : userRef!.favoriteGym,
                ),
              ),

              // ボルダリングデビュー日
              InkWell(
                onTap: () => {
                  // ページ遷移
                  showDateSelectionDialog(context, "ボルダリングデビュー日"),
                },
                child: EditSettingItem(
                  title: 'ボルダリングデビュー日',
                  subtitle: (userRef?.boulStartDate == null)
                      ? "未設定"
                      : "${userRef!.boulStartDate.year}-${userRef.boulStartDate.month}-${userRef.boulStartDate.day}",
                ),
              ),

              // ホームジム
              InkWell(
                onTap: () => {
                  // ページ遷移
                  selectHomeGymDialog(
                      context, "ホームジム", gymRef[userRef.homeGymId]!.gymName),
                },
                child: EditSettingItem(
                  title: 'ホームジム',
                  subtitle: ((userRef?.homeGymId == null) &&
                          ((gymRef[userRef!.homeGymId]?.gymName) == null))
                      ? "選択無し"
                      : gymRef[userRef!.homeGymId]!.gymName,
                ),
              ),

              // 生年月日
              InkWell(
                onTap: () => {
                  // ページ遷移
                  showDateSelectionDialog(context, "生年月日"),
                },
                child: EditSettingItem(
                  title: '生年月日(非公開)',
                  subtitle: (userRef.birthday == null)
                      ? "未設定"
                      : "${userRef.birthday.year}-${userRef.birthday.month}-${userRef.birthday.day}",
                ),
              ),

              // 性別
              InkWell(
                onTap: () => {
                  // ページ遷移する処理を実装
                  genderSelectionDialog(context, "性別"),
                },
                child: EditSettingItem(
                  title: '性別 (非公開)',
                  subtitle: gender,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
