import 'package:bouldering_app/view_model/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:bouldering_app/router.dart';
import 'package:bouldering_app/view_model/gym_info_provider.dart';

/// ■ 関数
/// - main関数
///
/// 説明
/// - アプリのエントリポイント
/// - Riverpodによる状態管理を行うため，ProviderScopeで囲う
///
/// 引数
/// - なし
///
/// 返り値
/// - なし
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(ProviderScope(child: App()));
}

/// ■ クラス
/// - エントリポイント対象のクラス
class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  void initState() {
    super.initState();

    // FirebaseAuthから現在のユーザーを取得
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      final uid = currentUser.uid;

      // ログイン済みユーザーのデータを取得
      Future.microtask(() {
        ref.read(userProvider.notifier).fetchUserData(uid);
      });
    }

    // ジム情報を取得
    Future.microtask(() {
      ref.read(gymInfoProvider.notifier).fetchGymInfoData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final routerRef = ref.watch(routerProvider);
    return MaterialApp.router(routerConfig: routerRef);
  }
}

/// ■ クラス
/// - エントリポイント対象のクラス
// class App extends ConsumerWidget {
//   App({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final routerRef = ref.watch(routerProvider);

//     ref.read(gymInfoProvider.notifier).fetchGymInfoData();

//     return MaterialApp.router(
//       routerConfig: routerRef,
//     );
//   }
// }
