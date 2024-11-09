import 'package:auto_route/auto_route.dart';
import 'package:bouldering_app/root_page.dart';
import 'package:bouldering_app/view/pages/home_page.dart';
import 'package:bouldering_app/view/pages/boul_log_page.dart';
import 'package:bouldering_app/view/pages/activity_post_page.dart';
import 'package:bouldering_app/view/pages/unlogined_my_page.dart';
import 'package:bouldering_app/view/pages/search_gim_page.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends _$AppRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(
          path: '/',
          page: RootRoute.page,
          children: [
            AutoRoute(
              path: 'home',
              page: HomeRouterRoute.page,
              children: [
                AutoRoute(
                  initial: true,
                  page: HomeRoute.page,
                ),
                AutoRoute(
                  path: 'search_gim',
                  page: SearchGimRoute.page,
                ),
              ],
            ),
            AutoRoute(
              path: 'page_b',
              page: RouteB.page,
            ),
            AutoRoute(
              path: 'page_c',
              page: RouteC.page,
              fullscreenDialog: true, // モーダル表示を可能にする設定を追加
            ),
            AutoRoute(
              path: 'my_page',
              page: MyRoute.page,
            ),
          ],
        ),
      ];
}
