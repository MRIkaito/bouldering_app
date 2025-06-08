import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ■ クラス
/// - 編集画面で写真をプレビュー表示するためのクラス
class ConfirmProfileImagePage extends ConsumerWidget {
  final File imageFile;

  const ConfirmProfileImagePage({Key? key, required this.imageFile})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("プロフィール"),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context, imageFile);
            },
            child: const Text("保存", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
      body: Center(
        child: ClipOval(
          child: Image.file(
            imageFile,
            width: 200,
            height: 200,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
