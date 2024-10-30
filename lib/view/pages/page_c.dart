import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class PageC extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // ボトムシートを表示
            showModalBottomSheet(
              context: context,
              isScrollControlled: true, // モーダルを全画面に近いサイズにする
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (context) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom:
                        MediaQuery.of(context).viewInsets.bottom, // キーボードに対応
                  ),
                  child: PostModal(),
                );
              },
            );
          },
          child: Text('投稿ボタン'),
        ),
      ),
    );
  }
}

// 投稿用のモーダルウィジェット
class PostModal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      height: 400, // モーダルの高さを調整
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '投稿する',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              labelText: '内容を入力してください',
              border: OutlineInputBorder(),
            ),
            maxLines: 4,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // モーダルを閉じる
            },
            child: Text('投稿'),
          ),
        ],
      ),
    );
  }
}
