import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../../../shared/models/event.dart';
import '../../../shared/widgets/event_card.dart';
import '../../../shared/widgets/async_body.dart';

final eventsListProvider =
    FutureProvider.autoDispose<List<HostedEvent>>((ref) {
  return ref.watch(eventRepositoryProvider).listEvents();
});

class EventsScreen extends ConsumerWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(eventsListProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Events')),
      body: async.when(
        data: (items) {
          if (items.isEmpty) {
            return const EmptyView(
              title: 'No events available',
              subtitle: 'Hosts publish rides against curated trails.',
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(eventsListProvider),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) => EventCard(event: items[index]),
            ),
          );
        },
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(eventsListProvider),
        ),
      ),
    );
  }
}
