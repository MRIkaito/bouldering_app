import 'package:bouldering_app/view/components/button.dart';
import 'package:bouldering_app/view_model/favorite_user_view_model.dart';
import 'package:bouldering_app/view_model/gym_info_provider.dart';
import 'package:bouldering_app/view_model/other_user_provider.dart';
import 'package:bouldering_app/view_model/user_provider.dart';
import 'package:bouldering_app/view_model/utility/calc_bouldering_duration.dart';
import 'package:bouldering_app/view/components/this_month_boul_log.dart';
import 'package:bouldering_app/view/components/user_logo_and_name.dart';
import 'package:bouldering_app/view_model/utility/show_gym_name.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;

class OtherUserProfileSection extends ConsumerStatefulWidget {
  // コンストラクタ
  const OtherUserProfileSection({super.key, required this.userId});
  // プロパティ
  final String userId;

  @override
  ConsumerState<OtherUserProfileSection> createState() =>
      _OtherUserProfileSectionState();
}

class _OtherUserProfileSectionState
    extends ConsumerState<OtherUserProfileSection> {
  bool? isFavorited; // 訪問したユーザーがお気に入り登録をしている人であるかどうかを確認する

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final currentUser = ref.read(userProvider);
    if (currentUser == null) return;

    final favoriteVM = FavoriteUserViewModel();
    final result =
        await favoriteVM.isAlreadyFavorited(currentUser.userId, widget.userId);
    setState(() => isFavorited = result);
  }

  Future<void> _toggleFavorite() async {
    final currentUser = ref.read(userProvider);
    if (currentUser == null) return;

    final likeeId = widget.userId;
    final likerId = currentUser.userId;

    const endpoint =
        'https://us-central1-gcp-compute-engine-441303.cloudfunctions.net/getData';
    final url = Uri.parse(endpoint).replace(queryParameters: {
      'request_id': isFavorited! ? '10' : '9', // 解除:10 / 登録:9
      'liker_user_id': likerId,
      'likee_user_id': likeeId,
    });

    final response = await (isFavorited! ? http.delete(url) : http.get(url));
    print('🟡 [DEBUG] status: ${response.statusCode}, body: ${response.body}');

    if (response.statusCode == 200) {
      setState(() {
        isFavorited = !isFavorited!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final otherUserAsync = ref.watch(otherUserProvider(widget.userId));
    final currentUser = ref.watch(userProvider);

    return otherUserAsync.when(
        loading: () => const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            ),
        error: (e, st) => SliverToBoxAdapter(
              child: Center(child: Text('エラーが発生しました: $e')),
            ),
        data: (user) {
          if (user == null) {
            return const SliverToBoxAdapter(
                child: Center(child: Text("ユーザー情報が取得できませんでした")));
          }

          final gymRef = ref.read(gymInfoProvider);
          String boulLogDuration = calcBoulderingDuration(user);

          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ユーザ写真・名前欄
                  UserLogoAndName(
                    userName: user.userName,
                    userLogo: user.userIconUrl,
                    heroTag: 'user_icon_${user.userId}', // 各ユーザーのユーザーIDを識別子タグ化
                  ),
                  const SizedBox(height: 16),

                  // ボル活
                  ThisMonthBoulLog(
                    userId: user.userId,
                    monthsAgo: 0,
                  ),
                  const SizedBox(height: 8),

                  if (currentUser != null &&
                      currentUser.userId != user.userId &&
                      isFavorited != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Button(
                          onPressedFunction: _toggleFavorite,
                          buttonName: isFavorited! ? '登録解除' : '登録',
                          buttonWidth: MediaQuery.of(context).size.width - 48,
                          buttonHeight: 36,
                          buttonColorCode:
                              isFavorited! ? 0xFF0056FF : 0xFFE3DCE4,
                          buttonTextColorCode:
                              isFavorited! ? 0xFFFFFFFF : 0xFF000000,
                        ),
                      ],
                    ),

                  const SizedBox(height: 8),

                  // 自己紹介文
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      user.userIntroduce,
                      textAlign: TextAlign.left,
                      softWrap: true,
                      overflow: TextOverflow.visible,
                      maxLines: null,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                        letterSpacing: -0.50,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 好きなジム欄
                  const Text(
                    "好きなジム",
                    style: TextStyle(
                      color: Color(0xFF8D8D8D),
                      fontSize: 16,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.bold,
                      height: 1.4,
                      letterSpacing: -0.50,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      user.favoriteGym,
                      textAlign: TextAlign.left,
                      softWrap: true,
                      overflow: TextOverflow.visible,
                      maxLines: null,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                        letterSpacing: -0.50,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ボル活歴
                  Row(
                    children: [
                      SvgPicture.asset('lib/view/assets/date_range.svg'),
                      const SizedBox(width: 8),
                      const Text("ボルダリング歴："),
                      Text(boulLogDuration),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // ホームジム
                  Row(
                    children: [
                      SvgPicture.asset('lib/view/assets/home_gim_icon.svg'),
                      const SizedBox(width: 8),
                      const Text("ホームジム："),
                      Text(showGymName(user, gymRef)),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        });
  }
}
