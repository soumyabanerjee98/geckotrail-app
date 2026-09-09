import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/session_bootstrap_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/trails/presentation/trails_screen.dart';
import '../../features/trails/presentation/trail_details_screen.dart';
import '../../features/events/presentation/events_screen.dart';
import '../../features/events/presentation/event_details_screen.dart';
import '../../features/payments/presentation/checkout_screen.dart';
import '../../features/attendance/presentation/attendance_screen.dart';
import '../../features/routes/presentation/my_routes_screen.dart';
import '../../features/rides/presentation/navigation_screen.dart';
import '../../features/rides/presentation/ride_summary_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/profile/presentation/edit_profile_screen.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/host/presentation/host_dashboard_screen.dart';
import '../../features/host/presentation/create_event_screen.dart';
import '../../features/host/presentation/host_event_details_screen.dart';
import '../../features/host/presentation/become_host_screen.dart';
import '../../features/admin/presentation/admin_dashboard_screen.dart';
import '../../features/admin/presentation/admin_host_approvals_screen.dart';
import '../../features/admin/presentation/admin_trails_screen.dart';
import '../../features/admin/presentation/admin_regions_screen.dart';
import '../../features/admin/presentation/admin_events_screen.dart';
import '../../features/shell/main_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerRefreshProvider = Provider<RouterRefreshNotifier>((ref) {
  final notifier = RouterRefreshNotifier();
  ref.listen<AuthState>(authControllerProvider, (_, _) {
    notifier.refresh();
  });
  ref.onDispose(notifier.dispose);
  return notifier;
});

class RouterRefreshNotifier extends ChangeNotifier {
  void refresh() => notifyListeners();
}

final goRouterProvider = Provider<GoRouter>((ref) {
  // routerRefreshProvider already listens to auth and starts restoreSession().
  final refresh = ref.watch(routerRefreshProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final loc = state.matchedLocation;
      final onSplash = loc == '/splash';
      final loggingIn = loc.startsWith('/auth');

      // Hold on bootstrap until tokens are hydrated and /users/me finishes.
      if (auth.status == AuthStatus.unknown) {
        return onSplash ? null : '/splash';
      }

      if (auth.status == AuthStatus.unauthenticated) {
        if (loggingIn) return null;
        return '/auth/login';
      }

      // Authenticated: leave splash / auth screens.
      if (onSplash || loggingIn) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SessionBootstrapScreen(),
      ),
      GoRoute(
        path: '/auth/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/auth/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
          GoRoute(path: '/trails', builder: (context, state) => const TrailsScreen()),
          GoRoute(path: '/events', builder: (context, state) => const EventsScreen()),
          GoRoute(
            path: '/my-routes',
            builder: (context, state) => const MyRoutesScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/trails/:trailId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => TrailDetailsScreen(
          trailId: state.pathParameters['trailId']!,
        ),
      ),
      GoRoute(
        path: '/events/:eventId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => EventDetailsScreen(
          eventId: state.pathParameters['eventId']!,
        ),
      ),
      GoRoute(
        path: '/events/:eventId/checkout',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => CheckoutScreen(
          eventId: state.pathParameters['eventId']!,
        ),
      ),
      GoRoute(
        path: '/events/:eventId/attendance',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => AttendanceScreen(
          eventId: state.pathParameters['eventId']!,
        ),
      ),
      GoRoute(
        path: '/rides/:trailId/navigate',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => NavigationScreen(
          trailId: state.pathParameters['trailId']!,
        ),
      ),
      GoRoute(
        path: '/rides/summary',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return RideSummaryScreen(
            verified: extra['verified'] == true,
            message: extra['message']?.toString(),
            familiarityLevel: extra['familiarityLevel']?.toString(),
          );
        },
      ),
      GoRoute(
        path: '/notifications',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/profile/edit',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/host/apply',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const BecomeHostScreen(),
      ),
      GoRoute(
        path: '/host',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const HostDashboardScreen(),
      ),
      GoRoute(
        path: '/host/events/create',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CreateEventScreen(),
      ),
      GoRoute(
        path: '/host/events/:eventId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => HostEventDetailsScreen(
          eventId: state.pathParameters['eventId']!,
        ),
      ),
      ShellRoute(
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state, child) => AdminShell(
          location: state.matchedLocation,
          child: child,
        ),
        routes: [
          GoRoute(
            path: '/admin',
            builder: (context, state) => const AdminDashboardScreen(),
          ),
          GoRoute(
            path: '/admin/hosts',
            builder: (context, state) => const AdminHostApprovalsScreen(),
          ),
          GoRoute(
            path: '/admin/trails',
            builder: (context, state) => const AdminTrailsScreen(),
          ),
          GoRoute(
            path: '/admin/regions',
            builder: (context, state) => const AdminRegionsScreen(),
          ),
          GoRoute(
            path: '/admin/events',
            builder: (context, state) => const AdminEventsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/admin/trails/create',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AdminUploadTrailScreen(),
      ),
      GoRoute(
        path: '/admin/regions/create',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AdminUploadRegionScreen(),
      ),
    ],
  );
});
