import 'package:flutter/material.dart';

class UserLogoAndName extends StatelessWidget {
  const UserLogoAndName({super.key, required this.userName});
  final String userName;

  @override
  Widget build(BuildContext context) {
    // ユーザー名が12文字を超える場合はカットする
    final displayUserName =
        userName.length > 12 ? userName.substring(0, 12) : userName;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0), // 両端にパディングを追加
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const ShapeDecoration(
              color: Color(0xFFEEEEEE),
              shape: OvalBorder(),
            ),
          ),
          const SizedBox(width: 8),
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
