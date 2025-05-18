import 'package:bouldering_app/view/pages/password_update_dialog_page.dart';
import 'package:bouldering_app/view/pages/show_logout_confimation_dialog_page.dart';
import 'package:flutter/material.dart';
import 'package:bouldering_app/view/components/setting_item.dart';
import 'package:bouldering_app/view/pages/show_exit_confimation_dialog_page.dart';
import 'package:bouldering_app/view/pages/show_mail_address_confirmation_dialog_page.dart';
import 'package:go_router/go_router.dart';

/// ■ クラス
/// 各設定項目へ移動するページ
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
        InkWell(
          onTap: () => {
            // ページ遷移する処理を実装
            passwordUpdateDialog(context),
          },
          child: const SettingItem(text: "パスワード変更"),
        ),
        InkWell(
          onTap: () => {
            // ページ遷移する処理を実装
            showLogoutConfirmationDialog(context),
          },
          child: const SettingItem(text: "ログアウト"),
        ),
        // TODO
        // 250517記載：退会機能は後に実装予定
        /* ここから退会機能
        InkWell(
          onTap: () => {
            // ページ遷移する処理を実装
            showExitConfirmationDialog(context),
          },
          child: const SettingItem(text: "退会"),
        ),
        ここまで退会機能 */
      ])),
    );
  }
}
