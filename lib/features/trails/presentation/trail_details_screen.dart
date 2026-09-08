import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/providers/auth_provider.dart';
import '../../../shared/models/trail.dart';
import '../../../shared/models/event.dart';
import '../../../shared/widgets/event_card.dart';
import '../../../shared/widgets/async_body.dart';
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trailAsync = ref.watch(trailDetailsProvider(trailId));
    final eventsAsync = ref.watch(trailEventsProvider(trailId));

    return Scaffold(
      appBar: AppBar(title: const Text('Trail details')),
      body: trailAsync.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(trailDetailsProvider(trailId)),
        ),
        data: (trail) {
          final unlocked = trail.accessState == TrailAccessState.unlocked;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(trail.name, style: Theme.of(context).textTheme.displayMedium),
              const SizedBox(height: 4),
              Text(trail.region, style: const TextStyle(color: AppColors.stone)),
              if (trail.ecoSensitive) ...[
                const SizedBox(height: 12),
                const Text(
                  'Eco-sensitive trail\nAdditional recommendation requirements apply.',
                  style: TextStyle(color: AppColors.moss),
                ),
                if (trail.eligibilityLabel != null)
                  Text(
                    trail.eligibilityLabel!,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
              ],
              const SizedBox(height: 16),
              if (trail.description != null) Text(trail.description!),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  if (trail.distanceKm != null)
                    _Fact(label: 'Distance', value: '${trail.distanceKm} km'),
                  if (trail.estimatedDurationMinutes != null)
                    _Fact(
                      label: 'Duration',
                      value: '${trail.estimatedDurationMinutes} min',
                    ),
                  if (trail.elevationGainM != null)
                    _Fact(
                      label: 'Elevation',
                      value: '${trail.elevationGainM!.toStringAsFixed(0)} m',
                    ),
                  if (trail.difficulty != null)
                    _Fact(label: 'Difficulty', value: trail.difficulty!.name),
                  if (trail.terrain != null)
                    _Fact(label: 'Terrain', value: trail.terrain!),
                  if (trail.bestSeason != null)
                    _Fact(label: 'Best season', value: trail.bestSeason!),
                ],
              ),
              if (trail.safetyInformation != null) ...[
                const SizedBox(height: 16),
                Text('Safety', style: Theme.of(context).textTheme.titleLarge),
                Text(trail.safetyInformation!),
              ],
              if (trail.environmentalInformation != null) ...[
                const SizedBox(height: 16),
                Text(
                  'Environment',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(trail.environmentalInformation!),
              ],
              const SizedBox(height: 24),
              if (unlocked) ...[
                if (trail.familiarityLevel != null)
                  Text(
                    'Familiarity: ${trail.familiarityLevel}'
                    '${trail.verifiedCompletionCount != null ? ' · ${trail.verifiedCompletionCount} verified rides' : ''}',
                  ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => context.push('/rides/$trailId/navigate'),
                  icon: const Icon(Icons.navigation),
                  label: const Text('Navigate route'),
                ),
              ] else ...[
                Text(
                  'Route access is earned through participation in a hosted event — not by buying a GPX.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 12),
                Text(
                  'Upcoming hosted events',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                eventsAsync.when(
                  data: (events) {
                    if (events.isEmpty) {
                      return const EmptyView(title: 'No events available');
                    }
                    return Column(
                      children: events
                          .map(
                            (e) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: EventCard(event: e),
                            ),
                          )
                          .toList(),
                    );
                  },
                  loading: () => const LoadingView(),
                  error: (e, _) => ErrorView(message: e.toString()),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.stone, fontSize: 12)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
