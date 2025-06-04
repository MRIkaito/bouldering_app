// お気に入り項目のウィジェット
import 'package:bouldering_app/view_model/utility/is_valid_url.dart';
import 'package:flutter/material.dart';

class FavoriteUserItem extends StatelessWidget {
  final String name;
  final String description;
  final String imageUrl;
  final String userId;
  final bool isFavorited;
  final VoidCallback onToggleFavorite;
  final VoidCallback? onTap;

  const FavoriteUserItem({
    Key? key,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.userId,
    required this.isFavorited,
    required this.onToggleFavorite,
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
            Hero(
              tag: 'user_icon_$userId',
              child: ClipOval(
                child: isValidUrl(imageUrl)
                    ? Image.network(
                        imageUrl,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildFallback();
                        },
                      )
                    : _buildFallback(),
              ),
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

            // お気に入りを解除 or 登録ボタン
            OutlinedButton(
              onPressed: onToggleFavorite,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.blue),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: Text(
                isFavorited ? 'お気に入りを解除' : 'お気に入り登録',
                style: const TextStyle(color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// fallback placeholder
Widget _buildFallback() {
  return Container(
    width: 48,
    height: 48,
    decoration: const BoxDecoration(
      shape: BoxShape.circle,
      color: Color(0xFFE0E0E0),
    ),
    child: const Icon(Icons.person, size: 28, color: Colors.grey),
  );
}
