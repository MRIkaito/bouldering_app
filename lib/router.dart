import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bouldering_app/view/pages/edit_profile_page.dart';
import 'package:bouldering_app/view/pages/facility_info_page.dart';
import 'package:bouldering_app/view/pages/favored_by_user_page.dart';
import 'package:bouldering_app/view/pages/favorite_user_page.dart';
import 'package:bouldering_app/view/pages/gym_selection_page.dart';
import 'package:bouldering_app/view/pages/login_or_signup_page.dart';
import 'package:bouldering_app/view/pages/logined_my_page.dart';
import 'package:bouldering_app/view/pages/searched_gim_list_page.dart';
import 'package:bouldering_app/view/pages/setting_page.dart';
import 'package:bouldering_app/view/pages/statics_report_page.dart';
import 'package:bouldering_app/view/pages/unlogined_my_page.dart';
import 'package:bouldering_app/view/pages/base.dart';
import 'package:bouldering_app/view/pages/boul_log_page.dart';
import 'package:bouldering_app/view/pages/home_page.dart';
import 'package:bouldering_app/view/pages/search_gim_page.dart';
import 'package:bouldering_app/view/pages/activity_post_page.dart';

import 'auth_provider.dart'; // AuthProviderを読み込み

// GlobalKeys
final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _homeNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'home');
final GlobalKey<NavigatorState> _boullogNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'boullog');
final GlobalKey<NavigatorState> _activitypostNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'activitypost');
final GlobalKey<NavigatorState> _unloginedNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'Unlogined');

// final GoRouter router = GoRouter(
final routerProvider = Provider<GoRouter>((ref) {
  final isLogined = ref.watch(authProvider);

  return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/home',
      routes: <RouteBase>[
        // ボトムナビゲーションバー有り
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return ScaffoldWithNavBar(
              navigationShell: navigationShell,
            );
          },
          branches: <StatefulShellBranch>[
            StatefulShellBranch(
              navigatorKey: _homeNavigatorKey,
              routes: <RouteBase>[
                GoRoute(
                  path: '/Home',
                  pageBuilder: (context, state) =>
                      const NoTransitionPage(child: HomePage()),
                  routes: [
                    GoRoute(
                      path: 'SearchGim',
                      pageBuilder: (context, state) =>
                          const NoTransitionPage(child: SearchGimPage()),
                      // builderでも可能なら，こちらのほうが単純な（デフォルトの遷移で済む
                      // 今は，どちらがいいのかわからないので，コメントアウトで残しておく．
                      // builder: (context, state) => const SearchGimPage(),
                      routes: [
                        GoRoute(
                            path: 'GymSelection',
                            pageBuilder: (context, state) =>
                                const NoTransitionPage(
                                    child: GymSelectionPage()),
                            routes: [
                              GoRoute(
                                  path: 'SearchedGimList',
                                  pageBuilder: (context, state) =>
                                      const NoTransitionPage(
                                          child: SearchedGimListPage())),
                            ]),
                        GoRoute(
                            path: 'SearchedGimList',
                            pageBuilder: (context, state) =>
                                const NoTransitionPage(
                                    child: SearchedGimListPage())),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              navigatorKey: _boullogNavigatorKey,
              routes: [
                GoRoute(
                  path: '/boullog',
                  pageBuilder: (context, state) =>
                      const NoTransitionPage(child: BoulLogPage()),
                ),
              ],
            ),
            StatefulShellBranch(
              // 投稿
              navigatorKey: _activitypostNavigatorKey,
              routes: [
                GoRoute(
                  path: '/activitypost',
                  pageBuilder: (context, state) =>
                      NoTransitionPage(child: ActivityPostPage()),
                ),
              ],
            ),
            StatefulShellBranch(
              navigatorKey: _unloginedNavigatorKey,
              routes: [
                GoRoute(
                  path: '/Unlogined',
                  pageBuilder: (context, state) =>
                      const NoTransitionPage(child: UnloginedMyPage()),
                  routes: [
                    GoRoute(
                      path: "LoginOrSignUp",
                      pageBuilder: (context, state) =>
                          const NoTransitionPage(child: LoginOrSignUpPage()),
                      routes: [
                        GoRoute(
                          path: "Logined",
                          pageBuilder: (context, state) =>
                              const NoTransitionPage(child: LoginedMyPage()),
                        ),
                      ],
                    ),
                  ],
                  redirect: (BuildContext context, GoRouterState state) {
                    if (isLogined) {
                      return '/Unlogined/LoginOrSignUp/Logined'; // ログイン：マイページ
                    }
                    return null; // 未ログイン：ログイン・サインアップページ
                  },
                ),
              ],
            ),
          ],
        ),

        // その他フルスクリーンダイアログ
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: '/FacilityInfo',
          pageBuilder: (context, state) => const MaterialPage(
              fullscreenDialog: true, child: FacilityInfoPage()),
        ),
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: '/StaticsReport',
          pageBuilder: (context, state) => const MaterialPage(
              fullscreenDialog: true, child: StaticsReportPage()),
        ),
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: '/Setting',
          pageBuilder: (context, state) =>
              const MaterialPage(fullscreenDialog: true, child: SettingPage()),
        ),
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: '/FavoriteUser',
          pageBuilder: (context, state) => const MaterialPage(
              fullscreenDialog: true, child: FavoriteUserPage()),
        ),
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: '/FavoredByUser',
          pageBuilder: (context, state) => const MaterialPage(
              fullscreenDialog: true, child: FavoredByUserPage()),
        ),
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: '/EditProfile',
          pageBuilder: (context, state) => const MaterialPage(
              fullscreenDialog: true, child: EditProfilePage()),
        ),
        // GoRoute(
        //   parentNavigatorKey: _rootNavigatorKey,
        //   path: '/notification',
        //   pageBuilder: (context, state) => const MaterialPage(
        //       fullscreenDialog: true, child: NotificationPage()),
        // )
      ]);
});
