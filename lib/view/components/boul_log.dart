import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bouldering_app/view_model/facility_info_provider.dart';
import 'package:bouldering_app/view_model/user_provider.dart';
import 'package:bouldering_app/view_model/utility/user_icon_url.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  final int? tweetId;

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
    this.tweetId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myUserId = ref.watch(userProvider)?.userId;

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

              // ツイートのユーザーIDが，ログインしているユーザーのユーザーIDと同じ場合「⋮」を表示する
              // 編集・削除 機能
              if (userId == myUserId)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) async {
                    if (value == 'delete') {
                      final shouldDelete = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("削除しますか？"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text("いいえ"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text("はい"),
                            ),
                          ],
                        ),
                      );
                      if (shouldDelete == true && tweetId != null) {
                        final uri = Uri.parse(
                          'https://us-central1-gcp-compute-engine-441303.cloudfunctions.net/getData',
                        ).replace(queryParameters: {
                          'request_id': '28',
                          'tweet_id': tweetId.toString(),
                          'user_id': userId,
                          'gym_id': gymId,
                        });

                        final response = await http.delete(uri);
                        if (response.statusCode == 200) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('削除しました')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('削除に失敗しました: ${response.body}')),
                          );
                        }
                      }
                    } else if (value == 'edit' && tweetId != null) {
                      // context.push('/EditTweetPage/$tweetId');
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'delete', child: Text('削除する')),
                    const PopupMenuItem(value: 'edit', child: Text('編集する')),
                  ],
                ),
//
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
                                return PageView.builder(
                                  controller:
                                      PageController(initialPage: index),
                                  itemCount: tweetImageUrls!.length,
                                  itemBuilder: (context, pageIndex) {
                                    return GestureDetector(
                                      onTap: () => Navigator.of(context).pop(),
                                      child: Container(
                                        color: Colors.transparent,
                                        child: Center(
                                          child: Hero(
                                            tag:
                                                'tweet_image_${userId}_${visitedDate}_$pageIndex',
                                            child: InteractiveViewer(
                                              minScale: 1.0,
                                              maxScale: 5.0,
                                              child: Image.network(
                                                tweetImageUrls![pageIndex],
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              transitionBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
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
