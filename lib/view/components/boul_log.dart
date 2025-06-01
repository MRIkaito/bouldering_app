import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bouldering_app/view_model/facility_info_provider.dart';
import 'package:bouldering_app/view_model/user_provider.dart';
import 'package:bouldering_app/view_model/utility/user_icon_url.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

class BoulLog extends ConsumerStatefulWidget {
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
  ConsumerState<BoulLog> createState() => _BoulLogState();
}

class _BoulLogState extends ConsumerState<BoulLog> {
  late List<String> _imageUrls;

  @override
  void initState() {
    super.initState();
    _imageUrls = widget.tweetImageUrls ?? [];
  }

  @override
  void didUpdateWidget(covariant BoulLog oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 新しく画像が渡された場合のみ更新（古い空リストで上書きしない）
    if ((widget.tweetImageUrls != null && widget.tweetImageUrls!.isNotEmpty)) {
      _imageUrls = widget.tweetImageUrls!;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                backgroundImage: isValidUrl(widget.userIconUrl)
                    ? NetworkImage(widget.userIconUrl!)
                    : null,
                child: isValidUrl(widget.userIconUrl)
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
                        context.push('/OtherUserPage/${widget.userId}');
                      },
                      child: Text(
                        widget.userName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      widget.visitedDate,
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
              if (widget.userId == myUserId)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) async {
                    if (value == 'delete') {
                      final shouldDelete = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          titlePadding: const EdgeInsets.only(
                              top: 24, left: 24, right: 24, bottom: 0),
                          contentPadding:
                              const EdgeInsets.fromLTRB(24, 8, 24, 0),
                          title: const Center(
                            child: Text(
                              "削除しますか？",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          content: const Text(
                            "一度削除すると戻すことはできません．本当にこのボル活を削除しますか？\n",
                            style: TextStyle(fontSize: 14, color: Colors.black),
                            textAlign: TextAlign.center,
                          ),
                          actionsAlignment: MainAxisAlignment.spaceBetween,
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text(
                                "キャンセル",
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text(
                                "削除",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                      if (shouldDelete == true && widget.tweetId != null) {
                        final uri = Uri.parse(
                          'https://us-central1-gcp-compute-engine-441303.cloudfunctions.net/getData',
                        ).replace(queryParameters: {
                          'request_id': '28',
                          'tweet_id': widget.tweetId.toString(),
                          'user_id': widget.userId,
                          'gym_id': widget.gymId,
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
                    } else if (value == 'edit' && widget.tweetId != null) {
                      context.push(
                        '/ActivityPostEdit',
                        extra: {
                          'tweetId': widget.tweetId,
                          'tweetContents': widget.tweetContents,
                          'gymId': widget.gymId,
                          'gymName': widget.gymName,
                          'visitedDate': widget.visitedDate,
                          'mediaUrls': widget.tweetImageUrls,
                        },
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text(
                        '編集する',
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        '削除する',
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
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
                    final gymInfoAsync = await ref
                        .read(facilityInfoProvider(widget.gymId).future);

                    if (gymInfoAsync != null) {
                      context.push('/FacilityInfo/${widget.gymId}');
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
                          text: widget.gymName,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(
                          text: ' [${widget.prefecture}]',
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
                  widget.tweetContents,
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),

                // 画像がある場合だけ表示（横スクロール）
                if (_imageUrls.isNotEmpty)
                  SizedBox(
                    height: 160,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _imageUrls.length,
                      itemBuilder: (context, index) {
                        final imageUrl = _imageUrls[index];
                        return Padding(
                          padding: EdgeInsets.only(
                              right:
                                  index != _imageUrls.length - 1 ? 8.0 : 0.0),
                          child: GestureDetector(
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
                                    itemCount: _imageUrls.length,
                                    itemBuilder: (context, pageIndex) {
                                      return GestureDetector(
                                        onTap: () =>
                                            Navigator.of(context).pop(),
                                        child: Container(
                                          color: Colors.transparent,
                                          child: Center(
                                            child: Hero(
                                              tag:
                                                  'tweet_image_${widget.userId}_${widget.visitedDate}_$pageIndex',
                                              child: InteractiveViewer(
                                                minScale: 1.0,
                                                maxScale: 5.0,
                                                child: CachedNetworkImage(
                                                  imageUrl:
                                                      _imageUrls[pageIndex],
                                                  fit: BoxFit.contain,
                                                  placeholder: (context, url) =>
                                                      const Center(
                                                          child:
                                                              CircularProgressIndicator()),
                                                  errorWidget: (context, url,
                                                          error) =>
                                                      const Icon(Icons.error),
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
                                      opacity: animation, child: child);
                                },
                              );
                            },
                            child: Hero(
                              tag:
                                  'tweet_image_${widget.userId}_${widget.visitedDate}_$index',
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  width: 200,
                                  height: 160,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const Center(
                                      child: CircularProgressIndicator()),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
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
