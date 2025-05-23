import 'dart:core';
import 'package:bouldering_app/view/components/favorite_tweets_section.dart';
import 'package:bouldering_app/view/components/general_tweets_section.dart';
import 'package:flutter/material.dart';
import 'package:bouldering_app/view/components/switcher_tab.dart';

/// ■ クラス
/// - View
/// - ボル活ページを表示する
class BoulLogPage extends StatelessWidget {
  const BoulLogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 2,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // タブバー
              SwitcherTab(leftTabName: "みんなのボル活", rightTabName: "お気に入り"),

              // タブの中身
              Expanded(
                child: TabBarView(
                  children: [
                    // (タブ1) みんなのボル活
                    GeneralTweetsSection(),

                    // (タブ2) お気に入りユーザーのツイート
                    FavoriteTweetsSection(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
