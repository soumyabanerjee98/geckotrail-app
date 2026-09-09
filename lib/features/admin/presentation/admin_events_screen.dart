import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../auth/providers/auth_provider.dart';
import '../../../shared/models/event.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/async_body.dart';

final adminEventsProvider = FutureProvider.autoDispose<List<HostedEvent>>((ref) {
  return ref.watch(eventRepositoryProvider).listEvents();
});

class AdminEventsScreen extends ConsumerWidget {
  const AdminEventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(adminEventsProvider);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async => ref.invalidate(adminEventsProvider),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => context.go('/admin'),
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                ),
                Expanded(
                  child: Text(
                    'Manage Group Rides',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontSize: 26,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Platform-wide hosted expeditions (read/manage via event APIs).',
              style: TextStyle(color: AppColors.stone),
            ),
            const SizedBox(height: 16),
            eventsAsync.when(
              loading: () => const LoadingView(),
              error: (e, _) => ErrorView(
                message: e.toString(),
                onRetry: () => ref.invalidate(adminEventsProvider),
              ),
              data: (events) {
                if (events.isEmpty) {
                  return const EmptyView(title: 'No group rides yet');
                }
                return Column(
                  children: events
                      .map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(AppRadii.card),
                              border: Border.all(color: AppColors.sand),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(e.title, style: Theme.of(context).textTheme.titleLarge),
                                const SizedBox(height: 4),
                                Text(
                                  [
                                    if (e.startDateTime != null)
                                      DateFormat('MMM d, y').format(e.startDateTime!.toLocal()),
                                    e.trailName ?? 'Trail',
                                    e.status.name,
                                  ].join(' · '),
                                  style: const TextStyle(color: AppColors.stone),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  e.capacity != null
                                      ? '${e.enrolledCount ?? 0}/${e.capacity} enrolled'
                                      : '${e.enrolledCount ?? 0} enrolled',
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
