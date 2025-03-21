// import 'package:flutter/material.dart';

// class BoulLog extends StatelessWidget {
//   final String userName;
//   final String date;
//   final String gymName;
//   final String prefecture;
//   final String activity;

//   const BoulLog({
//     super.key,
//     this.userName = 'ムラーン',
//     this.date = '2024.09.23',
//     this.gymName = 'Folkボルダリングジム',
//     this.prefecture = '神奈川県',
//     this.activity = 'いまセッションやってます！',
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // 丸いアイコン部分
//               const CircleAvatar(
//                 radius: 24,
//                 backgroundImage:
//                     AssetImage("lib/view/assets/test_user_icon.png"),
//               ),
//               const SizedBox(width: 12),
//               // ユーザー名と日付
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       userName,
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     Text(
//                       date,
//                       style: const TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           Padding(
//             padding: const EdgeInsets.only(left: 56.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // ジム名と場所
//                 RichText(
//                   text: TextSpan(
//                     children: [
//                       TextSpan(
//                         text: gymName,
//                         style: const TextStyle(
//                           fontSize: 16,
//                           color: Colors.blue,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       TextSpan(
//                         text: " [$prefecture]",
//                         style: const TextStyle(
//                           fontSize: 14,
//                           color: Colors.grey,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 // 活動内容
//                 Text(
//                   activity,
//                   style: const TextStyle(
//                     fontSize: 14,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 // 活動の画像
//                 Container(
//                   width: 359,
//                   height: 136,
//                   decoration: ShapeDecoration(
//                     image: const DecorationImage(
//                       image: AssetImage("lib/view/assets/map_image.png"),
//                       fit: BoxFit.fill,
//                     ),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           // 下線
//           const SizedBox(height: 8),
//           Container(
//             width: MediaQuery.of(context).size.width - 16,
//             height: 1,
//             color: const Color(0xFFB1B1B1),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class BoulLog extends StatelessWidget {
  final String userName;
  final String visitedDate;
  final String gymName;
  final String prefecture;
  final String tweetContents;

  const BoulLog({
    super.key,
    required this.userName,
    required this.visitedDate,
    required this.gymName,
    required this.prefecture,
    required this.tweetContents,
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
              // ユーザーアイコン
              const CircleAvatar(
                radius: 24,
                backgroundImage: AssetImage(
                    "lib/view/assets/test_user_icon.png"), // TODO：値をもらう箇所 + ユーザークラスでユーザーアイコンを設定する必要がある
              ),
              const SizedBox(width: 12),

              // ユーザー名・日付
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
                      visitedDate,
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
                // ジム名・場所
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: gymName, // TODO：値をもらう箇所
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text: " [$prefecture]", // TODO：値をもらう箇所
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
                  tweetContents, // TODO：値をもらう箇所
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),

                // 画像 // TODO：画像を横スクロールできるような実装に変更する必要がある
                Container(
                  width: 359,
                  height: 136,
                  decoration: ShapeDecoration(
                    image: const DecorationImage(
                      image: AssetImage(
                          "lib/view/assets/map_image.png"), // TODO：値をもらう箇所
                      fit: BoxFit.fill,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // 下線
          Container(
            width: MediaQuery.of(context).size.width - 16,
            height: 1,
            color: const Color(0xFFB1B1B1),
          ),
        ],
      ),
    );
  }
}
