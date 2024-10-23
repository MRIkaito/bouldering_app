/* ============================================
 * ・種別
 * インポート
 * ============================================ */
import 'package:bouldering_app/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
void main() {
  runApp(ProviderScope(child: App()));
}

/* ============================================
 * ・種別
 * Appクラス
 *
 * ・説明 概要
 * エントリポイントの対象となるクラス
 * ============================================ */
class App extends StatelessWidget {
  App({super.key});
  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _appRouter.config(),
    );
  }
}

// /* ============================================
//  * ・種別
//  * プロバイダ
//  *
//  * ・説明 概要
//  * 画面の状態を司るプロバイダ.
//  * ============================================ */
// final indexProvider = StateProvider((ref) {
//   // 画面状態が数値と対応
//   return 0;
// });
