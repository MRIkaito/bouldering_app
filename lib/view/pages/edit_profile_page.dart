import 'package:bouldering_app/view/pages/show_date_selection_dialog_page.dart';
import 'package:bouldering_app/view/pages/show_gender_selection_dialog_page.dart';
import 'package:bouldering_app/view/pages/show_nickname_confirmation_dialog_page.dart';
import 'package:bouldering_app/view/pages/show_self_introduce_favorite_gim_page.dart';
import 'package:bouldering_app/view_model/gym_provider.dart';
import 'package:bouldering_app/view_model/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:bouldering_app/view/components/edit_setting_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final gymRef = ref.read(gymProvider);

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              InkWell(
                onTap: () => {
                  // ページ遷移する処理を実装
                  showSelfIntroduceFavoriteGimPage(context),
                },
                child: EditSettingItem(
                  title: 'ニックネーム',
                  subtitle: (userRef?.userName == null)
                      ? '名前を取得できませんでした'
                      : userRef!.userName,
                ),
              ),
              InkWell(
                onTap: () => {
                  // ページ遷移する処理を実装
                  showSelfIntroduceFavoriteGim(context, "自己紹介"),
                },
                child: EditSettingItem(
                  title: '自己紹介',
                  subtitle: (userRef?.selfIntroduce == null)
                      ? '自己紹介文を取得できませんでした'
                      : userRef!.selfIntroduce,
                ),
              ),
              InkWell(
                onTap: () => {
                  // ページ遷移する処理を実装
                  showSelfIntroduceFavoriteGim(context, "好きなジム"),
                },
                child: EditSettingItem(
                  title: '好きなジム',
                  subtitle: (userRef?.favoriteGyms == null)
                      ? '自己紹介文を取得できませんでした'
                      : userRef!.favoriteGyms,
                ),
              ),
              InkWell(
                onTap: () => {
                  // ページ遷移する処理を実装
                  showDateSelectionDialog(context, "ボルダリングデビュー日"),
                },
                child: EditSettingItem(
                  title: 'ボルダリングデビュー日',
                  subtitle: (userRef?.boulStartDate == null)
                      ? "YYYY-MM"
                      : "${userRef!.boulStartDate.year}-${userRef!.boulStartDate.month}",
                ),
              ),
              InkWell(
                onTap: () => {
                  // ページ遷移する処理を実装
                  showDateSelectionDialog(context, "生年月日"),
                },
                child: EditSettingItem(
                  title: '生年月日(非公開)',
                  // TODO：userクラスに，生年月日を格納するように変更
                  subtitle: '1998-07-22',
                ),
              ),
              InkWell(
                onTap: () => {
                  // ページ遷移する処理を実装
                  showGenderSelectionDialog(context, "性別"),
                },
                child: EditSettingItem(
                  title: '性別 (非公開)',
                  // TODO：userクラスに，性別を格納するように変更
                  subtitle: '男性',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
