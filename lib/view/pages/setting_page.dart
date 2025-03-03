import 'package:bouldering_app/view/pages/edit_profile_page.dart';
import 'package:bouldering_app/view/pages/show_logout_confimation_dialog_page.dart';
import 'package:flutter/material.dart';
import 'package:bouldering_app/view/components/setting_item.dart';
import 'package:bouldering_app/view/pages/show_exit_confimation_dialog_page.dart';
import 'package:bouldering_app/view/pages/show_mail_address_confirmation_dialog_page.dart';
import 'package:go_router/go_router.dart';

// 遷移先のページ
class SettingPage extends StatelessWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
          child: Column(children: [
        InkWell(
          onTap: () => {
            context.push("/EditProfile"),
          },
          child: const SettingItem(text: "プロフィール編集"),
        ),
        InkWell(
          onTap: () => {
            // ページ遷移する処理を実装
            mailAddressConfirmationDialog(context),
          },
          child: const SettingItem(text: "メールアドレス変更"),
        ),
        // TODO；パスワード変更の欄もいれる
        InkWell(
          onTap: () => {
            // ページ遷移する処理を実装
            showLogoutConfirmationDialog(context), // 退会ダイアログを表示
          },
          child: const SettingItem(text: "ログアウト"),
        ),
        InkWell(
          onTap: () => {
            // ページ遷移する処理を実装
            showExitConfirmationDialog(context), // 退会ダイアログを表示
          },
          child: const SettingItem(text: "退会"),
        ),
      ])),
    );
  }
}
