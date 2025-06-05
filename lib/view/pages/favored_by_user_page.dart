import 'package:bouldering_app/view/components/app_logo.dart';
import 'package:bouldering_app/view/components/favorite_user_item.dart';
import 'package:bouldering_app/view_model/favorite_by_user_provider.dart';
import 'package:bouldering_app/view_model/favorite_user_provider.dart';
import 'package:bouldering_app/view_model/user_provider.dart';
import 'package:bouldering_app/view_model/utility/is_valid_url.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FavoredByUserPage extends ConsumerStatefulWidget {
  const FavoredByUserPage({super.key});

  @override
  ConsumerState<FavoredByUserPage> createState() => _FavoredByUserPageState();
}

class _FavoredByUserPageState extends ConsumerState<FavoredByUserPage>
    with RouteAware {
  bool isLoading = true;
  bool isError = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchFavoredByUsers();
  }

  Future<void> _fetchFavoredByUsers() async {
    print('🧪 favoriteUserState の中身（ユーザーID）:');
    for (final u in ref.read(favoriteUserProvider)) {
      print('  - ${u.userId} (${u.userName})');
    }

    setState(() {
      isLoading = true;
      isError = false;
      errorMessage = '';
    });

    try {
      final currentUserId = ref.read(userProvider)?.userId;
      if (currentUserId == null) return;

      await ref
          .read(favoriteUserProvider.notifier)
          .fetchDataFavoriteUser(currentUserId);

      await ref
          .read(favoredByUserProvider.notifier)
          .fetchFavoredByUsers(currentUserId);

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isError = true;
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  void didPopNext() {
    _fetchFavoredByUsers();
  }

  @override
  Widget build(BuildContext context) {
    final favoredByUsers = ref.watch(favoredByUserProvider);
    final favoriteUserState = ref.watch(favoriteUserProvider);
    final currentUserId = ref.read(userProvider)?.userId ?? '';

    // ★ デバッグログ①: 登録しているお気に入り一覧
    print('✅ 登録済みお気に入り一覧:');
    for (final user in favoriteUserState) {
      print(' - ${user.userName} (${user.userId})');
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFEF7FF),
        surfaceTintColor: const Color(0xFFFEF7FF),
        title: const Text(
          'お気に入られ',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : isError
              ? const Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 余白
                    SizedBox(height: 128),

                    // ロゴ
                    Center(child: AppLogo()),
                    SizedBox(height: 16),

                    Text(
                      'ユーザーをお気に入り登録しよう！',
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
                      'お気に入り登録して\n他の人の活動を見てみましょう！',
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
                  ],
                )
              : favoredByUsers.isEmpty
                  ? const Center(child: Text("データが見つかりませんでした"))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: favoredByUsers.length,
                      itemBuilder: (context, index) {
                        final user = favoredByUsers[index];

                        // ★ デバッグログ②: 被お気に入りユーザーと、その登録状態
                        final isFavorited = favoriteUserState
                            .any((u) => u.userId == user.userId);
                        print('🟡 表示対象: ${user.userName} (${user.userId})');
                        print('  ↳ isFavorited 判定結果: $isFavorited');

                        for (final user in favoredByUsers) {
                          print('🟨 判定中: ${user.userId} (${user.userName})');
                          final isFavorited = favoriteUserState.any((u) {
                            final result = u.userId == user.userId;
                            print(
                                '  ↳ 比較対象: ${u.userId} =?= ${user.userId} → $result');
                            return result;
                          });
                        }

                        final String imageUrl = isValidUrl(user.userIconUrl)
                            ? user.userIconUrl
                            : '';

                        return FavoriteUserItem(
                          name: user.userName,
                          description: user.gymName,
                          imageUrl: imageUrl,
                          userId: user.userId,
                          isFavorited: isFavorited,
                          onToggleFavorite: () async {
                            final favoriteNotifier =
                                ref.read(favoriteUserProvider.notifier);

                            if (isFavorited) {
                              await favoriteNotifier.removeFavoriteUser(
                                likerUserId: currentUserId,
                                likeeUserId: user.userId,
                              );
                            } else {
                              favoriteNotifier.addFavoriteUser(
                                  likerUserId: currentUserId,
                                  likeeUserId: user.userId);
                            }
                            setState(() {});
                          },
                          onTap: () {
                            context.push('/OtherUserPage/${user.userId}');
                          },
                        );
                      },
                    ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final routeObserver = ref.read(routeObserverProvider);
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    final routeObserver = ref.read(routeObserverProvider);
    routeObserver.unsubscribe(this);
    super.dispose();
  }
}

final routeObserverProvider =
    Provider<RouteObserver>((ref) => RouteObserver<PageRoute>());
