import 'package:flutter/material.dart';

class GymTile extends StatelessWidget {
  GymTile({super.key});

  // サンプルデータ的に4つ項目表示
  // 外部DBからジムを取得してきたものを，gymsに格納する．
  final List<Map<String, String>> gyms = [
    {'name': 'フォークボルダリングジム', 'location': '神奈川県横浜市'},
    {'name': 'ディーボルダリング綱島', 'location': '神奈川県横浜市'},
    {'name': 'スポーツスパ アスリエ大倉山', 'location': '神奈川県横浜市'},
    {'name': 'クライミングジム ビッグロック 日吉店', 'location': '神奈川県横浜市'},
  ];

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: gyms.length,
        itemBuilder: (context, index) {
          final gym = gyms[index];
          return ListTile(
            title: Text(gym['name']!),
            subtitle: Text(gym['location']!),
            onTap: () {
              // ジム選択時の処理（選択したジムを渡すなど）
              //Navigator.pop(context, gym['name']);
            },
          );
        },
      ),
    );
  }
}
