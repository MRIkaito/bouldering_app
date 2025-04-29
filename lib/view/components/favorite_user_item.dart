// お気に入り項目のウィジェット
import 'package:flutter/material.dart';

class FavoriteUserItem extends StatelessWidget {
  final String name;
  final String description;
  final String imageUrl;
  final VoidCallback? onTap;

  const FavoriteUserItem({
    Key? key,
    required this.name,
    required this.description,
    required this.imageUrl,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
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
                // TODO：お気に入り解除の処理を実装する
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
      ),
    );
  }
}
