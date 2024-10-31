import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:bouldering_app/view/components/setting_item.dart';
import 'package:bouldering_app/view/pages/show_exit_confimation_dialog_page.dart';

// 遷移先のページ
@RoutePage()
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
            // ページ遷移する処理を実装
          },
          child: SettingItem(text: "プロフィール編集"),
        ),
        InkWell(
          onTap: () => {
            // ページ遷移する処理を実装
          },
          child: SettingItem(text: "メールアドレス"),
        ),
        InkWell(
          onTap: () => {
            // ページ遷移する処理を実装
          },
          child: SettingItem(text: "ログアウト"),
        ),
        InkWell(
          onTap: () => {
            // ページ遷移する処理を実装
            showExitConfirmationDialog(context), // 退会ダイアログを表示
          },
          child: SettingItem(text: "退会"),
        ),
      ])),
    );
  }
}
