import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/trail.dart';
import '../theme/app_theme.dart';

class TrailCard extends StatelessWidget {
  const TrailCard({super.key, required this.trail});

  final TrailSummary trail;

  String get _accessLabel {
    switch (trail.accessState) {
      case TrailAccessState.unlocked:
        return 'Unlocked';
      case TrailAccessState.upcomingEvent:
        return 'Upcoming event';
      case TrailAccessState.notUnlocked:
        return 'Not unlocked';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/trails/${trail.id}'),
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    trail.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                if (trail.ecoSensitive)
                  const Icon(Icons.eco, color: AppColors.moss, size: 18),
              ],
            ),
            const SizedBox(height: 4),
            Text(trail.region, style: const TextStyle(color: AppColors.stone)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                if (trail.distanceKm != null)
                  _Meta(label: '${trail.distanceKm!.toStringAsFixed(1)} km'),
                if (trail.difficulty != null)
                  _Meta(label: trail.difficulty!.name),
                if (trail.terrain != null) _Meta(label: trail.terrain!),
                _Meta(label: _accessLabel),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.forest,
            fontWeight: FontWeight.w600,
          ),
    );
  }
}
