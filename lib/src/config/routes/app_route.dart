import 'package:backtix_app/src/blocs/auth/auth_bloc.dart';
import 'package:backtix_app/src/config/routes/route_names.dart';
import 'package:backtix_app/src/config/routes/router_notifier.dart';
import 'package:backtix_app/src/presentations/pages/app_start/onboarding_page.dart';
import 'package:backtix_app/src/presentations/pages/app_start/splash_page.dart';
import 'package:backtix_app/src/presentations/pages/auth/login_page.dart';
import 'package:backtix_app/src/presentations/pages/auth/otp_activation_page.dart';
import 'package:backtix_app/src/presentations/pages/auth/register_page.dart';
import 'package:backtix_app/src/presentations/pages/location_picker_page.dart';
import 'package:backtix_app/src/presentations/pages/my_events/create_new_event_page.dart';
import 'package:backtix_app/src/presentations/pages/my_events/edit_event_page.dart';
import 'package:backtix_app/src/presentations/pages/my_events/event_ticket_refund_page.dart';
import 'package:backtix_app/src/presentations/pages/my_events/event_ticket_sales_page.dart';
import 'package:backtix_app/src/presentations/pages/my_events/my_event_detail_page.dart';
import 'package:backtix_app/src/presentations/pages/my_events/my_events_page.dart';
import 'package:backtix_app/src/presentations/pages/my_events/sales_by_ticket_page.dart';
import 'package:backtix_app/src/presentations/pages/my_events/verify_ticket_page.dart';
import 'package:backtix_app/src/presentations/pages/my_tickets/my_tickets_history_page.dart';
import 'package:backtix_app/src/presentations/pages/my_tickets/my_tickets_page.dart';
import 'package:backtix_app/src/presentations/pages/my_tickets/ticket_purchase_detail_page.dart';
import 'package:backtix_app/src/presentations/pages/published_events/event_detail_page.dart';
import 'package:backtix_app/src/presentations/pages/published_events/home_page.dart';
import 'package:backtix_app/src/presentations/pages/published_events/search_published_event_page.dart';
import 'package:backtix_app/src/presentations/pages/unsupported_platform_page.dart';
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
      refreshListenable: routerNotifier,
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
                        return SearchPublishedEventPage(
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
                      path: 'detail/:uid',
                      parentNavigatorKey: rootNavigatorKey,
                      builder: (_, state) => TicketPurchaseDetailPage(
                        uid: state.pathParameters['uid'] ?? '',
                      ),
                    ),
                    GoRoute(
                      name: RouteNames.myTicketsHistory,
                      path: 'history',
                      parentNavigatorKey: rootNavigatorKey,
                      builder: (_, __) => const MyTicketsHistoryPage(),
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  name: RouteNames.myEvents,
                  path: '/${RouteNames.myEvents}',
                  pageBuilder: (_, __) {
                    return const NoTransitionPage(child: MyEventsPage());
                  },
                  routes: [
                    GoRoute(
                      name: RouteNames.locationPicker,
                      path: 'pickLocation',
                      parentNavigatorKey: rootNavigatorKey,
                      builder: (_, state) {
                        final lat = state.uri.queryParameters['latitude'];
                        final lng = state.uri.queryParameters['longitude'];
                        return LocationPickerPage(
                          latitude: lat != null ? double.tryParse(lat) : null,
                          longitude: lng != null ? double.tryParse(lng) : null,
                        );
                      },
                    ),
                    GoRoute(
                      name: RouteNames.createNewEvent,
                      path: 'new',
                      parentNavigatorKey: rootNavigatorKey,
                      builder: (_, __) => const CreateNewEventPage(),
                    ),
                    GoRoute(
                      name: RouteNames.editEvent,
                      path: ':id/edit',
                      parentNavigatorKey: rootNavigatorKey,
                      builder: (_, state) => EditEventPage(
                        eventId: state.pathParameters['id'] ?? '',
                      ),
                    ),
                    GoRoute(
                      name: RouteNames.myEventDetail,
                      path: ':id',
                      parentNavigatorKey: rootNavigatorKey,
                      builder: (_, state) {
                        final queryParams = state.uri.queryParameters;
                        return MyEventDetailPage(
                          id: state.pathParameters['id'] ?? '',
                          name: queryParams['name'],
                          heroImageTag: queryParams['heroImageTag'],
                          heroImageUrl: queryParams['heroImageUrl'],
                        );
                      },
                      routes: [
                        GoRoute(
                          name: RouteNames.verifyTicket,
                          path: 'verify',
                          parentNavigatorKey: rootNavigatorKey,
                          builder: (_, state) {
                            if (VerifyTicketPage.supported) {
                              return VerifyTicketPage(
                                eventId: state.pathParameters['id'] ?? '',
                              );
                            }
                            return const UnsupportedPlatformPage();
                          },
                        ),
                        GoRoute(
                          name: RouteNames.eventTicketSales,
                          path: 'sales',
                          parentNavigatorKey: rootNavigatorKey,
                          builder: (_, state) => EventTicketSalesPage(
                            eventId: state.pathParameters['id'] ?? '',
                          ),
                        ),
                        GoRoute(
                          name: RouteNames.eventTicketRefundRequest,
                          path: 'refunds',
                          parentNavigatorKey: rootNavigatorKey,
                          builder: (_, state) => EventTicketRefundPage(
                            eventId: state.pathParameters['id'] ?? '',
                          ),
                        ),
                        GoRoute(
                          name: RouteNames.eventTicketSalesDetail,
                          path: 'purchases/:uid',
                          parentNavigatorKey: rootNavigatorKey,
                          builder: (_, state) => TicketPurchaseDetailPage(
                            uid: state.pathParameters['uid'] ?? '',
                            asEventOwner: true,
                          ),
                        ),
                        GoRoute(
                          name: RouteNames.salesByTicket,
                          path: 'tickets/:ticketId/sales',
                          parentNavigatorKey: rootNavigatorKey,
                          builder: (_, state) => SalesByTicketPage(
                            ticketId: state.pathParameters['ticketId'] ?? '',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
