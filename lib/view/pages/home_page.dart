import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bouldering_app/view/components/app_logo.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                // ロゴ
                const AppLogo(),
                const SizedBox(height: 48),

                // ジム条件検索
                InkWell(
                  onTap: () {
                    context.push("/Home/SearchGim");
                  },
                  borderRadius: BorderRadius.circular(32),
                  splashColor: Colors.grey.withOpacity(0.3),
                  child: Container(
                    width: double.infinity,
                    height: 64,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                            width: 1, color: Color(0xFFD9D9D9)),
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.search, size: 32.0, color: Colors.blue),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '条件からジムを探す',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w600,
                                  height: 1.3,
                                ),
                              ),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'ボルダリング以外の種目も検索できます',
                                  style: TextStyle(
                                    color: Color(0xFFD9D9D9),
                                    fontSize: 14,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w600,
                                    height: 1.3,
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

                const SizedBox(height: 48),

                // 地図検索ウィジェット
                Container(
                  width: double.infinity,
                  height: 136,
                  decoration: ShapeDecoration(
                    image: const DecorationImage(
                      image: AssetImage("lib/view/assets/map_image.png"),
                      fit: BoxFit.cover,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Center(
                    child: InkWell(
                      onTap: () {
                        context.push('/Home/SearchGymOnMap');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: ShapeDecoration(
                          color: const Color(0xFF0056FF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          '地図からジムを探す',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 52),

                /// 写真提供URL実装
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF4D9), // 薄い黄色背景
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        '🙇‍♂️ 現在、ジム写真を募集中です！🙇‍♀️',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'ジムの写真を提供してくれる方は ぜひご協力ください！',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final Uri formUrl = Uri.parse(
                                'https://forms.gle/fshfxBP8Sd49mfBi6');
                            if (await canLaunchUrl(formUrl)) {
                              await launchUrl(formUrl,
                                  mode: LaunchMode.externalApplication);
                            } else {
                              debugPrint('GoogleフォームのURLを開けませんでした。');
                            }
                          },
                          icon: const Icon(Icons.send),
                          label: const Text('ジムの写真を送る'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF0056FF),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
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
      ),
    );
  }
}
