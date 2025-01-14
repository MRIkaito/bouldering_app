import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bouldering_app/view/pages/search_gim_page.dart';

// HTTPリクエスト テスト
import 'package:http/http.dart' as http;
import 'dart:convert';

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

          const SizedBox(height: 48),

          // ジム条件検索
          InkWell(
            onTap: () {
              // ページ遷移
              context.push("/Home/SearchGim");

              // テスト：データ取得
              // fetchData(9);
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
                      width: 44,
                      height: 44,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(),
                      // child: FlutterLogo(),
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
                  child: InkWell(
                    onTap: () {
                      print("タップしたよ");
                      // ページ遷移：実装したら以下コメントアウト削除
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

// テスト作成
Future<void> fetchData(int gymId) async {
  gymId = gymId + 1;
  final url = Uri.parse(
          'https://us-central1-gcp-compute-engine-441303.cloudfunctions.net/getData')
      .replace(queryParameters: {'gym_id': gymId.toString()});

  try {
    // HTTP GETリクエスト
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // レスポンスボディをJSONとしてデコード
      final List<dynamic> data = jsonDecode(response.body);
      print("$data");

      // 指定されたgym_idのデータを検索
      final gym = data.firstWhere((gym) => gym['gym_id'] == gymId,
          orElse: () => null // 見つからない場合はnullを返す
          );

      print(gym);

      if (gym != null) {
        // is_bouldering_gym の値を取得
        final isBouldering = gym['is_lead_gym'];
        print('gym_id: $gymId のis_lead_gym: $isBouldering');
      } else {
        print('gym_id: $gymId のデータがみつかりませんでした');
      }
    } else {
      print("エラー：${response.statusCode}");
    }
  } catch (e) {
    print("リクエスト中にErrorが発生しました: $e");
  }
}
