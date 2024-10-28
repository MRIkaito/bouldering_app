import 'package:auto_route/auto_route.dart';
import 'package:bouldering_app/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bouldering_app/view/pages/search_gim_page.dart';

@RoutePage()
class HomeRouterPage extends AutoRouter {
  const HomeRouterPage({super.key});
}

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        // 上から開始
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // 上から80ピクセルのスペースを作成
          const SizedBox(height: 80),

          // アプリアイコン
          Align(
            alignment: Alignment.center, // 中央揃え
            child: SvgPicture.asset(
              'lib/view/assets/app_main_icon.svg',
            ),
          ),

          // アプリ名テキスト
          SizedBox(
            width: 209,
            height: 25,
            child: Text(
              'イワノボリタイ',
              textAlign: TextAlign.center,
              style: GoogleFonts.rocknRollOne(
                color: Colors.black,
                fontSize: 28,
                fontWeight: FontWeight.w400,
                height: 0.8, // ここでは正しいline heightを指定
                letterSpacing: -0.50,
              ),
            ),
          ),

          // 余白:48px
          const SizedBox(height: 48),

          // 検索ボックス・・・アプリ名とのマージンが必要
          InkWell(
            onTap: () {
              // ページ遷移
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SearchGimPage()), // 遷移先のページ
              );

              // ページ遷移の際,レプレースするコード例
              // context.router.replace(const SearchGimRoute());
            },
            borderRadius: BorderRadius.circular(32), // タッチエフェクトの範囲をボーダーに合わせる
            splashColor: Colors.grey.withOpacity(0.3), // タップ時のエフェクトカラー

            child: Container(
              width: 360,
              height: 64,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                      width: 360,
                      height: 64,
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(width: 1, color: Color(0xFFD9D9D9)),
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                    ),
                  ),
                  const Positioned(
                    left: 64,
                    top: 40,
                    child: Text(
                      'ボルダリング以外の種目も検索できます',
                      style: TextStyle(
                        color: Color(0xFFD9D9D9),
                        fontSize: 14,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w600,
                        height: 0.11,
                        letterSpacing: -0.50,
                      ),
                    ),
                  ),
                  const Positioned(
                    left: 64,
                    top: 18,
                    child: Text(
                      '条件からジムを探す',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w600,
                        height: 0.06,
                        letterSpacing: -0.50,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    top: 12,
                    child: Container(
                      width: 40,
                      height: 40,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(),
                      child: FlutterLogo(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 余白:48px
          SizedBox(height: 48),

          // 地図検索ウィジェット
          Container(
            width: 359,
            height: 136,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  child: Container(
                    width: 359,
                    height: 136,
                    decoration: ShapeDecoration(
                      image: const DecorationImage(
                        image: AssetImage("lib/view/assets/map_image.png"),
                        fit: BoxFit.fill,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 91.10,
                  top: 55.59,
                  child: Container(
                    width: 176,
                    height: 32,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          top: 0,
                          child: Container(
                            width: 176,
                            height: 32,
                            decoration: ShapeDecoration(
                              color: Color(0xFF0056FF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                        const Positioned(
                          left: 8.90,
                          top: 8.41,
                          child: SizedBox(
                            width: 159,
                            height: 13,
                            child: Text(
                              '地図からジムを探す',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w600,
                                height: 0.6,
                                letterSpacing: -0.50,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
          // 次のウィジェット開始位置
        ],
      ),
    );
  }
}
