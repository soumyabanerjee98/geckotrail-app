import 'dart:io';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Shared hero tag for home header ↔ profile avatar transitions.
const kProfileAvatarHeroTag = 'gecko-profile-avatar';

class ProfileAvatarHero extends StatelessWidget {
  const ProfileAvatarHero({
    super.key,
    required this.radius,
    this.photoUrl,
    this.localFile,
    this.initials = 'R',
    this.onTap,
    this.showBorder = false,
    this.heroTag = kProfileAvatarHeroTag,
    this.enableHero = true,
  });

  final double radius;
  final String? photoUrl;
  final File? localFile;
  final String initials;
  final VoidCallback? onTap;
  final bool showBorder;
  final Object heroTag;
  final bool enableHero;

  @override
  Widget build(BuildContext context) {
    final letter = initials.isNotEmpty ? initials[0].toUpperCase() : 'R';
    ImageProvider? image;
    if (localFile != null) {
      image = FileImage(localFile!);
    } else if (photoUrl != null && photoUrl!.isNotEmpty) {
      image = NetworkImage(photoUrl!);
    }

    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.forest,
      backgroundImage: image,
      child: image == null
          ? Text(
              letter,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: radius * 0.75,
              ),
            )
          : null,
    );

    final framed = showBorder
        ? Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.ember, width: 2),
            ),
            child: avatar,
          )
        : avatar;

    final tappable = Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: framed,
      ),
    );

    if (!enableHero) return tappable;
    return Hero(tag: heroTag, child: tappable);
  }
}
