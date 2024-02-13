import 'package:backtix_app/src/blocs/auth/auth_bloc.dart';
import 'package:backtix_app/src/config/routes/route_names.dart';
import 'package:backtix_app/src/config/routes/router_notifier.dart';
import 'package:backtix_app/src/presentations/pages/event_detail_page.dart';
import 'package:backtix_app/src/presentations/pages/home_page.dart';
import 'package:backtix_app/src/presentations/pages/login_page.dart';
import 'package:backtix_app/src/presentations/pages/my_tickets_history_page.dart';
import 'package:backtix_app/src/presentations/pages/my_tickets_page.dart';
import 'package:backtix_app/src/presentations/pages/onboarding_page.dart';
import 'package:backtix_app/src/presentations/pages/otp_activation_page.dart';
import 'package:backtix_app/src/presentations/pages/register_page.dart';
import 'package:backtix_app/src/presentations/pages/search_event_page.dart';
import 'package:backtix_app/src/presentations/pages/splash_page.dart';
import 'package:backtix_app/src/presentations/pages/ticket_purchase_detail_page.dart';
import 'package:backtix_app/src/presentations/wrappers/navigation_shell.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

class AppRoute {
  AppRoute({required AuthBloc authBloc}) : _authBloc = authBloc;

  final AuthBloc _authBloc;

  GoRouter get goRouter => init();

  static final rootNavigatorKey = GlobalKey<NavigatorState>();

  GoRouter init() {
    final RouterNotifier routerNotifier = RouterNotifier(authBloc: _authBloc);

    return GoRouter(
      debugLogDiagnostics: kDebugMode,
      navigatorKey: rootNavigatorKey,
      redirect: routerNotifier.redirect,
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          name: RouteNames.splash,
          builder: (_, __) => const SplashPage(),
          routes: [
            GoRoute(
              path: RouteNames.onboarding,
              name: RouteNames.onboarding,
              builder: (_, __) => const OnboardingPage(),
            ),
          ],
        ),
        GoRoute(
          path: '/login',
          name: RouteNames.login,
          builder: (_, state) {
            return LoginPage(
              initialUsername: state.uri.queryParameters['username'],
            );
          },
          routes: [
            GoRoute(
              path: RouteNames.register,
              name: RouteNames.register,
              builder: (_, __) => const RegisterPage(),
            ),
          ],
        ),
        GoRoute(
          path: '/activation',
          name: RouteNames.activation,
          builder: (_, __) => const OtpActivationPage(),
        ),
        StatefulShellRoute.indexedStack(
          parentNavigatorKey: rootNavigatorKey,
          builder: (_, __, navigationShell) {
            return NavigationShell(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  name: RouteNames.home,
                  path: '/${RouteNames.home}',
                  pageBuilder: (_, __) {
                    return const NoTransitionPage(child: HomePage());
                  },
                  routes: [
                    GoRoute(
                      name: RouteNames.eventDetail,
                      path: '${RouteNames.eventDetail}/:id',
                      parentNavigatorKey: rootNavigatorKey,
                      builder: (_, state) {
                        final queryParams = state.uri.queryParameters;
                        return EventDetailPage(
                          id: state.pathParameters['id'] ?? '',
                          name: queryParams['name'],
                          heroImageTag: queryParams['heroImageTag'],
                          heroImageUrl: queryParams['heroImageUrl'],
                        );
                      },
                    ),
                    GoRoute(
                      name: RouteNames.eventSearch,
                      path: '${RouteNames.eventSearch}/:search',
                      parentNavigatorKey: rootNavigatorKey,
                      builder: (_, state) {
                        return SearchEventPage(
                          keyword: state.pathParameters['search'] ?? '',
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  name: RouteNames.myTickets,
                  path: '/${RouteNames.myTickets}',
                  pageBuilder: (_, __) {
                    return const NoTransitionPage(child: MyTicketsPage());
                  },
                  routes: [
                    GoRoute(
                      name: RouteNames.myTicketDetail,
                      path: '${RouteNames.myTicketDetail}/:uid',
                      parentNavigatorKey: rootNavigatorKey,
                      builder: (_, state) => TicketPurchaseDetailPage(
                        uid: state.pathParameters['uid'] ?? '',
                      ),
                    ),
                    GoRoute(
                      name: RouteNames.myTicketsHistory,
                      path: RouteNames.myTicketsHistory,
                      parentNavigatorKey: rootNavigatorKey,
                      builder: (_, __) => const MyTicketsHistoryPage(),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
      refreshListenable: routerNotifier,
    );
  }
}
