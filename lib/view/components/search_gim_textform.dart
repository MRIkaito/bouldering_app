import 'package:flutter/material.dart';

class SearchGimTextform extends StatelessWidget {
  const SearchGimTextform({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 288,
      height: 48,
      child: Stack(
        children: [
          // 背景の白いボックス
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: 288,
              height: 48,
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: BorderSide(width: 1, color: Color(0xFFB1B1B1)),
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
          // テキストフォームフィールド
          Positioned(
            left: 8.40,
            top: 0,
            child: SizedBox(
              width: 270,
              height: 48,
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: '施設名',
                  hintStyle: TextStyle(
                    color: Color(0xFFB1B1B1),
                    fontSize: 20,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.50,
                  ),
                  border: InputBorder.none, // 枠線を削除
                  contentPadding: EdgeInsets.only(top: 14), // プレースホルダーの位置調整
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
