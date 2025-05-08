import 'package:bouldering_app/view_model/gym_info_provider.dart';
import 'package:bouldering_app/view_model/utility/calc_bouldering_duration.dart';
import 'package:bouldering_app/view/components/button.dart';
import 'package:bouldering_app/view/components/this_month_boul_log.dart';
import 'package:bouldering_app/view/components/user_logo_and_name.dart';
import 'package:bouldering_app/view_model/user_provider.dart';
import 'package:bouldering_app/view_model/utility/show_gym_name.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class UserProfileSection extends ConsumerWidget {
  const UserProfileSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    // final gymRef = ref.read(gymProvider);
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
              userName: user?.userName ?? "名無し",
              userLogo: user?.userIconUrl,
              heroTag: 'login_user_icon',
            ),
            const SizedBox(height: 16),

            // ボル活
            ThisMonthBoulLog(
              userId: user?.userId,
              monthsAgo: 0,
            ),
            const SizedBox(height: 8),

            // お気に入り・お気にいられ欄
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Button(
                  onPressedFunction: () => {
                    context.push('/FavoriteUser/favorite'),
                  },
                  buttonName: "お気に入り",
                  buttonWidth: ((MediaQuery.of(context).size.width) / 2) - 24,
                  buttonHeight: 36,
                  buttonColorCode: 0xFFE3DCE4,
                  buttonTextColorCode: 0xFF000000,
                ),
                Button(
                  onPressedFunction: () =>
                      {context.push("/FavoriteUser/favoredBy")},
                  buttonName: "お気に入られ",
                  buttonWidth: ((MediaQuery.of(context).size.width) / 2) - 24,
                  buttonHeight: 36,
                  buttonColorCode: 0xFFE3DCE4,
                  buttonTextColorCode: 0xFF000000,
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 自己紹介文
            SizedBox(
              width: double.infinity,
              child: Text(
                user?.userIntroduce == null ? " - " : user!.userIntroduce,
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
                user?.favoriteGym == null ? " - " : user!.favoriteGym,
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
  }
}
