import 'package:bouldering_app/view/components/button.dart';
import 'package:bouldering_app/view/components/this_month_boul_log.dart';
import 'package:bouldering_app/view/components/user_logo_and_name.dart';
import 'package:flutter/material.dart';

class LoginedMyPage extends StatelessWidget {
  const LoginedMyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ユーザ欄
              UserLogoAndName(userName: 'ログインユーザ名'), // 取得したユーザ名を表示
              const SizedBox(height: 16),

              // ボル活
              ThisMonthBoulLog(), // 各ユーザのボル活を下に計算して表示
              const SizedBox(height: 8),

              // お気に入り・お気に入られ
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Button(
                    buttonName: "お気に入り",
                    buttonWidth: 196,
                    buttonHeight: 36,
                    buttonTextColorCode: 0xFF000000,
                  ),
                  Button(
                    buttonName: "お気に入られ",
                    buttonWidth: 196,
                    buttonHeight: 36,
                    buttonTextColorCode: 0xFF000000,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // 自己紹介文
              // Containerを使用して幅制約を設ける
              Container(
                width: double.infinity,
                child: const Text(
                  // 各ユーザーの紹介文を取得して表示
                  "今はまだ5級しか登れませんが，将来は1級を登れるようになることが目標です！！よろしくお願いします！",
                  textAlign: TextAlign.left,
                  softWrap: true,
                  overflow: TextOverflow.visible,
                  maxLines: null,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                    letterSpacing: -0.50,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 好きなジム欄
              const Text(
                "好きなジム",
                style: TextStyle(
                  color: Color(0xFF8D8D8D),
                  fontSize: 16,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.bold,
                  height: 1.4,
                  letterSpacing: -0.50,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                child: const Text(
                  // 各ユーザーの好きなジムをそのまま表示する
                  """
・Folkボルダリングジム
・Dボルダリング綱島
                  """,
                  textAlign: TextAlign.left,
                  softWrap: true,
                  overflow: TextOverflow.visible,
                  maxLines: null,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                    letterSpacing: -0.50,
                  ),
                ),
              ),

              // ボル活歴
              Row(),

              // ホームジム
              Row(),
            ],
          ),
        ),
      ),
    );
  }
}
