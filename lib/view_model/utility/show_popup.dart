import 'package:flutter/material.dart';

/// ■ メソッド
/// - ポップアップメッセージを表示する
///
/// 引数：
/// - [context] ウィジェットツリーの情報
/// - [title] タイトル・概要
/// - [message] メッセージ・内容
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
