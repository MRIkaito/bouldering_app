import 'package:flutter/material.dart';

class PrefectureButton extends StatelessWidget {
  final String prefectureName; // 引数として渡される文字列

  // コンストラクタで文字列を受け取る
  const PrefectureButton({
    Key? key,
    required this.prefectureName, // prefectureNameを必須引数として受け取る
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 104,
      height: 40,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: 104,
              height: 40,
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: BorderSide(width: 1, color: Color(0xFFD9D9D9)),
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
          Positioned(
            left: 8,
            top: 1,
            child: SizedBox(
              width: 88,
              height: 39,
              child: Text(
                prefectureName, // 引数として渡された都道府県名を表示
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w500,
                  height: 0.08,
                  letterSpacing: -0.50,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
