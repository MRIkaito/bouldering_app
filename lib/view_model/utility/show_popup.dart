import 'package:flutter/material.dart';

/* ============================================
 * ・関数
 * showPopup
 *
 * ・引数
 * BuildContext context：ウィジェットツリー情報
 * String title：タイトル・標題
 * String message：メッセージ・内容
 *
 * ・説明
 * ポップアップメッセージを表示する
 *
 * ・補足
 *
 * ============================================ */
void showPopup(BuildContext context, String title, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}
