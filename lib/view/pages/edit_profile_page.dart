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

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  // 初期化
  @override
  void initState() {
    super.initState();
  }

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
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey.shade300,
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
