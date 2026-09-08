import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Cream canvas with faint topographic motif (light discovery screens).
class TopoBackground extends StatelessWidget {
  const TopoBackground({
    super.key,
    required this.child,
    this.dark = false,
  });

  final Widget child;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: dark ? AppColors.night : AppColors.cream,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (!dark)
            Opacity(
              opacity: 0.35,
              child: Image.asset(
                'assets/brand/topo-motif.png',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
          child,
        ],
      ),
    );
  }
}

class GeckoMark extends StatelessWidget {
  const GeckoMark({
    super.key,
    this.size = 72,
    this.circular = true,
  });

  final double size;
  final bool circular;

  static const assetPath = 'assets/brand/app_icon.png';

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      assetPath,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => Container(
        width: size,
        height: size,
        color: AppColors.forest,
        alignment: Alignment.center,
        child: Icon(Icons.pets, color: Colors.white, size: size * 0.45),
      ),
    );

    if (!circular) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.22),
        child: image,
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.forest.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(child: image),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.lightOnDark = false,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool lightOnDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: lightOnDark ? Colors.white : AppColors.ink,
                  fontSize: 20,
                ),
          ),
        ),
        if (actionLabel != null && onAction != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.ember,
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}

class UpperLabel extends StatelessWidget {
  const UpperLabel(this.text, {super.key, this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: color ?? AppColors.stone,
          ),
    );
  }
}

class DifficultyBadge extends StatelessWidget {
  const DifficultyBadge(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final upper = label.toUpperCase();
    final hard = upper.contains('HARD') || upper.contains('EXPERT');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: hard ? AppColors.hardBg : AppColors.moderateBg,
        borderRadius: BorderRadius.circular(AppRadii.chip),
      ),
      child: Text(
        upper,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: hard ? AppColors.hardFg : AppColors.moderateFg,
        ),
      ),
    );
  }
}

class AccessBadge extends StatelessWidget {
  const AccessBadge({super.key, required this.label, required this.tone});

  final String label;
  final AccessBadgeTone tone;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    switch (tone) {
      case AccessBadgeTone.unlocked:
        bg = AppColors.success;
        fg = Colors.white;
      case AccessBadgeTone.groupRequired:
        bg = AppColors.ember;
        fg = Colors.white;
      case AccessBadgeTone.locked:
        bg = AppColors.locked;
        fg = Colors.white;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: fg,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

enum AccessBadgeTone { unlocked, groupRequired, locked }

class FilterChipPill extends StatelessWidget {
  const FilterChipPill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.forest : Colors.white,
      borderRadius: BorderRadius.circular(AppRadii.chip),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.chip),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.chip),
            border: Border.all(
              color: selected ? AppColors.forest : AppColors.sand,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.ink,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
