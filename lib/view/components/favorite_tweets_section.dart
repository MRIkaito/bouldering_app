import 'dart:core';
import 'package:bouldering_app/view/components/app_logo.dart';
import 'package:bouldering_app/view_model/favorite_user_tweets_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bouldering_app/view/components/boul_log.dart';
import 'package:bouldering_app/view_model/user_provider.dart';
import 'package:bouldering_app/view_model/auth_provider.dart';

class FavoriteTweetsSection extends ConsumerStatefulWidget {
  const FavoriteTweetsSection({super.key});

  @override
  FavoriteTweetsSectionState createState() => FavoriteTweetsSectionState();
}

class FavoriteTweetsSectionState extends ConsumerState<FavoriteTweetsSection> {
  // スクロールを監視するコントローラ
  final ScrollController _favoriteTweetsScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _favoriteTweetsScrollController.addListener(_onFavoriteUserTweetsScroll);
  }

  @override
  void dispose() {
    _favoriteTweetsScrollController.dispose();
    super.dispose();
  }

  void _onFavoriteUserTweetsScroll() {
    if (_favoriteTweetsScrollController.position.pixels >
        _favoriteTweetsScrollController.position.maxScrollExtent - 100) {
      final userId = ref.read(userProvider)!.userId;
      ref.read(favoriteUserTweetsProvider(userId).notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = ref.watch(authProvider);
    final userId = ref.watch(userProvider)?.userId;
    // デバッグ
    print("isLoggedIn: $isLoggedIn");
    print("userId: $userId");

    if (!isLoggedIn || userId == null) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 余白
          SizedBox(height: 32),

          // ロゴ
          Center(child: AppLogo()),
          SizedBox(height: 16),

          Text(
            'イワノボリタイに登録しよう',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF0056FF),
              fontSize: 20,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,
              height: 1.2,
              letterSpacing: -0.50,
            ),
          ),
          SizedBox(height: 16),

          Text(
            'ログインしてユーザーを\nお気に入り登録しよう!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,
              height: 1.4,
              letterSpacing: -0.50,
            ),
          ),
          SizedBox(height: 16),

          Text(
            'お気に入り登録したユーザーの\nツイートを見ることができます！',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,
              height: 1.4,
              letterSpacing: -0.50,
            ),
          ),
        ],
      );
    }

    // お気に入りユーザーツイート
    final favoriteUserTweetsState =
        ref.watch(favoriteUserTweetsProvider(userId));
    final favoriteUserTweets = favoriteUserTweetsState.favoriteUserTweets;
    final _hasMoreFavoriteUserTweets = favoriteUserTweetsState.hasMore;

    return isLoggedIn
        // ログイン時
        ? RefreshIndicator(
            onRefresh: () async {
              await ref
                  .read(favoriteUserTweetsProvider(userId).notifier)
                  .refreshTweets();
            },
            child: ListView.builder(
              controller: _favoriteTweetsScrollController,
              itemCount: favoriteUserTweets.length +
                  (_hasMoreFavoriteUserTweets ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == favoriteUserTweets.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: SizedBox.shrink(),
                    ),
                  );
                }

                final favoriteUserTweet = favoriteUserTweets[index];

                return BoulLog(
                  userId: favoriteUserTweet.userId,
                  userName: favoriteUserTweet.userName,
                  userIconUrl: favoriteUserTweet.userIconUrl,
                  visitedDate: favoriteUserTweet.visitedDate
                      .toLocal()
                      .toIso8601String()
                      .split('T')[0],
                  // DateTime.parse(favoriteUserTweet.visitedDate.toString()).toLocal().toString().split(' ')[0],
                  gymId: favoriteUserTweet.gymId.toString(),
                  gymName: favoriteUserTweet.gymName,
                  prefecture: favoriteUserTweet.prefecture,
                  tweetContents: favoriteUserTweet.tweetContents,
                  tweetImageUrls: favoriteUserTweet.mediaUrls,
                );
              },
            ),
          )

        // 未ログイン時
        : Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 32),
              Center(
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: SvgPicture.asset('lib/view/assets/app_main_icon.svg'),
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'イワノボリタイに\n登録しよう',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF0056FF),
                    fontSize: 32,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                    letterSpacing: -0.50,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'ログインしてユーザーを\nお気に入り登録しよう!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                  letterSpacing: -0.50,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'お気に入り登録したユーザーの\nツイートを見ることができます！',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                  letterSpacing: -0.50,
                ),
              ),
            ],
          );
  }
}
