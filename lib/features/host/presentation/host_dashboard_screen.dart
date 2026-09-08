import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/providers/auth_provider.dart';
import '../../../shared/models/event.dart';
import '../../../shared/widgets/async_body.dart';
import '../../../shared/theme/app_theme.dart';

final hostEventsProvider =
    FutureProvider.autoDispose<List<HostedEvent>>((ref) {
  return ref.watch(eventRepositoryProvider).hostEvents();
});

class HostDashboardScreen extends ConsumerWidget {
  const HostDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(hostEventsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Host dashboard'),
        actions: [
          IconButton(
            onPressed: () => context.push('/host/events/create'),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: async.when(
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
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: events.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final event = events[index];
              return ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.sand),
                ),
                title: Text(event.title),
                subtitle: Text('${event.trailName ?? 'Trail'} · ${event.status.name}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/host/events/${event.id}'),
              );
            },
          );
        },
      ),
    );
  }
}
