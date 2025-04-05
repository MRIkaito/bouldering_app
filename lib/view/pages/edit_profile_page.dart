import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bouldering_app/view/pages/select_home_gym_dialog_page.dart';
import 'package:bouldering_app/view/pages/show_date_selection_dialog_page.dart';
import 'package:bouldering_app/view/pages/gender_selection_dialog_page.dart';
import 'package:bouldering_app/view/pages/edit_username_page.dart';
import 'package:bouldering_app/view/pages/edit_user_introduce_favorite_gym_page.dart';
import 'package:bouldering_app/view/components/edit_setting_item.dart';
import 'package:bouldering_app/view_model/gym_provider.dart';
import 'package:bouldering_app/view_model/user_provider.dart';
import 'package:bouldering_app/view/pages/confirmed_dialog_page.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:googleapis/storage/v1.dart' as storage;
import 'package:googleapis_auth/auth_io.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  /// ■ プロパティ
  File? _imageFile;
  String? _uploadedImageUrl;
  final String bucketName = "my-app-profile-images"; // パケット名
  final String serviceAccountPath = "assets/service_account.json"; // 認証キー

  /// ■ 初期化
  @override
  void initState() {
    super.initState();
  }

  /// ■ メソッド
  /// アイコン画像をギャラリーから選択して設定する
  ///
  /// 引数：なし
  /// 返り値：なし
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery); // ギャラリーから選択

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });

      // 画像をCloud Storageにアップロード
      await _uploadToCloudStorage(_imageFile!);
    }
  }

  /// ■ メソッド
  /// ユーザーアイコンURLの状態を変更する

  /// ■ メソッド
  /// Google Cloud Storageに写真をアップロードする
  ///
  /// 引数
  /// - [imageFile] 写真
  ///
  /// 返り値
  /// - なし
  Future<void> _uploadToCloudStorage(File imageFile) async {
    try {
      // 認証設定
      final credentials = ServiceAccountCredentials.fromJson(
          await File(serviceAccountPath).readAsString());
      final client = await clientViaServiceAccount(
          credentials, [storage.StorageApi.devstorageFullControlScope]);
      final storageApi = storage.StorageApi(client);

      // 画像をバイナリデータに変換
      final imageBytes = await imageFile.readAsBytes();
      final media = storage.Media(Stream.value(imageBytes), imageBytes.length);

      // ファイル名をユニークにする
      String fileName =
          "profile_${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}";
      final storageObject = storage.Object()..name = fileName;

      // アップロード実行
      await storageApi.objects
          .insert(storageObject, bucketName, uploadMedia: media);

      // 公開URLを生成
      final imageUrl = "https://storage.googleapis.com/$bucketName/$fileName";

      setState(() {
        _uploadedImageUrl = imageUrl;
      });
      print("🟢アップロード完了: $imageUrl");
    } catch (error) {
      print("アップロード失敗: $error");
    }
  }

  /* 内部メソッドとして実装したが、必要ないかもしれない
  /// ■ メソッド
  /// - DBに更新後のURLを設定して、状態を更新する処理
  Future<void> updateUserIconUrl(
      String preUserIconUrl, String setUserIconUrl) async {
    final userId = ref.read(userProvider)!.userId;
    final result = await ref
        .read(userProvider.notifier)
        .updateUserIconUrl(_uploadedImageUrl, userId);
    if (context.mounted) {
      confirmedDialog(context, result);
    }
  }
 */

  @override
  Widget build(BuildContext context) {
    final userRef = ref.watch(userProvider);
    final gymRef = ref.watch(gymProvider);
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
                  mainAxisSize: MainAxisSize.min, // 追加
                  children: [
                    GestureDetector(
                      onTap: () async {
                        // 画像をCloudStorageに保存する処理
                        await _pickImage();

                        // 状態変更処理+DBにURLを保存する処理
                        final userId = ref.read(userProvider)!.userId;
                        final result = await ref
                            .read(userProvider.notifier)
                            .updateUserIconUrl(_uploadedImageUrl, userId);
                        if (context.mounted) {
                          confirmedDialog(context, result);
                        }
                      },
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage: _imageFile != null
                            ? NetworkImage(_uploadedImageUrl!)
                            : _imageFile != null
                                ? FileImage(_imageFile!)
                                : null,
                        child: _imageFile == null
                            ? Icon(Icons.camera_alt,
                                size: 40, color: Colors.grey.shade700)
                            : null,
                      ),
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

              // 名前
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
                  subtitle: (userRef?.birthday == null)
                      ? "未設定"
                      : "${userRef!.birthday.year}-${userRef.birthday.month}-${userRef.birthday.day}",
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
