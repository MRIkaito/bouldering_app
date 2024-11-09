import 'package:flutter/material.dart';

class FavoriteUserPage extends StatelessWidget {
  const FavoriteUserPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'お気に入り',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView.builder(
        itemCount: 3, // 表示したいお気に入りの数に応じて変更
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemBuilder: (context, index) {
          return FavoriteItem(
            name: _favoriteNames[index],
            description: _favoriteDescriptions[index],
            imageUrl: _favoriteImages[index],
          );
        },
      ),
    );
  }
}

// ダミーデータ
const _favoriteNames = ["あっちゃんさん", "ぽんたろー", "たしかに"];
const _favoriteDescriptions = ["月見湯", "虹の湯", "綱島源泉 湯けむりの庄"];
const _favoriteImages = [
  "https://via.placeholder.com/50", // ダミー画像URL
  "https://via.placeholder.com/50",
  "https://via.placeholder.com/50"
];

// お気に入り項目のウィジェット
class FavoriteItem extends StatelessWidget {
  final String name;
  final String description;
  final String imageUrl;

  const FavoriteItem({
    Key? key,
    required this.name,
    required this.description,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        children: [
          // ユーザー画像
          CircleAvatar(
            backgroundImage: NetworkImage(imageUrl),
            radius: 24,
          ),
          const SizedBox(width: 12),

          // 名前と説明
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // お気に入りを解除ボタン
          OutlinedButton(
            onPressed: () {
              // お気に入り解除の処理
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.blue),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: const Text(
              'お気に入りを解除',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }
}
