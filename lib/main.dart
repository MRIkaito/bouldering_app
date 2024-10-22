import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:bouldering_app/view/pages/home_page.dart';
import 'package:bouldering_app/view/pages/page_b.dart';
import 'package:bouldering_app/view/pages/page_c.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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
 *
 *
 * ・補足
 *
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
 *
 * ============================================ */
class Root extends ConsumerWidget {
  const Root({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 画面状態を示すインデックス
    final index = ref.watch(indexProvider);

    // アイテムたち
    final items = [
      BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'ホーム'),
      BottomNavigationBarItem(icon: Icon(Icons.description), label: 'ボル活'),
      BottomNavigationBarItem(icon: Icon(Icons.edit_document), label: '投稿'),
      // BottomNavigationBarItem(
      //     icon: SvgPicture.asset(
      //       'lib/view/assets/rock.svg',
      //     ),
      //     label: 'マイページ'),
    ];

    final bar = BottomNavigationBar(
        items: items,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        currentIndex: index,
        onTap: (index) {
          ref.read(indexProvider.notifier).state = index;
        });

    final pages = [
      HomePage(),
      PageB(),
      PageC(),
    ];

    return Scaffold(
      body: pages[index],
      bottomNavigationBar: bar,
    );
  }
}
