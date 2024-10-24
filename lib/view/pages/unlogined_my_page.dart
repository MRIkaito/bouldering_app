import 'package:bouldering_app/main.dart';
import 'package:flutter/material.dart';

class UnloginedMyPage extends StatelessWidget {
  const UnloginedMyPage({Key? key}): super(key: key);

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text("マイページ")
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 指定されたContainer をぺーjの一番上に配置
            Container(
              width: 375,
              height: 72,
              padding: const EdgeInsets.only(left: 6, right: 114),
              child: Row(
                mainAxisSize: MainAxisSize.min,
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
                      height: 0.03,
                      letterSpacing: -0.50,
                    ),
                  ),
                ]
              ),
            ),
            
            // 24ピクセルのスペースを設ける     
            const SizedBox(height: 24),

            // 新しいウィジェットを追加
            Container(
              width: 300,
              decoration: ShapeDecoration(
                color: Color(0xCCF4F4F4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      child: FlutterLogo(),
                    ),
                    Text(
                      'イワノボリタイに\n登録しよう',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF0056FF),
                        fontSize: 32,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w700,
                        height: 0.03,
                        letterSpacing: -0.50,
                      ),
                    ),
                    const SizedBox(height:16),
                    Container(
                      width: 344,
                      height: 49,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            top: 0,
                            child: Container(
                              width: 344,
                              height: 49,
                              decoration: ShapeDecoration(
                                color: Color(0xFF0056FF),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 55,
                            top: 16,
                            child: Text(
                              '新規登録(無料)またはログイン',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w400,
                                height: 0.00,
                                letterSpacing: -0.50,
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
          ],
        ),
      ),
    );
  }
}