import 'package:flutter/material.dart';

class GimCategory extends StatelessWidget {
  const GimCategory({
    Key? key,
    required this.gimCategory,
    required this.colorCode,
    this.isSelected,
    this.isTappable = false,
    this.onTap,
  }) : super(key: key);

  final String gimCategory;
  final int colorCode;
  final bool? isSelected;
  final bool isTappable;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool showSelected = isSelected != null;
    final Color bgColor = showSelected
        ? (isSelected! ? Color(colorCode) : Colors.grey.shade300)
        : Color(colorCode);
    final Color textColor = showSelected
        ? (isSelected! ? Colors.white : Colors.black)
        : Colors.white;

    final categoryWidget = Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: ShapeDecoration(
          color: bgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        // 幅を文字列の長さに応じて自動調整
        child: Text(
          gimCategory,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w600,
            height: 1.0, // 縦の中央にテキストを配置
            letterSpacing: -0.5,
          ),
        ),
      ),
    );

    return isTappable
        ? GestureDetector(
            onTap: onTap,
            child: categoryWidget,
          )
        : categoryWidget;
  }
}
