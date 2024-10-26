// アイコン
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Align(
        alignment: Alignment.center, // 中央揃え
        child: SvgPicture.asset(
          'lib/view/assets/app_main_icon.svg',
        ),
      ),
      Center(
        child: SizedBox(
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
      ),
    ]);
  }
}
