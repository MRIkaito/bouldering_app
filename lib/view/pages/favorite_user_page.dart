import 'package:bouldering_app/view/components/app_logo.dart';
import 'package:bouldering_app/view/components/favorite_user_item.dart';
import 'package:bouldering_app/view_model/favorite_user_provider.dart';
import 'package:bouldering_app/view_model/utility/is_valid_url.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bouldering_app/view_model/user_provider.dart';
import 'package:go_router/go_router.dart';

/// ■ クラス
/// - お気に入り登録している/されている ユーザーを表示するクラス
class FavoriteUserPage extends ConsumerStatefulWidget {
  // コンストラクタ
  const FavoriteUserPage({super.key});

  @override
  ConsumerState<FavoriteUserPage> createState() => _FavoriteUserPageState();
}

class _FavoriteUserPageState extends ConsumerState<FavoriteUserPage>
    with RouteAware {
  List<dynamic> favoriteUserData = [];
  bool isLoading = true;
  bool isError = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchFavoriteUsers();
  }

  /// ■ メソッド
  /// - お気に入りユーザーを取得する
  Future<void> _fetchFavoriteUsers() async {
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

      setState(() {
        favoriteUserData = ref.read(favoriteUserProvider);
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

  /// ■ メソッド
  /// - 他ユーザーページから戻ってきたときに再取得
  @override
  void didPopNext() {
    _fetchFavoriteUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFEF7FF),
        surfaceTintColor: const Color(0xFFFEF7FF),
        title: const Text(
          'お気に入り',
          style:
              const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
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
                      'ボル活投稿をして\nお気に入り登録してもらいましょう！',
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
                      'ボル活をしていろんな人に\n活動を見てもらいましょう！',
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
              : favoriteUserData.isEmpty
                  ? const Center(child: Text("データが見つかりませんでした"))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: favoriteUserData.length,
                      itemBuilder: (context, index) {
                        final FavoriteUserState favoriteUser =
                            favoriteUserData[index];
                        final String rawUrl = favoriteUser.userIconUrl;
                        final String favoriteUserIconUrl =
                            isValidUrl(rawUrl) ? rawUrl : '';
                        final String favoriteUserName = favoriteUser.userName;
                        final String favoriteUserHomeGym = favoriteUser.gymName;
                        final String favoriteUserId = favoriteUser.userId;

                        return FavoriteUserItem(
                          name: favoriteUserName,
                          description: favoriteUserHomeGym,
                          imageUrl: favoriteUserIconUrl,
                          userId: favoriteUserId,
                          isFavorited: ref
                              .read(favoriteUserProvider.notifier)
                              .isFavoritedByCurrentUser(favoriteUserId),
                          onToggleFavorite: () async {
                            final notifier =
                                ref.read(favoriteUserProvider.notifier);
                            final currentUserId =
                                ref.read(userProvider)!.userId;

                            if (notifier
                                .isFavoritedByCurrentUser(favoriteUserId)) {
                              await notifier.removeFavoriteUser(
                                  likerUserId: currentUserId,
                                  likeeUserId: favoriteUserId);
                            } else {
                              await notifier.addFavoriteUser(
                                  likerUserId: currentUserId,
                                  likeeUserId: favoriteUserId);
                            }

                            setState(() {}); // ボタンの文言だけ更新するため必要
                          },
                          onTap: () {
                            context.push('/OtherUserPage/$favoriteUserId');
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
