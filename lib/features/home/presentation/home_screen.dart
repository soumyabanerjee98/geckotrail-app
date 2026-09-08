import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/providers/auth_provider.dart';
import '../../../shared/models/trail.dart';
import '../../../shared/models/event.dart';
import '../../../shared/widgets/trail_card.dart';
import '../../../shared/widgets/event_card.dart';
import '../../../shared/widgets/async_body.dart';
import '../../../shared/theme/app_theme.dart';

final homeFeaturedProvider = FutureProvider.autoDispose<List<TrailSummary>>((ref) {
  return ref.watch(trailRepositoryProvider).featured();
});

final homeEventsProvider = FutureProvider.autoDispose<List<HostedEvent>>((ref) {
  return ref.watch(eventRepositoryProvider).listEvents(status: 'OPEN');
});

final homeMyRidesProvider = FutureProvider.autoDispose<List<HostedEvent>>((ref) {
  return ref.watch(eventRepositoryProvider).myUpcoming();
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    final featured = ref.watch(homeFeaturedProvider);
    final events = ref.watch(homeEventsProvider);
    final myRides = ref.watch(homeMyRidesProvider);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gecko Trail',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (user != null)
                Text(
                  'Hey ${user.name.split(' ').first}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.stone,
                      ),
                ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () => context.push('/notifications'),
              icon: const Icon(Icons.notifications_outlined),
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          sliver: SliverList.list(
            children: [
              Text(
                'Discover curated trails and earn route access through hosted rides.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              _SectionTitle(
                title: 'Featured trails',
                onSeeAll: () => context.go('/trails'),
              ),
              const SizedBox(height: 12),
              _AsyncList(
                async: featured,
                onRetry: () => ref.invalidate(homeFeaturedProvider),
                empty: 'No featured trails yet',
                builder: (items) => Column(
                  children: items
                      .take(3)
                      .map(
                        (t) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: TrailCard(trail: t),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 16),
              _SectionTitle(
                title: 'Upcoming hosted events',
                onSeeAll: () => context.go('/events'),
              ),
              const SizedBox(height: 12),
              _AsyncList(
                async: events,
                onRetry: () => ref.invalidate(homeEventsProvider),
                empty: 'No events available',
                builder: (items) => Column(
                  children: items
                      .take(3)
                      .map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: EventCard(event: e),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 16),
              const _SectionTitle(title: 'My upcoming rides'),
              const SizedBox(height: 12),
              _AsyncList(
                async: myRides,
                onRetry: () => ref.invalidate(homeMyRidesProvider),
                empty: 'No upcoming rides yet',
                builder: (items) => Column(
                  children: items
                      .map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: EventCard(event: e),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.onSeeAll});
  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.headlineMedium),
        ),
        if (onSeeAll != null)
          TextButton(onPressed: onSeeAll, child: const Text('See all')),
      ],
    );
  }
}

class _AsyncList<T> extends StatelessWidget {
  const _AsyncList({
    required this.async,
    required this.builder,
    required this.onRetry,
    required this.empty,
  });

  final AsyncValue<List<T>> async;
  final Widget Function(List<T> items) builder;
  final VoidCallback onRetry;
  final String empty;

  @override
  Widget build(BuildContext context) {
    return async.when(
      data: (items) {
        if (items.isEmpty) {
          return EmptyView(title: empty);
        }
        return builder(items);
      },
      loading: () => const LoadingView(),
      error: (e, _) => ErrorView(message: e.toString(), onRetry: onRetry),
    );
  }
}
