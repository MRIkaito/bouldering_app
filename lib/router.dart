import 'package:bouldering_app/view/pages/activity_post_from_facility_info_page.dart';
import 'package:bouldering_app/view/pages/favored_by_user_page.dart';
import 'package:bouldering_app/view/pages/my_page_gate.dart';
import 'package:bouldering_app/view/pages/other_user_page.dart';
import 'package:bouldering_app/view/pages/search_gym_on_map_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bouldering_app/view/pages/edit_profile_page.dart';
import 'package:bouldering_app/view/pages/facility_info_page.dart';
import 'package:bouldering_app/view/pages/favorite_user_page.dart';
import 'package:bouldering_app/view/pages/gym_selection_page.dart';
import 'package:bouldering_app/view/pages/login_or_signup_page.dart';
import 'package:bouldering_app/view/pages/searched_gim_list_page.dart';
import 'package:bouldering_app/view/pages/setting_page.dart';
import 'package:bouldering_app/view/pages/statics_report_page.dart';
import 'package:bouldering_app/view/pages/base.dart';
import 'package:bouldering_app/view/pages/boul_log_page.dart';
import 'package:bouldering_app/view/pages/home_page.dart';
import 'package:bouldering_app/view/pages/search_gim_page.dart';
import 'package:bouldering_app/view/pages/activity_post_page.dart';

// GlobalKeys
final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _homeNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'home');
final GlobalKey<NavigatorState> _boullogNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'boullog');
final GlobalKey<NavigatorState> _activitypostNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'activitypost');
final GlobalKey<NavigatorState> _mypageNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'Mypage');

// final GoRouter router = GoRouter(
final routerProvider = Provider<GoRouter>((ref) {
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
                          const MaterialPage(child: SearchGimPage()),
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
                                    const MaterialPage(
                                  child: SearchedGimListPage(),
                                ),
                              )
                            ]),
                        GoRoute(
                            path: 'SearchedGimList',
                            pageBuilder: (context, state) => const MaterialPage(
                                child: SearchedGimListPage())),
                      ],
                    ),
                    GoRoute(
                      path: 'SearchGymOnMap',
                      pageBuilder: (context, state) =>
                          const MaterialPage(child: SearchGymOnMapPage()),
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
              navigatorKey: _mypageNavigatorKey,
              routes: [
                GoRoute(
                  path: '/mypage',
                  pageBuilder: (context, state) =>
                      const NoTransitionPage(child: MyPageGate()),
                ),
              ],
            ),
          ],
        ),

        // その他フルスクリーンダイアログ
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: '/FacilityInfo/:gymId',
          pageBuilder: (context, state) {
            final String gymId = state.pathParameters['gymId'] ?? '';
            return MaterialPage(
              child: FacilityInfoPage(gymId: gymId),
            );
          },
          routes: [
            GoRoute(
              parentNavigatorKey: _rootNavigatorKey,
              path: 'ActivityPostFromFacilityInfo',
              pageBuilder: (context, state) {
                final String gymId = state.pathParameters['gymId'] ?? ''; // 再取得
                return MaterialPage(
                  fullscreenDialog: true,
                  child: ActivityPostFromFacilityInfoPage(gymId: gymId),
                );
              },
            ),
          ],
        ),
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: '/LoginOrSignUp',
          pageBuilder: (context, state) => const MaterialPage(
            fullscreenDialog: true,
            child: LoginOrSignUpPage(),
          ),
        ),
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: '/LoginOrSignUp',
          pageBuilder: (context, state) =>
              const MaterialPage(child: LoginOrSignUpPage()),
        ),
        GoRoute(
            parentNavigatorKey: _rootNavigatorKey,
            path: '/StaticsReport/:userId',
            pageBuilder: (context, state) {
              // 遷移先にuserIdを渡す
              final String userId = state.pathParameters['userId'] ?? '';
              return MaterialPage(
                  fullscreenDialog: true,
                  child: StaticsReportPage(userId: userId));
            }),
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: '/Setting',
          pageBuilder: (context, state) =>
              const MaterialPage(fullscreenDialog: true, child: SettingPage()),
        ),
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: '/FavoriteUser/:type',
          pageBuilder: (context, state) {
            return const MaterialPage(
                fullscreenDialog: true, child: FavoriteUserPage());
          },
        ),
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: '/FavoredByUser',
          pageBuilder: (context, state) => const MaterialPage(
            fullscreenDialog: true,
            child: FavoredByUserPage(),
          ),
        ),
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: '/EditProfile',
          pageBuilder: (context, state) =>
              const MaterialPage(child: EditProfilePage()),
        ),
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: '/ActivityPostEdit',
          pageBuilder: (context, state) {
            final extra = state.extra as Map<String, dynamic>;
            return MaterialPage(
              fullscreenDialog: true,
              child: ActivityPostPage(initialData: extra),
            );
          },
        ),
        GoRoute(
            parentNavigatorKey: _rootNavigatorKey,
            path: '/OtherUserPage/:userId',
            pageBuilder: (context, state) {
              final String userId = state.pathParameters['userId'] ?? '';
              return MaterialPage(
                  fullscreenDialog: true, child: OtherUserPage(userId: userId));
            }),
      ]);
});
