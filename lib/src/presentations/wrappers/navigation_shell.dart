import 'package:backtix_app/src/blocs/auth/auth_bloc.dart';
import 'package:backtix_app/src/blocs/events/published_events/published_events_bloc.dart';
import 'package:backtix_app/src/core/extensions/extensions.dart';
import 'package:backtix_app/src/data/models/event/event_query.dart';
import 'package:backtix_app/src/data/models/user/user_model.dart';
import 'package:backtix_app/src/presentations/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

class NavigationShell extends StatelessWidget {
  const NavigationShell({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthBloc>().state.mapOrNull(
          authenticated: (s) => s.user,
        );

    return RepositoryProvider<UserModel>(
      create: (_) => user ?? UserModel.dummyUser,
      child: MultiBlocProvider(
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
        ],
        child: _NavigationShell(navigationShell: navigationShell),
      ),
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
