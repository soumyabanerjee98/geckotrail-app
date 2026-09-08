import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/providers/auth_provider.dart';
import '../../../shared/models/trail.dart';
import '../../../shared/models/event.dart';
import '../../../shared/widgets/async_body.dart';
import '../../../shared/widgets/design_system.dart';
import '../../../shared/theme/app_theme.dart';

final trailDetailsProvider =
    FutureProvider.autoDispose.family<TrailDetails, String>((ref, id) {
  return ref.watch(trailRepositoryProvider).getTrail(id);
});

final trailEventsProvider =
    FutureProvider.autoDispose.family<List<HostedEvent>, String>((ref, id) {
  return ref.watch(trailRepositoryProvider).trailEvents(id);
});

class TrailDetailsScreen extends ConsumerWidget {
  const TrailDetailsScreen({super.key, required this.trailId});

  final String trailId;

  String? _durationLabel(TrailDetails trail) {
    final minutes = trail.estimatedDurationMinutes;
    if (minutes == null) return null;
    if (minutes >= 1440) {
      final days = (minutes / 1440).round();
      return '$days ${days == 1 ? 'Day' : 'Days'}';
    }
    return '$minutes min';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trailAsync = ref.watch(trailDetailsProvider(trailId));

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: trailAsync.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(trailDetailsProvider(trailId)),
        ),
        data: (trail) {
          final unlocked = trail.accessState == TrailAccessState.unlocked;
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: AppColors.forest,
                leading: IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                ),
                actions: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.ios_share, color: Colors.white),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (trail.coverImageUrl != null)
                        Image.network(
                          trail.coverImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) =>
                              const ColoredBox(color: AppColors.forest),
                        )
                      else
                        const ColoredBox(color: AppColors.forest),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.black38, Colors.black54],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 20,
                        right: 20,
                        bottom: 24,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.place,
                                  color: AppColors.ember,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  trail.region.toUpperCase(),
                                  style: const TextStyle(
                                    color: AppColors.ember,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                    fontSize: 12,
                                  ),
                                ),
                                const Spacer(),
                                if (trail.difficulty != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      trail.difficulty!.name.toUpperCase(),
                                      style: const TextStyle(
                                        color: AppColors.ember,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              trail.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .displayMedium
                                  ?.copyWith(color: Colors.white, fontSize: 28),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    children: [
                      _Stat(
                        label: 'Distance',
                        value: trail.distanceKm != null
                            ? '${trail.distanceKm!.toStringAsFixed(0)} km'
                            : '—',
                      ),
                      _Stat(
                        label: 'Duration',
                        value: _durationLabel(trail) ?? '—',
                      ),
                      _Stat(
                        label: 'Peak elevation',
                        value: trail.elevationGainM != null
                            ? '${trail.elevationGainM!.toStringAsFixed(0)} m'
                            : '—',
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                sliver: SliverList.list(
                  children: [
                    const UpperLabel('Trail overview'),
                    const SizedBox(height: 8),
                    Text(
                      trail.description ??
                          'Curated expedition trail. Join a hosted ride to unlock route coordinates.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            height: 1.45,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _InfoTile(
                            label: 'Terrain type',
                            value: trail.terrain ?? 'Mixed terrain',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _InfoTile(
                            label: 'Best season',
                            value: trail.bestSeason ?? 'Check with host',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (unlocked) ...[
                      if (trail.familiarityLevel != null)
                        Text(
                          'Familiarity: ${trail.familiarityLevel}'
                          '${trail.verifiedCompletionCount != null ? ' · ${trail.verifiedCompletionCount} verified rides' : ''}',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () =>
                            context.push('/rides/$trailId/navigate'),
                        icon: const Icon(Icons.route),
                        label: const Text('Navigate route'),
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.ember.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.ember.withValues(alpha: 0.45),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.lock, color: AppColors.ember),
                                SizedBox(width: 8),
                                Text(
                                  'Route Coordinates Locked',
                                  style: TextStyle(fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'To protect eco-sensitive zones and guarantee rider safety, join a community-hosted ride to unlock GPX coordinates.',
                            ),
                            const SizedBox(height: 10),
                            TextButton(
                              onPressed: () => context.go('/events'),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('View Hosted Rides to Unlock'),
                                  SizedBox(width: 4),
                                  Icon(Icons.arrow_forward, size: 16),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          UpperLabel(label),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.forest,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.sand),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UpperLabel(label),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
