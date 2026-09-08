import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../auth/providers/auth_provider.dart';
import '../../../shared/models/event.dart';
import '../../../shared/widgets/async_body.dart';
import '../../../shared/theme/app_theme.dart';

final eventDetailsProvider =
    FutureProvider.autoDispose.family<HostedEvent, String>((ref, id) {
  return ref.watch(eventRepositoryProvider).getEvent(id);
});

class EventDetailsScreen extends ConsumerWidget {
  const EventDetailsScreen({super.key, required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(eventDetailsProvider(eventId));

    return Scaffold(
      appBar: AppBar(title: const Text('Event details')),
      body: async.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(eventDetailsProvider(eventId)),
        ),
        data: (event) {
          final date = event.startDateTime != null
              ? DateFormat('EEEE, d MMM yyyy · HH:mm')
                  .format(event.startDateTime!.toLocal())
              : 'Date TBA';
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(event.title, style: Theme.of(context).textTheme.displayMedium),
              const SizedBox(height: 8),
              Text(event.trailName ?? 'Trail', style: const TextStyle(color: AppColors.stone)),
              const SizedBox(height: 16),
              Text(date),
              Text('Host: ${event.hostName ?? 'Host'}'),
              if (event.capacity != null)
                Text(
                  event.isFull
                      ? 'Event full'
                      : '${event.spotsLeft ?? event.capacity} spots available',
                ),
              if (event.price != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '${event.currency} ${event.price!.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.clay,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              const Text(
                'Payment covers participation in this hosted ride. Route access is granted only after verified attendance and host event completion — not as a GPX purchase.',
              ),
              if (event.description != null) ...[
                const SizedBox(height: 16),
                Text(event.description!),
              ],
              if (event.requirements != null) ...[
                const SizedBox(height: 16),
                Text('Requirements', style: Theme.of(context).textTheme.titleLarge),
                Text(event.requirements!),
              ],
              if (event.safetyInstructions != null) ...[
                const SizedBox(height: 16),
                Text('Safety', style: Theme.of(context).textTheme.titleLarge),
                Text(event.safetyInstructions!),
              ],
              if (event.environmentalInstructions != null) ...[
                const SizedBox(height: 16),
                Text('Environment', style: Theme.of(context).textTheme.titleLarge),
                Text(event.environmentalInstructions!),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: event.isFull
                    ? null
                    : () => context.push('/events/$eventId/checkout'),
                child: Text(event.isFull ? 'Event full' : 'Enrol & pay'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => context.push('/events/$eventId/attendance'),
                child: const Text('Mark attendance'),
              ),
            ],
          );
        },
      ),
    );
  }
}
