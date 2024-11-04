import 'package:flutter/material.dart';

class GimCategory extends StatelessWidget {
  const GimCategory({
    Key? key,
    required this.gimCategory,
    required this.colorCode,
  }) : super(key: key);

  final String gimCategory;
  final int colorCode;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft, // Container全体を左寄せ
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4), // 高さを調整
        decoration: ShapeDecoration(
          color: Color(colorCode),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        // 以下のように幅を文字列の長さに応じて自動調整
        child: Text(
          gimCategory,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w600,
            height: 1.0, // 縦の中央にテキストを配置
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }
}
