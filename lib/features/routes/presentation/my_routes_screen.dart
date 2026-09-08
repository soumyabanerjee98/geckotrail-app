import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/providers/auth_provider.dart';
import '../../../shared/models/ride.dart';
import '../../../shared/widgets/async_body.dart';
import '../../../shared/theme/app_theme.dart';

final myRoutesProvider = FutureProvider.autoDispose<List<RouteAccess>>((ref) {
  return ref.watch(routeRepositoryProvider).myRoutes();
});

class MyRoutesScreen extends ConsumerWidget {
  const MyRoutesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(myRoutesProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('My Routes')),
      body: async.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(myRoutesProvider),
        ),
        data: (routes) {
          final active = routes.where((r) => r.isActive).toList();
          if (active.isEmpty) {
            return const EmptyView(
              title: 'No unlocked routes yet',
              subtitle:
                  'Join a hosted ride, attend the meetup, and wait for the host to complete the event.',
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(myRoutesProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: active.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final route = active[index];
                return ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.sand),
                  ),
                  title: Text(route.trailName),
                  subtitle: Text(
                    [
                      if (route.region != null) route.region!,
                      if (route.familiarityLevel != null)
                        'Familiarity: ${route.familiarityLevel}',
                      if (route.verifiedCompletionCount != null)
                        '${route.verifiedCompletionCount} verified',
                    ].join(' · '),
                  ),
                  trailing: const Icon(Icons.navigation),
                  onTap: () => context.push('/rides/${route.trailId}/navigate'),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
