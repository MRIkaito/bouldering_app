import 'package:auto_route/auto_route.dart';
import 'package:bouldering_app/root_page.dart';
import 'package:bouldering_app/view/pages/home_page.dart';
import 'package:bouldering_app/view/pages/boul_log_page.dart';
import 'package:bouldering_app/view/pages/activity_post_page.dart';
import 'package:bouldering_app/view/pages/login_or_signup_page.dart';
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
                // 下記の，地図からジムを検索するページを後々追加予定．
                /*
                AutoRoute(
                  path: 'search_gim_on_map',
                  page: SearchGimOnMapRoute.page
                ),
                 */
              ],
            ),
            AutoRoute(
              path: 'boul_log_page',
              page: BoulLogRoute.page,
            ),
            AutoRoute(
              path: 'activity_post_page',
              page: ActivityPostRoute.page,
              fullscreenDialog: true, // モーダル表示を可能にする設定を追加
            ),
            AutoRoute(
              path: 'unlogined_my',
              page: UnloginedMyRouterRoute.page,
              children: [
                AutoRoute(
                  initial: true,
                  path: 'unlogined_my_page',
                  page: UnloginedMyRoute.page,
                ),
                AutoRoute(
                  path: 'login_or_signup',
                  page: LoginOrSignUpRoute.page,
                ),
              ],
            ),
          ],
        ),
      ];
}
