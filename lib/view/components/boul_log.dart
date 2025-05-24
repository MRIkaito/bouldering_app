import 'package:bouldering_app/view_model/facility_info_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bouldering_app/view_model/utility/user_icon_url.dart';

class BoulLog extends ConsumerWidget {
  final String userId;
  final String userName;
  final String? userIconUrl;
  final String visitedDate;
  final String gymId;
  final String gymName;
  final String prefecture;
  final String tweetContents;
  final List<String>? tweetImageUrls; // 画像がある場合のみ使用される

  const BoulLog({
    super.key,
    required this.userId,
    required this.userName,
    required this.userIconUrl,
    required this.visitedDate,
    required this.gymId,
    required this.gymName,
    required this.prefecture,
    required this.tweetContents,
    this.tweetImageUrls, // null許容にすることで未添付もOK
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ユーザーアイコン
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.grey[200],
                backgroundImage:
                    isValidUrl(userIconUrl) ? NetworkImage(userIconUrl!) : null,
                child: isValidUrl(userIconUrl)
                    ? null
                    : const Icon(Icons.person, color: Colors.grey, size: 24),
              ),
              const SizedBox(width: 12),

              // ユーザー名・日付
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        context.push('/OtherUserPage/$userId');
                      },
                      child: Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
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
                GestureDetector(
                  onTap: () async {
                    final gymInfoAsync =
                        await ref.read(facilityInfoProvider(gymId).future);

                    if (gymInfoAsync != null) {
                      context.push('/FacilityInfo/$gymId');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('施設情報の取得に失敗しました')),
                      );
                    }
                  },
                  child: RichText(
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
                          text: " [$prefecture]",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4),

                // 活動内容
                Text(
                  tweetContents,
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),

                // 画像 // TODO：画像を横スクロールできるような実装に変更する必要がある
                // 画像部分
                // GestureDetector(
                //   onTap: () {
                //     showGeneralDialog(
                //       context: context,
                //       barrierDismissible: true,
                //       barrierLabel: "TweetImageDialog",
                //       barrierColor: Colors.white.withOpacity(0.8),
                //       transitionDuration: const Duration(milliseconds: 300),
                //       pageBuilder: (context, _, __) {
                //         return Stack(
                //           children: [
                //             GestureDetector(
                //               onTap: () => Navigator.of(context).pop(),
                //               child: Container(color: Colors.transparent),
                //             ),
                //             Center(
                //               child: Hero(
                //                 tag:
                //                     'tweet_image_${userId}_$visitedDate', // 任意のユニークIDに
                //                 child: InteractiveViewer(
                //                   minScale: 1.0,
                //                   maxScale: 20.0,
                //                   child: Image.asset(
                //                     "lib/view/assets/map_image.png",
                //                     fit: BoxFit.contain,
                //                   ),
                //                   // ↑ ここは必要に応じて Image.network (下記のよう)に変更する
                //                   // child: Image.network(
                //                   //   tweetImageUrl, // ← 実際の画像URL  // TODO：値をもらう箇所
                //                   //   fit: BoxFit.contain,
                //                   // ),
                //                 ),
                //               ),
                //             ),
                //           ],
                //         );
                //       },
                //       transitionBuilder:
                //           (context, animation, secondaryAnimation, child) {
                //         return FadeTransition(
                //           opacity: animation,
                //           child: child,
                //         );
                //       },
                //     );
                //   },
                //   child: Hero(
                //     tag: 'tweet_image_${userId}_$visitedDate',
                //     child: Container(
                //       width: 359,
                //       height: 136,
                //       decoration: ShapeDecoration(
                //         image: const DecorationImage(
                //           image: AssetImage("lib/view/assets/map_image.png"),
                //           // ↑ ここを下記のように変更する
                //           // image: NetworkImage(tweetImageUrl),  // TODO：値をもらう箇所
                //           fit: BoxFit.fill,
                //         ),
                //         shape: RoundedRectangleBorder(
                //           borderRadius: BorderRadius.circular(16),
                //         ),
                //       ),
                //     ),
                //   ),
                // ),

                // 画像がある場合だけ表示（横スクロール）
                if (tweetImageUrls != null && tweetImageUrls!.isNotEmpty)
                  SizedBox(
                    height: 160,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: tweetImageUrls!.length,
                      itemBuilder: (context, index) {
                        final imageUrl = tweetImageUrls![index];
                        return GestureDetector(
                          onTap: () {
                            showGeneralDialog(
                              context: context,
                              barrierDismissible: true,
                              barrierLabel: "TweetImageDialog",
                              barrierColor: Colors.white.withOpacity(0.8),
                              transitionDuration:
                                  const Duration(milliseconds: 300),
                              pageBuilder: (context, _, __) {
                                return Stack(
                                  children: [
                                    GestureDetector(
                                      onTap: () => Navigator.of(context).pop(),
                                      child:
                                          Container(color: Colors.transparent),
                                    ),
                                    Center(
                                      child: Hero(
                                        tag:
                                            'tweet_image_${userId}_${visitedDate}_$index',
                                        child: InteractiveViewer(
                                          minScale: 1.0,
                                          maxScale: 20.0,
                                          child: Image.network(
                                            imageUrl,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                              transitionBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                return FadeTransition(
                                    opacity: animation, child: child);
                              },
                            );
                          },
                          child: Hero(
                            tag: 'tweet_image_${userId}_${visitedDate}_$index',
                            child: Container(
                              width: 200,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                image: DecorationImage(
                                  image: NetworkImage(imageUrl),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
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
