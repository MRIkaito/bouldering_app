import 'package:bouldering_app/view/pages/show_date_selection_dialog_page.dart';
import 'package:bouldering_app/view/pages/show_gender_selection_dialog_page.dart';
import 'package:bouldering_app/view/pages/show_nickname_confirmation_dialog_page.dart';
import 'package:bouldering_app/view/pages/show_self_introduce_favorite_gim_page.dart';
import 'package:flutter/material.dart';
import 'package:bouldering_app/view/components/edit_setting_item.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  subtitle: 'むらーん',
                ),
              ),
              InkWell(
                onTap: () => {
                  // ページ遷移する処理を実装
                  showSelfIntroduceFavoriteGim(context, "自己紹介"),
                },
                child: EditSettingItem(
                  title: '自己紹介',
                  subtitle: 'よろしく！',
                ),
              ),
              InkWell(
                onTap: () => {
                  // ページ遷移する処理を実装
                  showSelfIntroduceFavoriteGim(context, "好きなジム"),
                },
                child: EditSettingItem(
                  title: '好きなジム',
                  subtitle: 'フォークボルダリングジム',
                ),
              ),
              InkWell(
                onTap: () => {
                  // ページ遷移する処理を実装
                  showDateSelectionDialog(context, "ボルダリングデビュー日"),
                },
                child: EditSettingItem(
                  title: 'ボルダリングデビュー日',
                  subtitle: '2023-12-11',
                ),
              ),
              InkWell(
                onTap: () => {
                  // ページ遷移する処理を実装
                  showDateSelectionDialog(context, "生年月日"),
                },
                child: EditSettingItem(
                  title: '生年月日',
                  subtitle: '1998-07-22',
                ),
              ),
              InkWell(
                onTap: () => {
                  // ページ遷移する処理を実装
                  showGenderSelectionDialog(context, "性別"),
                },
                child: EditSettingItem(
                  title: '性別',
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
