import 'package:flutter/material.dart';

class BoulLog extends StatelessWidget {
  final String userName;
  //final String userRole;
  final String date;
  final String gymName;
  final String gymLocation;
  final String activity;
  // final String userIconUrl;
  // final String imageUrl;

  const BoulLog({
    super.key,
    /* 本来はすべて必要・・・本番では下記のrequiredをつける */
    // required this.userName,
    // required this.userRole,
    // required this.date,
    // required this.gymName,
    // required this.gymLocation,
    // required this.activity,
    // required this.userIconUrl,
    // required this.imageUrl,

    // デモ用：userIconUrl, imageUrlは，設定する必要あり．今はただの◯とか写真をベタ書きで設定
    this.userName = 'ムラーん',
    // this.userRole,
    this.date = '2024.09.23',
    this.gymName = 'Folkボルダリングジム',
    this.gymLocation = '[神奈川県]',
    this.activity = 'いまセッションやってます！',
    // this.userIconUrl,
    // this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 丸いアイコン部分
              const CircleAvatar(
                radius: 24,
                // backgroundImage: NetworkImage(userIconUrl),    // 本番はDBから取得したアイコンを表示
                backgroundImage:
                    AssetImage("lib/view/assets/test_user_icon.png"),
              ),
              const SizedBox(width: 12),
              // ユーザー名と日付
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 56.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ジム名と場所
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: gymName,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text: " [$gymLocation]",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                // 活動内容
                Text(
                  activity,
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                // 活動の画像
                // 下記，本番用
                // Image.network(
                //   imageUrl,
                //   height: 150,
                //   width: double.infinity,
                //   fit: BoxFit.cover,
                // ),
                // 下記，ここからデモ用
                Container(
                  width: 359,
                  height: 136,
                  decoration: ShapeDecoration(
                    image: const DecorationImage(
                      image: AssetImage("lib/view/assets/map_image.png"),
                      fit: BoxFit.fill,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                // ここまでデモ用
              ],
            ),
          ),
          // 下線
          const SizedBox(height: 8),
          // 下線部分
          Container(
            width: MediaQuery.of(context).size.width - 16,
            height: 1,
            color: Color(0xFFB1B1B1),
          ),
        ],
      ),
    );
  }
}
