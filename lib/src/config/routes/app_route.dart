import 'package:backtix_app/src/config/routes/route_names.dart';
import 'package:backtix_app/src/config/routes/router_notifier.dart';
import 'package:backtix_app/src/presentations/pages/home_page.dart';
import 'package:backtix_app/src/presentations/pages/login_page.dart';
import 'package:backtix_app/src/presentations/pages/onboarding_page.dart';
import 'package:backtix_app/src/presentations/pages/otp_activation_page.dart';
import 'package:backtix_app/src/presentations/pages/register_page.dart';
import 'package:backtix_app/src/presentations/pages/splash_page.dart';
import 'package:backtix_app/src/presentations/wrappers/navigation_shell.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

class AppRoute {
  AppRoute() : _goRouter = AppRoute.init();

  final GoRouter _goRouter;

  GoRouter get goRouter => _goRouter;

  static final rootNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter init() {
    final RouterNotifier routerNotifier = RouterNotifier();

    return GoRouter(
      debugLogDiagnostics: true,
      navigatorKey: rootNavigatorKey,
      redirect: routerNotifier.redirect,
      initialLocation: '/splash',
      routes: [
        GoRoute(
          path: '/splash',
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
                  path: '/home',
                  pageBuilder: (_, __) {
                    return const NoTransitionPage(child: HomePage());
                  },
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
