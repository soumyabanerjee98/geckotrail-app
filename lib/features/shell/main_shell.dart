import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/theme/app_theme.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  int _indexForLocation(String location) {
    if (location.startsWith('/trails')) return 1;
    if (location.startsWith('/events')) return 2;
    if (location.startsWith('/my-routes')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final index = _indexForLocation(location);
    final darkTabs = location.startsWith('/my-routes') ||
        location.startsWith('/profile');

    return Scaffold(
      body: child,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: AppColors.sand.withValues(alpha: 0.8)),
          ),
        ),
        child: NavigationBar(
          selectedIndex: index,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          onDestinationSelected: (value) {
            switch (value) {
              case 0:
                context.go('/home');
              case 1:
                context.go('/trails');
              case 2:
                context.go('/events');
              case 3:
                context.go('/my-routes');
              case 4:
                context.go('/profile');
            }
          },
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            const NavigationDestination(
              icon: Icon(Icons.location_on_outlined),
              selectedIcon: Icon(Icons.location_on),
              label: 'Trails',
            ),
            const NavigationDestination(
              icon: Icon(Icons.calendar_today_outlined),
              selectedIcon: Icon(Icons.calendar_today),
              label: 'Events',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.verified_user_outlined,
                color: darkTabs ? AppColors.stone : null,
              ),
              selectedIcon: const Icon(Icons.verified_user),
              label: 'My Routes',
            ),
            const NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
