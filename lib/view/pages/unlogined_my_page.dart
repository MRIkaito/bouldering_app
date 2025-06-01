import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bouldering_app/view/components/app_logo.dart';
import 'package:bouldering_app/view/components/user_logo_and_name.dart';

class UnloginedMyPage extends StatelessWidget {
  const UnloginedMyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ユーザーのロゴ・ユーザ名部分
              const UserLogoAndName(
                userName: 'ゲストボルダー',
                heroTag: 'guest_user_icon',
              ),

              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFEEEEEE).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(child: AppLogo()),
                    const SizedBox(height: 16),

                    // 説明テキスト
                    const Text(
                      'イワノボリタイに登録すると，ボル活がさらに充実します！登録は無料！',
                      textAlign: TextAlign.left,
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

                    // 各項目のリスト
                    _buildSectionTitle('1. 行きたいジムを保存'),
                    const SizedBox(height: 4),
                    _buildSectionText('気になるジムをお気に入り登録して，行きたいジムリストを作ることができます．'),
                    const SizedBox(height: 20),
                    _buildSectionTitle('2. ボル活を記録'),
                    const SizedBox(height: 4),
                    _buildSectionText('ジムで登った記録や感想を残すことができます．'),
                    const SizedBox(height: 20),
                    _buildSectionTitle('3. コンペ（今後追加予定）'),
                    const SizedBox(height: 4),
                    _buildSectionText(
                        'ジムのコンペやイベント，セッションの情報を確認できます．気になるジムをのぞいてみよう！'),
                    const SizedBox(height: 40),

                    // 画面遷移ボタン
                    InkWell(
                      onTap: () {
                        // context.push("/Unlogined/LoginOrSignUp");
                        context.push("/LoginOrSignUp");
                      },
                      borderRadius: BorderRadius.circular(10),
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
                            '新規登録 / ログイン',
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
      textAlign: TextAlign.left,
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
      textAlign: TextAlign.left,
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
