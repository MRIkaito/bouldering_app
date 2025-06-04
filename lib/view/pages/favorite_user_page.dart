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
  const FavoriteUserPage({super.key, required this.type});

  // favorite(お気に入り)/favoredBy(被お気に入り)の区分を示す
  final String type;

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
          .fetchDataFavoriteUser(widget.type, currentUserId);

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
        title: Text(
          (widget.type == 'favorite') ? 'お気に入り' : 'お気に入られ',
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
              ? Center(child: Text("Errorが発生しました: $errorMessage"))
              : favoriteUserData.isEmpty
                  ? const Center(child: Text("データが見つかりませんでした"))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: favoriteUserData.length,
                      itemBuilder: (context, index) {
                        // final favoriteUser = favoriteUserData[index];
                        // final String? rawUrl = favoriteUser['user_icon_url'];
                        // final String favoriteUserIconUrl =
                        //     isValidUrl(rawUrl) ? rawUrl! : '';
                        // final String favoriteUserName =
                        //     favoriteUser['user_name'] ?? '-';
                        // final String favoriteUserHomeGym =
                        //     favoriteUser['gym_name'] ?? '-';
                        // final String favoriteUserId =
                        //     (widget.type == 'favorite')
                        //         ? favoriteUser['likee_user_id'] ?? ''
                        //         : favoriteUser['liker_user_id'] ?? '';

                        // return FavoriteUserItem(
                        //   name: favoriteUserName,
                        //   description: favoriteUserHomeGym,
                        //   imageUrl: favoriteUserIconUrl,
                        //   userId: favoriteUserId,
                        //   onTap: () {
                        //     context.push('/OtherUserPage/$favoriteUserId');
                        //   },
                        // );
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
