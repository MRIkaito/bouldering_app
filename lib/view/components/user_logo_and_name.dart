import 'package:flutter/material.dart';

/// ■ クラス
/// - マイページで(他ユーザーも含む),アイコンとユーザー名を表示する
class UserLogoAndName extends StatelessWidget {
  // プロパティ
  final String userName;
  final String? userLogo;

  // コンストラクタ
  const UserLogoAndName({
    super.key,
    required this.userName,
    this.userLogo,
  });

  /// ■ メソッド
  /// - URLが有効な形式かを確認する
  bool _isValidUrl(String? url) {
    if (url == null) return false;
    return url.startsWith('http://') || url.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    // ユーザー名が長すぎる場合、...でカット
    final displayUserName =
        (userName.length > 12) ? '${userName.substring(0, 11)}…' : userName;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 画像
          ClipOval(
            child: (_isValidUrl(userLogo))
                ? Image.network(
                    userLogo!,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return _buildPlaceholderIcon();
                    },
                    errorBuilder: (context, error, stackTrace) {
                      debugPrint(
                          "❌ [UserLogoAndName] Image load failed. URL: $userLogo");
                      return _buildPlaceholderIcon();
                    },
                  )
                : _buildPlaceholderIcon(),
          ),
          const SizedBox(width: 8),

          // 名前
          Text(
            displayUserName,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w500,
              height: 1.2,
              letterSpacing: -0.50,
            ),
          ),
        ],
      ),
    );
  }

  /// デフォルト画像アイコン
  Widget _buildPlaceholderIcon() {
    return Container(
      width: 72,
      height: 72,
      decoration: const BoxDecoration(
        color: Color(0xFFEEEEEE),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.person,
        color: Colors.grey,
        size: 40,
      ),
    );
  }
}
