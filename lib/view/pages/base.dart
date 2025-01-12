import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  final bool? hideBottomNavigation;

  const ScaffoldWithNavBar({
    required this.navigationShell,
    this.hideBottomNavigation,
    Key? key,
  }) : super(key: key ?? const ValueKey<String>('ScaffoldWithNavBar'));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (int index) => _onTap(context, index),
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ホーム'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.library_books), label: 'ボル活'),
          const BottomNavigationBarItem(icon: Icon(Icons.add_box), label: '投稿'),
          BottomNavigationBarItem(
              icon: SvgPicture.asset('lib/view/assets/rock_selected.svg'),
              label: 'マイページ'),
        ],
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
      ),
    );
  }

  void _onTap(BuildContext context, int index) {
    // 場合によっては，インデックスが3のとき(マイページのとき)は反応しない
    // という仕様にすることも考える
    if (index == navigationShell.currentIndex) {
      return;
    }

    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
