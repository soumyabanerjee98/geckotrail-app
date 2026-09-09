import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../auth/providers/auth_provider.dart';
import '../../../shared/models/event.dart';
import '../../../shared/models/host.dart';
import '../../../shared/widgets/async_body.dart';
import '../../../shared/widgets/design_system.dart';
import '../../../shared/theme/app_theme.dart';
import 'become_host_screen.dart';

final hostEventsProvider =
    FutureProvider.autoDispose<List<HostedEvent>>((ref) {
  return ref.watch(eventRepositoryProvider).hostEvents();
});

class HostDashboardScreen extends ConsumerWidget {
  const HostDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    final hostAsync = ref.watch(myHostProfileProvider);
    final eventsAsync = ref.watch(hostEventsProvider);

    return TopoBackground(
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(hostEventsProvider);
            ref.invalidate(myHostProfileProvider);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                  ),
                  Expanded(
                    child: Text(
                      'Host Dashboard',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            fontSize: 26,
                          ),
                    ),
                  ),
                ],
              ),
              hostAsync.when(
                data: (profile) => _HostHeader(
                  name: profile?.displayName ?? user?.name ?? 'Host',
                  photoUrl: profile?.photoUrl ?? user?.photoUrl,
                  profile: profile,
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.forest,
                  borderRadius: BorderRadius.circular(AppRadii.card),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Planning a weekend escape?',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.forest,
                      ),
                      onPressed: () => context.push('/host/events/create'),
                      child: const Text('+ CREATE'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              hostAsync.when(
                data: (profile) => Row(
                  children: [
                    Expanded(
                      child: _MiniStat(
                        label: 'Rides led',
                        value: '${profile?.ridesLed ?? 0}',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _MiniStat(
                        label: 'Upcoming',
                        value: '${profile?.upcomingCount ?? 0}',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _MiniStat(
                        label: 'Riders led',
                        value: '${profile?.ridersLed ?? 0}',
                      ),
                    ),
                  ],
                ),
                loading: () => const LoadingView(),
                error: (_, _) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 20),
              const SectionHeader(title: 'Upcoming active rides'),
              const SizedBox(height: 10),
              eventsAsync.when(
                loading: () => const LoadingView(),
                error: (e, _) => ErrorView(
                  message: e.toString(),
                  onRetry: () => ref.invalidate(hostEventsProvider),
                ),
                data: (events) {
                  if (events.isEmpty) {
                    return EmptyView(
                      title: 'No hosted events yet',
                      subtitle: 'Create an event on a published trail.',
                      actionLabel: 'Create event',
                      onAction: () => context.push('/host/events/create'),
                    );
                  }
                  return Column(
                    children: events
                        .map(
                          (e) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _HostEventCard(event: e),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HostHeader extends StatelessWidget {
  const _HostHeader({
    required this.name,
    this.photoUrl,
    this.profile,
  });

  final String name;
  final String? photoUrl;
  final HostProfile? profile;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.forest,
          backgroundImage: photoUrl != null ? NetworkImage(photoUrl!) : null,
          child: photoUrl == null
              ? Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'H',
                  style: const TextStyle(color: Colors.white),
                )
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Verified Host',
                  style: TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.sand),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 20,
              color: AppColors.forest,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: AppColors.stone, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _HostEventCard extends StatelessWidget {
  const _HostEventCard({required this.event});
  final HostedEvent event;

  @override
  Widget build(BuildContext context) {
    final date = event.startDateTime != null
        ? DateFormat('MMM d').format(event.startDateTime!.toLocal())
        : 'TBA';
    final price = event.price != null ? '₹${event.price!.toStringAsFixed(0)}' : '';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.card),
        onTap: () => context.push('/host/events/${event.id}'),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.card),
            border: Border.all(color: AppColors.sand),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(event.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                '$date · ${event.trailName ?? 'Trail'}',
                style: const TextStyle(color: AppColors.stone),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    event.capacity != null
                        ? '${event.enrolledCount ?? 0}/${event.capacity} enrolled'
                        : event.status.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  Text(
                    price,
                    style: const TextStyle(
                      color: AppColors.ember,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
