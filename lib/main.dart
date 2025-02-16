/* ============================================
 * ・種別
 * インポート
 * ============================================ */
import 'package:bouldering_app/router.dart';
import 'package:bouldering_app/view_model/gym_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

/* ============================================
 * ・種別
 * main関数
 *
 * ・説明 概要
 * アプリのエントリポイントとなる関数
 *
 * ・補足
 * Riverpodによる状態管理を行うため、ProviderScopeで囲う
 * ============================================ */
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(ProviderScope(child: App()));
}

/* ============================================
 * ・種別
 * Appクラス
 *
 * ・説明 概要
 * エントリポイントの対象となるクラス
 * ============================================ */
class App extends ConsumerWidget {
  App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routerRef = ref.watch(routerProvider);
    // TODO: 下記のコードが実際に実行できるかを試す必要がある
    // TODO：また，DBに実装したデータを，軽度・緯度が小数点0で埋められているので，すべてもう一度登録しなおす必要あり．
    final gymRef = ref.watch(gymProvider.notifier).fetchGymData();

    return MaterialApp.router(
      routerConfig: routerRef,
    );
  }
}
