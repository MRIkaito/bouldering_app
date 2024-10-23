import 'package:flutter/material.dart';

class ClearButton extends StatelessWidget {
  const ClearButton({Key? key, required this.onPressed}) : super(key: key);

  // ボタンが押されたときの処理を外部から受け取る
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 48,
      padding: const EdgeInsets.only(top: 14, left: 8, right: 9, bottom: 14),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(),
      child: TextButton(
        onPressed: onPressed,  // ボタンが押されたときの処理
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,  // 不要な余白を削除
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'クリア',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w500,
                height: 0.08,
                letterSpacing: -0.50,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
