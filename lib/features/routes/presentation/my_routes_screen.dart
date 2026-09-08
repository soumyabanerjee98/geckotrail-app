import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../auth/providers/auth_provider.dart';
import '../../../shared/models/ride.dart';
import '../../../shared/widgets/async_body.dart';
import '../../../shared/widgets/design_system.dart';
import '../../../shared/theme/app_theme.dart';

final myRoutesProvider = FutureProvider.autoDispose<List<RouteAccess>>((ref) {
  return ref.watch(routeRepositoryProvider).myRoutes();
});

class MyRoutesScreen extends ConsumerWidget {
  const MyRoutesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(myRoutesProvider);

    return TopoBackground(
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Unlocked Routes',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontSize: 28,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Access routes earned by completing community rides.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.stone,
                        ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: async.when(
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
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                      itemCount: active.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final route = active[index];
                        final completed = route.lastCompletedAt != null
                            ? 'Completed ${DateFormat('MMM d').format(route.lastCompletedAt!.toLocal())}'
                            : null;
                        final familiarity = route.familiarityLevel ?? 'Explorer';
                        final verified = route.verifiedCompletionCount ?? 0;
                        final progress = (verified / 5).clamp(0.15, 1.0);

                        return Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppRadii.card),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () => context
                                .push('/rides/${route.trailId}/navigate'),
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(AppRadii.card),
                                border: Border.all(color: AppColors.sand),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          (route.region ?? 'India').toUpperCase(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall,
                                        ),
                                      ),
                                      if (completed != null)
                                        Text(
                                          completed,
                                          style: const TextStyle(
                                            color: AppColors.stone,
                                            fontSize: 12,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    route.trailName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontSize: 20),
                                  ),
                                  const SizedBox(height: 6),
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text:
                                              '$verified verified ${verified == 1 ? 'ride' : 'rides'} — ',
                                          style: const TextStyle(
                                            color: AppColors.stone,
                                            fontSize: 13,
                                          ),
                                        ),
                                        TextSpan(
                                          text: familiarity,
                                          style: const TextStyle(
                                            color: AppColors.ember,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(999),
                                    child: LinearProgressIndicator(
                                      value: progress,
                                      minHeight: 6,
                                      backgroundColor: AppColors.sand,
                                      color: AppColors.forest,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Row(
                                    children: [
                                      const Spacer(),
                                      FilledButton.icon(
                                        style: FilledButton.styleFrom(
                                          backgroundColor: AppColors.forest,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              AppRadii.button,
                                            ),
                                          ),
                                        ),
                                        onPressed: () => context.push(
                                          '/rides/${route.trailId}/navigate',
                                        ),
                                        icon: const Icon(Icons.route, size: 18),
                                        label: const Text('Navigate'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
