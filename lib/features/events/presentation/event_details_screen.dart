import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../auth/providers/auth_provider.dart';
import '../../../shared/models/event.dart';
import '../../../shared/widgets/async_body.dart';
import '../../../shared/widgets/design_system.dart';
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
      body: TopoBackground(
        child: async.when(
          loading: () => const LoadingView(),
          error: (e, _) => ErrorView(
            message: e.toString(),
            onRetry: () => ref.invalidate(eventDetailsProvider(eventId)),
          ),
          data: (event) {
            final start = event.startDateTime?.toLocal();
            final end = event.endDateTime?.toLocal();
            final dateLabel = start == null
                ? 'Date TBA'
                : end == null
                    ? DateFormat('MMM d, yyyy · h:mm a').format(start)
                    : '${DateFormat('MMM d').format(start)} - ${DateFormat('MMM d, yyyy').format(end)} (Starts ${DateFormat('h:mm a').format(start)})';
            final price = event.price != null
                ? '₹${event.price!.toStringAsFixed(0)}'
                : null;
            final requirements = (event.requirements ?? '')
                .split(RegExp(r'[\n•|]'))
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList();

            return Column(
              children: [
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 16, 8),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => context.pop(),
                          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                        ),
                        Text(
                          'Group Ride Details',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppRadii.card),
                          border: Border.all(color: AppColors.sand),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.ember.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'CURATED EXPEDITION',
                                    style: TextStyle(
                                      color: AppColors.ember,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 10,
                                      letterSpacing: 0.6,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  event.isFull
                                      ? 'Full'
                                      : event.spotsLeft != null
                                          ? '${event.spotsLeft} spots left'
                                          : '',
                                  style: const TextStyle(
                                    color: AppColors.stone,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              event.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .displayMedium
                                  ?.copyWith(fontSize: 26),
                            ),
                            const SizedBox(height: 14),
                            const Divider(height: 1),
                            const SizedBox(height: 14),
                            _IconRow(
                              icon: Icons.calendar_today_outlined,
                              text: dateLabel,
                            ),
                            const SizedBox(height: 10),
                            _IconRow(
                              icon: Icons.place_outlined,
                              text: event.trailName != null
                                  ? 'Meetup near ${event.trailName}'
                                  : 'Meetup details shared after enrolment',
                            ),
                            if (price != null) ...[
                              const SizedBox(height: 10),
                              _IconRow(
                                icon: Icons.currency_rupee,
                                text: '$price / Rider',
                                emphasize: price,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.sand.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: AppColors.forest,
                              backgroundImage: event.hostPhotoUrl != null
                                  ? NetworkImage(event.hostPhotoUrl!)
                                  : null,
                              child: event.hostPhotoUrl == null
                                  ? const Icon(Icons.person, color: Colors.white)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        event.hostName ?? 'Host',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Icon(
                                        Icons.verified,
                                        color: AppColors.success,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                  Text(
                                    'Community host · ${event.trailName ?? 'Trail ride'}',
                                    style: const TextStyle(
                                      color: AppColors.stone,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (requirements.isNotEmpty ||
                          event.description != null) ...[
                        const SizedBox(height: 22),
                        const UpperLabel('Ride requirements'),
                        const SizedBox(height: 10),
                        if (requirements.isNotEmpty)
                          ...requirements.map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(top: 7),
                                    child: Icon(
                                      Icons.circle,
                                      size: 7,
                                      color: AppColors.ember,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(child: Text(item)),
                                ],
                              ),
                            ),
                          )
                        else if (event.description != null)
                          Text(event.description!),
                      ],
                    ],
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                    child: Column(
                      children: [
                        ElevatedButton(
                          onPressed: event.isFull
                              ? null
                              : () =>
                                  context.push('/events/$eventId/checkout'),
                          child: Text(
                            event.isFull
                                ? 'Event full'
                                : price != null
                                    ? 'Enroll Now — $price'
                                    : 'Enrol & pay',
                          ),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: () =>
                              context.push('/events/$eventId/attendance'),
                          child: const Text('Mark attendance'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _IconRow extends StatelessWidget {
  const _IconRow({
    required this.icon,
    required this.text,
    this.emphasize,
  });

  final IconData icon;
  final String text;
  final String? emphasize;

  @override
  Widget build(BuildContext context) {
    if (emphasize != null && text.contains(emphasize!)) {
      final parts = text.split(emphasize!);
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.stone),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: parts.first),
                  TextSpan(
                    text: emphasize,
                    style: const TextStyle(
                      color: AppColors.ember,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (parts.length > 1) TextSpan(text: parts.sublist(1).join()),
                ],
              ),
            ),
          ),
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.stone),
        const SizedBox(width: 10),
        Expanded(child: Text(text)),
      ],
    );
  }
}
