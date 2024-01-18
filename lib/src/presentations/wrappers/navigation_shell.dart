import 'package:backtix_app/src/core/extensions/extensions.dart';
import 'package:backtix_app/src/presentations/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class NavigationShell extends StatelessWidget {
  const NavigationShell({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: const [],
      child: _NavigationShell(navigationShell: navigationShell),
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
            Flexible(child: navigationShell),
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
