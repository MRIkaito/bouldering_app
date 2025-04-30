import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 80),

          // アプリアイコン
          Align(
            alignment: Alignment.center,
            child: SvgPicture.asset(
              'lib/view/assets/app_main_icon.svg',
            ),
          ),

          // アプリ名テキスト : test実行する
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
                height: 0.8,
                letterSpacing: -0.50,
              ),
            ),
          ),
          const SizedBox(height: 48),

          // ジム条件検索
          InkWell(
            onTap: () {
              // ページ遷移
              context.push("/Home/SearchGim");
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
                          side: const BorderSide(
                              width: 1, color: Color(0xFFD9D9D9)),
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
                      width: 44,
                      height: 44,
                      clipBehavior: Clip.antiAlias,
                      decoration: const BoxDecoration(),
                      child: const Icon(
                        Icons.search,
                        size: 40.0,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 48),

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
                  child: InkWell(
                    onTap: () {
                      print("タップしたよ");
                      // TODO：ページ遷移 実装
                      // context.push("/home/searchGimOnMap");
                    },
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
                                color: const Color(0xFF0056FF),
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
                              width: 160,
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
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
