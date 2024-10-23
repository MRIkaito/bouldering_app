/* ============================================
 * ・種別
 * インポート
 * ============================================ */
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:bouldering_app/view/pages/home_page.dart';
import 'package:bouldering_app/view/pages/page_b.dart';
import 'package:bouldering_app/view/pages/page_c.dart';
import 'package:bouldering_app/view/pages/my_page.dart';
import 'package:bouldering_app/view/pages/search_gim_page.dart';

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
  runApp(ProviderScope(child: MyApp()));
}

/* ============================================
 * ・種別
 * MyAppクラス
 *
 * ・説明 概要
 * エントリポイントの対象となるクラス
 * ============================================ */
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      home: Root(),
    );
  }
}

/* ============================================
 * ・種別
 * プロバイダ
 *
 * ・説明 概要
 * 画面の状態を司るプロバイダ.
 * ============================================ */
final indexProvider = StateProvider((ref) {
  // 画面状態が数値と対応
  return 0;
});

/* ============================================
 * ・種別
 * ルート(Root)クラス
 *
 * ・説明 概要
 * アプリ全体で画面繊維ができるように設定するクラス
 * ============================================ */
class Root extends ConsumerWidget {
  const Root({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 現在選択されている画面をインデックスで取得
    final index = ref.watch(indexProvider);

    // BottomNavigationBarで表示するアイテム群
    final items = [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ホーム'),
      BottomNavigationBarItem(icon: Icon(Icons.description), label: 'ボル活'),
      BottomNavigationBarItem(icon: Icon(Icons.edit_document), label: '投稿'),
      BottomNavigationBarItem(
          icon: index == 3
          ? SvgPicture.asset(
            'lib/view/assets/rock_selected.svg',
          )
          : SvgPicture.asset(
            'lib/view/assets/rock_unselected.svg',
          ),
          label: 'マイページ'),
    ];

    // BottomNavigationBar設定
    final bar = BottomNavigationBar(
      items: items,
      backgroundColor: Colors.white,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
      currentIndex: index,
      onTap: (index) {
        ref.read(indexProvider.notifier).state = index;
      },
      type: BottomNavigationBarType.fixed,
    );

    // BottomNavigationで遷移するページ
    final pages = [
      HomePage(),
      PageB(),
      PageC(),
      MyPage(),
      SearchGimPage(),
    ];

    // BottomNavigationBar付きのScaffold
return Scaffold(
      body: pages[index], // 選択されたページを表示
      bottomNavigationBar: BottomNavigationBar(
        items: items,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        currentIndex: index,
        onTap: (newIndex) {
          ref.read(indexProvider.notifier).state = newIndex;
        },
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
