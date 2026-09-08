import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../models/event.dart';
import '../theme/app_theme.dart';

class EventCard extends StatelessWidget {
  const EventCard({super.key, required this.event});

  final HostedEvent event;

  @override
  Widget build(BuildContext context) {
    final date = event.startDateTime != null
        ? DateFormat('EEE, d MMM · HH:mm').format(event.startDateTime!.toLocal())
        : 'Date TBA';
    final price = event.price != null
        ? '${event.currency} ${event.price!.toStringAsFixed(0)}'
        : 'Price TBA';

    return InkWell(
      onTap: () => context.push('/events/${event.id}'),
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.sand),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(event.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              event.trailName ?? 'Trail',
              style: const TextStyle(color: AppColors.stone),
            ),
            const SizedBox(height: 8),
            Text(date),
            const SizedBox(height: 4),
            Text('Hosted by ${event.hostName ?? 'Host'}'),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  price,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.clay,
                  ),
                ),
                const Spacer(),
                Text(
                  event.isFull
                      ? 'Full'
                      : event.spotsLeft != null
                          ? '${event.spotsLeft} spots'
                          : event.status.name,
                  style: TextStyle(
                    color: event.isFull ? AppColors.danger : AppColors.forest,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
