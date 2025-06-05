import 'package:bouldering_app/view/components/button.dart';
import 'package:bouldering_app/view_model/favorite_user_provider.dart';
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
import 'package:go_router/go_router.dart';

/// ■ クラス
class OtherUserProfileSection extends ConsumerWidget {
  final String userId;
  const OtherUserProfileSection({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final otherUserAsync = ref.watch(otherUserProvider(userId));
    final currentUser = ref.watch(userProvider);
    final favoriteList = ref.watch(favoriteUserProvider);
    final isFavorited = favoriteList.any((user) => user.userId == userId);

    /// ■ メソッド
    /// - お気に入り登録ボタン / お気に入り解除ボタンを押下して，ユーザーのお気に入り状態を管理する
    Future<void> _toggleFavorite() async {
      if (currentUser == null) return;

      final favoriteUserState = ref.read(favoriteUserProvider.notifier);
      final success = isFavorited
          ? await favoriteUserState.removeFavoriteUser(
              likerUserId: currentUser.userId, likeeUserId: userId)
          : await favoriteUserState.addFavoriteUser(
              likerUserId: currentUser.userId, likeeUserId: userId);

      /* 再取得して状態を即時更新 */
      /* 外部から状態変更された可能性があるときの状態を再進化したい場合の処理 */
      /* データ整合性を厳密に保ち街時に個の処理を実装する */
      /* 現状は実装不要 */
      // if (success) {
      //   await favoriteUserState.fetchDataFavoriteUser(
      //       'favorite', currentUser.userId);
      // }
    }

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
                    userId: user.userId,
                  ),
                  const SizedBox(height: 16),

                  // ボル活
                  ThisMonthBoulLog(
                    userId: user.userId,
                    monthsAgo: 0,
                  ),
                  const SizedBox(height: 8),

                  if (currentUser != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Button(
                          onPressedFunction: _toggleFavorite,
                          buttonName: isFavorited ? 'お気に入り登録解除' : 'お気に入り登録',
                          buttonWidth: MediaQuery.of(context).size.width - 48,
                          buttonHeight: 36,
                          buttonColorCode:
                              isFavorited ? 0xFF0056FF : 0xFFE3DCE4,
                          buttonTextColorCode:
                              isFavorited ? 0xFFFFFFFF : 0xFF000000,
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
                      // Text(showGymName(user, gymRef)),
                      Builder(builder: (_) {
                        final int homeGymId = user.homeGymId;
                        if (homeGymId == null ||
                            !gymRef.containsKey(homeGymId)) {
                          return const Text("-",
                              style: TextStyle(fontSize: 14));
                        } else {
                          return GestureDetector(
                            onTap: () {
                              context.push('/FacilityInfo/$homeGymId');
                            },
                            child: Text(
                              showGymName(user, gymRef),
                              style: const TextStyle(
                                color: Colors.blue,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }
                      }),
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
