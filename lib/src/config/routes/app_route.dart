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
    );
  }
}
