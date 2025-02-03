import 'package:bouldering_app/view/components/favorite_user_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bouldering_app/view_model/favorite_user_view_model.dart';
import 'package:bouldering_app/view_model/user_provider.dart';

/// ■ クラス
/// - お気に入り登録している/されている ユーザーを表示するクラス
class FavoriteUserPage extends ConsumerWidget {
  // コンストラクタ
  const FavoriteUserPage({super.key, required this.type});

  // favorite(お気に入り)/favoredBy(被お気に入り)の区分を示す
  final String type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // インスタンス化
    final FavoriteUserViewModel favoriteUser = FavoriteUserViewModel();
    // ユーザー情報(ID)を取得
    // TODO：強制的アンラップで問題ないかを確認する
    final userId = ref.read(userProvider)!.userId;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          (type == 'favorite') ? 'お気に入り' : 'お気に入られ',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: favoriteUser.fetchDataFavoriteUser(type, userId),
        builder: (context, snapshot) {
          // お気に入りユーザーデータ取得中
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Errorが発生しました:${snapshot.error}"));
          } else if (snapshot.hasData) {
            // お気に入りユーザーを取得
            final favoirteUserData = snapshot.data!;

            // お気に入りユーザーをリスト形式で表示
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: favoirteUserData.length,
              itemBuilder: (context, index) {
                final favoriteUser = favoirteUserData[index];
                final String favoriteUserIconUrl =
                    favoriteUser['user_icon_url'] ?? 'https://fakeimg.pl/50x50';
                // TODO：今は、上記のuser_icon_urlがnullの場合は直接記述している
                // URL(ダミーデータ)として標示しているが、これはいずれDBに記述するようにする。
                // 設定していない場合は上記のURLを記述して埋めるようにする
                final String favoriteUserName = favoriteUser['user_name'];
                final String favoriteUserHomeGym = favoriteUser['gym_name'];

                return FavoriteUserItem(
                  name: favoriteUserName,
                  description: favoriteUserHomeGym,
                  imageUrl: favoriteUserIconUrl,
                );
              },
            );
          } else {
            return const Center(child: Text("データが見つかりませんでした"));
          }
        },
      ),
    );
  }
}
