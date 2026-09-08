import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/trail.dart';
import '../theme/app_theme.dart';
import 'design_system.dart';

class TrailCard extends StatelessWidget {
  const TrailCard({
    super.key,
    required this.trail,
    this.compact = false,
  });

  final TrailSummary trail;
  final bool compact;

  AccessBadgeTone get _tone {
    switch (trail.accessState) {
      case TrailAccessState.unlocked:
        return AccessBadgeTone.unlocked;
      case TrailAccessState.upcomingEvent:
        return AccessBadgeTone.groupRequired;
      case TrailAccessState.notUnlocked:
        return AccessBadgeTone.locked;
    }
  }

  String get _accessLabel {
    switch (trail.accessState) {
      case TrailAccessState.unlocked:
        return 'Unlocked';
      case TrailAccessState.upcomingEvent:
        return 'Group required';
      case TrailAccessState.notUnlocked:
        return 'Locked';
    }
  }

  String? get _durationLabel {
    final minutes = trail.estimatedDurationMinutes;
    if (minutes == null) return null;
    if (minutes >= 1440) {
      final days = (minutes / 1440).round();
      return '$days ${days == 1 ? 'day' : 'days'}';
    }
    if (minutes >= 60) {
      final hours = (minutes / 60).round();
      return '$hours ${hours == 1 ? 'hr' : 'hrs'}';
    }
    return '$minutes min';
  }

  @override
  Widget build(BuildContext context) {
    final width = compact ? 260.0 : double.infinity;
    return SizedBox(
      width: width,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.card),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push('/trails/${trail.id}'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: compact ? 16 / 10 : 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _Cover(url: trail.coverImageUrl),
                    if (trail.ecoSensitive)
                      const Positioned(
                        top: 12,
                        left: 12,
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.forest,
                          child: Icon(Icons.eco, color: Colors.white, size: 16),
                        ),
                      ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: AccessBadge(label: _accessLabel, tone: _tone),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            trail.region.toUpperCase(),
                            style: Theme.of(context).textTheme.labelSmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (trail.difficulty != null)
                          DifficultyBadge(trail.difficulty!.name),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      trail.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: compact ? 17 : 19,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    const Divider(height: 1),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 14,
                      runSpacing: 6,
                      children: [
                        if (trail.distanceKm != null)
                          _MetaIcon(
                            icon: Icons.place_outlined,
                            text: '${trail.distanceKm!.toStringAsFixed(0)} km',
                          ),
                        if (_durationLabel != null)
                          _MetaIcon(
                            icon: Icons.schedule,
                            text: _durationLabel!,
                          ),
                        if (trail.terrain != null)
                          _MetaIcon(
                            icon: Icons.terrain,
                            text: trail.terrain!,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Cover extends StatelessWidget {
  const _Cover({this.url});
  final String? url;

  @override
  Widget build(BuildContext context) {
    if (url != null && url!.isNotEmpty) {
      return Image.network(
        url!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const _CoverFallback(),
      );
    }
    return const _CoverFallback();
  }
}

class _CoverFallback extends StatelessWidget {
  const _CoverFallback();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.forest,
      child: Center(
        child: Icon(Icons.terrain, color: Colors.white54, size: 40),
      ),
    );
  }
}

class _MetaIcon extends StatelessWidget {
  const _MetaIcon({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.stone),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.stone,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
