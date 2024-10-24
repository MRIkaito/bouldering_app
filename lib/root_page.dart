import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'app_router.dart';

@RoutePage()
class RootPage extends StatelessWidget {
  const RootPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter(
      routes: const [
        HomeRoute(),
        RouteB(),
        RouteC(),
        MyRoute(),
      ],
      builder: (context, child) {
        // タブが切り替わると発火します
        final tabsRouter = context.tabsRouter;
        return Scaffold(
          body: child,
          bottomNavigationBar: NavigationBar(
            selectedIndex: tabsRouter.activeIndex,
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.home),
                label: 'ホーム',
              ),
              const NavigationDestination(
                icon: Icon(Icons.description),
                label: 'ボル活',
              ),
              const NavigationDestination(
                icon: Icon(Icons.edit_document),
                label: '投稿',
              ),
              NavigationDestination(
                icon: SvgPicture.asset(
                  'lib/view/assets/rock_selected.svg',
                ),
                label: 'マイページ',
              ),
            ],
            onDestinationSelected: tabsRouter.setActiveIndex,
          ),
        );
      },
    );
  }
}
