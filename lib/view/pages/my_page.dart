import 'package:auto_route/auto_route.dart';
import 'package:bouldering_app/view/pages/login_page.dart';
import 'package:flutter/material.dart';

@RoutePage()
class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // 左揃え
            children: [
              // 「ゲストボルダー」部分
              Container(
                width: 375,
                height: 72,
                padding: const EdgeInsets.only(left: 6, right: 114),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: ShapeDecoration(
                        color: Color(0xFFEEEEEE),
                        shape: OvalBorder(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "ゲストボルダー",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                        letterSpacing: -0.50,
                      ),
                    ),
                  ],
                ),
              ),

              // 24ピクセルのスペースを設ける
              const SizedBox(height: 24),

              // === 背景色を追加した部分 ===
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFFEEEEEE).withOpacity(0.2), // 赤色の背景色（半透明）
                  borderRadius: BorderRadius.circular(16), // 角を丸くする
                  // boxShadow: [
                  //   BoxShadow(blurRadius: 10, color: Colors.black12)
                  // ], // シャドウを追加
                ),
                padding: EdgeInsets.all(16), // 内側にパディングを追加
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // 左揃えに修正
                  children: [
                    // Flutterロゴを中央揃えに
                    Center(
                      child: Container(
                        width: 72,
                        height: 72,
                        child: FlutterLogo(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 「イワノボリタイに登録しよう」のタイトル（2行に分ける）
                    Center(
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
                    Text(
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
                    _buildSectionText('ジムで登った記録を切ろきゃ感想に残すことができます．'),

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
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      },
                      borderRadius: BorderRadius.circular(10), // 角丸をボタンに適用
                      child: Container(
                        width: double.infinity,
                        height: 49,
                        decoration: ShapeDecoration(
                          color: Color(0xFF0056FF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Center(
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
      style: TextStyle(
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
      style: TextStyle(
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
