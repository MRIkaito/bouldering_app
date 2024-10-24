import 'package:auto_route/auto_route.dart';
import 'package:bouldering_app/view/components/setting_item.dart';
import 'package:flutter/material.dart';

// 遷移先のページ
@RoutePage()
class SettingPage extends StatelessWidget {
  const SettingPage({Key? key}): super(key: key);

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(children: [
          InkWell(
            onTap: () => {
              // ページ遷移する処理を実装
            },
            child: SettingItem(text: "プロフィール変種"),
          ),
          SettingItem(text: "メールアドレス"),
          SettingItem(text: "ログアウト"),
          SettingItem(text: "退会"),
        ])
      ),
    );
  }
}