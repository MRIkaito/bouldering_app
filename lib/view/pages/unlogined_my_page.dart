import 'package:auto_route/auto_route.dart';
import 'package:bouldering_app/view/components/user_logo_and_name.dart';
import 'package:bouldering_app/view/pages/login_or_signup_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

@RoutePage()
class UnloginedMyPage extends StatelessWidget {
  const UnloginedMyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // 左揃え
            children: [
              // ユーザーのロゴ・ユーザ名部分
              const UserLogoAndName(userName: 'ゲストボルダー'),

              // 24ピクセルのスペースを設ける
              const SizedBox(height: 24),

              // === 背景色を追加した部分 ===
              Container(
                decoration: BoxDecoration(
                  color:
                      const Color(0xFFEEEEEE).withOpacity(0.2), // 赤色の背景色（半透明）
                  borderRadius: BorderRadius.circular(16), // 角を丸くする
                ),
                padding: const EdgeInsets.all(16), // 内側にパディングを追加
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // 左揃えに修正
                  children: [
                    // イワノボリタイロゴを中央揃えに
                    Center(
                      child: SizedBox(
                        width: 72,
                        height: 72,
                        child: SvgPicture.asset(
                          'lib/view/assets/app_main_icon.svg',
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 「イワノボリタイに登録しよう」のタイトル（2行に分ける）
                    const Center(
                      child: Text(
                        'イワノボリタイに\n登録しよう',
                        textAlign: TextAlign.center, // 真ん中揃え
                        style: TextStyle(
                          color: Color(0xFF0056FF),
                          fontSize: 32,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                          letterSpacing: -0.50,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 説明テキスト
                    const Text(
                      'イワノボリタイに登録すると，ボル活がさらに充実します！登録は無料！',
                      textAlign: TextAlign.left, // 左揃え
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                        letterSpacing: -0.50,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // 各項目のリスト（左揃えに修正）
                    _buildSectionTitle('1. 行きたいジムを保存'),
                    const SizedBox(height: 8),
                    _buildSectionText('気になるジムをお気に入り登録して，行きたいジムリストを作ることができます．'),

                    const SizedBox(height: 24),

                    _buildSectionTitle('2. 行きたいジムを保存'),
                    const SizedBox(height: 8),
                    _buildSectionText('ジムで登った記録や感想を残すことができます．'),

                    const SizedBox(height: 24),

                    _buildSectionTitle('3. コンペ'),
                    const SizedBox(height: 8),
                    _buildSectionText(
                        'ジムのコンペやイベント，セッションの情報を確認できます．気になるジムをのぞいてみよう！'),

                    const SizedBox(height: 48),

                    // ボタン
                    // ボタン（InkWellを追加して押下時に画面遷移する）
                    InkWell(
                      onTap: () {
                        // Navigatorで画面遷移を行う
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginOrSignUpPage()),
                        );
                      },
                      borderRadius: BorderRadius.circular(10), // 角丸をボタンに適用
                      child: Container(
                        width: double.infinity,
                        height: 49,
                        decoration: ShapeDecoration(
                          color: const Color(0xFF0056FF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            '新規登録（無料）またはログイン',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                              letterSpacing: -0.50,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // === 背景色を追加した部分ここまで ===
            ],
          ),
        ),
      ),
    );
  }

  // タイトルテキストウィジェット
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      textAlign: TextAlign.left, // 左揃え
      style: const TextStyle(
        color: Color(0xFF0056FF),
        fontSize: 16,
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w600,
        height: 1.4,
        letterSpacing: -0.50,
      ),
    );
  }

  // 説明テキストウィジェット
  Widget _buildSectionText(String text) {
    return Text(
      text,
      textAlign: TextAlign.left, // 左揃え
      style: const TextStyle(
        color: Colors.black,
        fontSize: 16,
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w500,
        height: 1.4,
        letterSpacing: -0.50,
      ),
    );
  }
}
