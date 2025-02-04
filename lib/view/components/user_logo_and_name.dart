import 'package:flutter/material.dart';

/// ■ クラス
/// - マイページで(他ユーザーも含む),アイコンとユーザー名を表示する
class UserLogoAndName extends StatelessWidget {
  // コンストラクタ
  const UserLogoAndName({super.key, required this.userName});
  // ユーザー名
  final String userName;

  @override
  Widget build(BuildContext context) {
    // ユーザー名が12文字を超える(13文字以上の)場合は、11文字目までと'...'を表示する
    final displayUserName =
        (userName.length > 12) ? '${userName.substring(0, 11)}…' : userName;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 画像URL
          Container(
            width: 72,
            height: 72,
            decoration: const ShapeDecoration(
              color: Color(0xFFEEEEEE),
              shape: OvalBorder(),
            ),
          ),
          const SizedBox(width: 8),

          // ユーザー名
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
}
