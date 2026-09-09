import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../auth/providers/auth_provider.dart';
import '../../../shared/models/trail.dart';
import '../../../shared/models/event.dart';
import '../../../shared/widgets/trail_card.dart';
import '../../../shared/widgets/event_card.dart';
import '../../../shared/widgets/async_body.dart';
import '../../../shared/widgets/design_system.dart';
import '../../../shared/widgets/profile_avatar_hero.dart';
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

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';
    return 'Good evening,';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    final featured = ref.watch(homeFeaturedProvider);
    final events = ref.watch(homeEventsProvider);
    final myRides = ref.watch(homeMyRidesProvider);
    final firstName = user?.name.split(' ').first ?? 'Rider';

    return TopoBackground(
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              sliver: SliverList.list(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 4, right: 12),
                        child: GeckoMark(size: 44, circular: false),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _greeting(),
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppColors.stone,
                                  ),
                            ),
                            Text(
                              firstName,
                              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                    fontSize: 30,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      ProfileAvatarHero(
                        radius: 24,
                        photoUrl: user?.photoUrl,
                        initials: firstName,
                        onTap: () => context.go('/profile'),
                      ),
                      IconButton(
                        onPressed: () => context.push('/notifications'),
                        icon: const Icon(Icons.notifications_outlined),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    readOnly: true,
                    onTap: () => context.go('/trails'),
                    decoration: InputDecoration(
                      hintText: 'Search Spiti, Ghats, desert trails...',
                      prefixIcon: const Icon(Icons.search, color: AppColors.stone),
                      suffixIcon: IconButton(
                        onPressed: () => context.go('/trails'),
                        icon: const Icon(Icons.tune, color: AppColors.forest),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  SectionHeader(
                    title: 'Featured Trails',
                    actionLabel: 'View All',
                    onAction: () => context.go('/trails'),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 280,
                    child: featured.when(
                      data: (items) {
                        if (items.isEmpty) {
                          return const EmptyView(title: 'No featured trails yet');
                        }
                        return ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: items.length.clamp(0, 8),
                          separatorBuilder: (_, _) => const SizedBox(width: 12),
                          itemBuilder: (context, index) => TrailCard(
                            trail: items[index],
                            compact: true,
                          ),
                        );
                      },
                      loading: () => const LoadingView(),
                      error: (e, _) => ErrorView(
                        message: e.toString(),
                        onRetry: () => ref.invalidate(homeFeaturedProvider),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SectionHeader(
                    title: 'Hosted Group Rides',
                    actionLabel: 'View All',
                    onAction: () => context.go('/events'),
                  ),
                  const SizedBox(height: 12),
                  events.when(
                    data: (items) {
                      if (items.isEmpty) {
                        return const EmptyView(title: 'No events available');
                      }
                      return Column(
                        children: items
                            .take(3)
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
                    error: (e, _) => ErrorView(
                      message: e.toString(),
                      onRetry: () => ref.invalidate(homeEventsProvider),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const SectionHeader(title: 'My Upcoming Rides'),
                  const SizedBox(height: 12),
                  myRides.when(
                    data: (items) {
                      if (items.isEmpty) {
                        return const EmptyView(title: 'No upcoming rides yet');
                      }
                      return Column(
                        children: items
                            .map(
                              (e) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _UpcomingRideTile(event: e),
                              ),
                            )
                            .toList(),
                      );
                    },
                    loading: () => const LoadingView(),
                    error: (e, _) => ErrorView(
                      message: e.toString(),
                      onRetry: () => ref.invalidate(homeMyRidesProvider),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UpcomingRideTile extends StatelessWidget {
  const _UpcomingRideTile({required this.event});
  final HostedEvent event;

  @override
  Widget build(BuildContext context) {
    final start = event.startDateTime?.toLocal();
    final subtitle = start == null
        ? 'Date TBA'
        : 'Starts ${DateFormat('MMM d').format(start)} · ${DateFormat('EEE').format(start)}';

    return Material(
      color: AppColors.sand.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(AppRadii.chip),
      child: InkWell(
        onTap: () => context.push('/events/${event.id}'),
        borderRadius: BorderRadius.circular(AppRadii.chip),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.forest,
                child: Icon(Icons.two_wheeler, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.stone,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.stone),
            ],
          ),
        ),
      ),
    );
  }
}
