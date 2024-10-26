import 'package:auto_route/auto_route.dart';
import 'package:bouldering_app/root_page.dart';
import 'package:bouldering_app/view/pages/home_page.dart';
import 'package:bouldering_app/view/pages/page_b.dart';
import 'package:bouldering_app/view/pages/page_c.dart';
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
            ),
            AutoRoute(
              path: 'my_page',
              page: MyRoute.page,
            ),
          ],
        ),
      ];
}
