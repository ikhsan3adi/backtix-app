import 'dart:async';
import 'dart:convert';

import 'package:backtix_app/src/blocs/auth/auth_bloc.dart';
import 'package:backtix_app/src/blocs/events/published_events/published_events_bloc.dart';
import 'package:backtix_app/src/blocs/notifications/info_notifications_cubit.dart';
import 'package:backtix_app/src/blocs/notifications/notifications_cubit.dart';
import 'package:backtix_app/src/core/background_service.dart';
import 'package:backtix_app/src/core/local_notification.dart';
import 'package:backtix_app/src/data/models/event/event_query.dart';
import 'package:backtix_app/src/data/models/notification/notification_model.dart';
import 'package:backtix_app/src/presentations/extensions/extensions.dart';
import 'package:backtix_app/src/presentations/utils/utils.dart';
import 'package:backtix_app/src/presentations/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

class NavigationShell extends StatefulWidget {
  const NavigationShell({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  State<NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends State<NavigationShell> {
  StreamSubscription? subscription;

  @override
  void initState() async {
    super.initState();
    await BackgroundService.start();
  }

  @override
  void dispose() async {
    await subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthBloc>().user;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      subscription = LocalNotification.onResponse((response) {
        if (response.payload == null) return;
        try {
          NotificationHandler.onNotificationTap(
            context,
            NotificationModel.fromJson(jsonDecode(response.payload!)),
          );
        } catch (e) {
          debugPrint(e.toString());
        }
      });
    });

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => GetIt.I<PublishedEventsBloc>()
            ..add(
              PublishedEventsEvent.getPublishedEvents(
                const EventQuery(),
                isUserLocationSet: user?.isUserLocationSet,
                refreshNearbyEvents: true,
              ),
            ),
        ),
        BlocProvider<NotificationsCubit>(
          create: (_) {
            final cubit = GetIt.I<NotificationsCubit>()..getNotifications();
            if (!BackgroundService.supported) cubit.startRefreshing();
            return cubit;
          },
        ),
        BlocProvider<InfoNotificationsCubit>(
          create: (_) {
            final cubit = GetIt.I<InfoNotificationsCubit>()..getNotifications();
            if (!BackgroundService.supported) cubit.startRefreshing();
            return cubit;
          },
        ),
      ],
      child: _NavigationShell(navigationShell: widget.navigationShell),
    );
  }
}

class _NavigationShell extends StatelessWidget {
  const _NavigationShell({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: context.responsive(
        //
        // Mobile
        navigationShell,
        //
        // Tablet & Desktop
        md: Row(
          children: [
            HomeNavigationRail(
              currentIndex: navigationShell.currentIndex,
              onDestinationSelected: _goBranch,
            ),
            const VerticalDivider(width: 1, thickness: 1),
            Flexible(child: ResponsivePadding(child: navigationShell)),
          ],
        ),
      ),
      //
      // Mobile
      bottomNavigationBar: context.isMobile
          ? HomeNavigationBar(
              currentIndex: navigationShell.currentIndex,
              onDestinationSelected: _goBranch,
            )
          : null,
    );
  }
}
