import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/providers/auth_provider.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/design_system.dart';
import '../../../shared/widgets/profile_avatar_hero.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final user = auth.user;
    final name = user?.name.isNotEmpty == true ? user!.name : 'Rider';

    return TopoBackground(
      child: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () => ref.read(authControllerProvider.notifier).refreshUser(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Rider Profile',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            fontSize: 28,
                          ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => context.push('/profile/edit'),
                    tooltip: 'Edit profile',
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  IconButton(
                    onPressed: () => context.push('/notifications'),
                    icon: const Icon(Icons.notifications_outlined),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Your rider identity, unlocked routes, and host tools.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.stone,
                    ),
              ),
              const SizedBox(height: 16),
              if (user == null)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: CircularProgressIndicator()),
                )
              else ...[
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadii.card),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppRadii.card),
                    onTap: () => context.push('/profile/edit'),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadii.card),
                        border: Border.all(color: AppColors.sand),
                      ),
                      child: Row(
                        children: [
                          ProfileAvatarHero(
                            radius: 36,
                            photoUrl: user.photoUrl,
                            initials: name,
                            showBorder: true,
                            onTap: () => context.push('/profile/edit'),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(fontSize: 20),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user.bio?.isNotEmpty == true
                                      ? user.bio!
                                      : user.email,
                                  style: const TextStyle(
                                    color: AppColors.stone,
                                    fontSize: 13,
                                  ),
                                ),
                                if (user.ridingExperience != null) ...[
                                  const SizedBox(height: 8),
                                  const UpperLabel('Riding since'),
                                  Text(
                                    user.ridingExperience!,
                                    style: const TextStyle(
                                      color: AppColors.forest,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                                if (user.bikeInfo != null) ...[
                                  const SizedBox(height: 6),
                                  const UpperLabel('Current steed'),
                                  Text(
                                    user.bikeInfo!,
                                    style: const TextStyle(
                                      color: AppColors.forest,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 8),
                                const Text(
                                  'Tap to edit profile',
                                  style: TextStyle(
                                    color: AppColors.ember,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: AppColors.stone),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        value: '${user.unlockedRoutesCount ?? 0}',
                        label: 'Unlocked',
                        valueColor: AppColors.ember,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatCard(
                        value: '${user.verifiedRouteCompletions ?? 0}',
                        label: 'Verified rides',
                        valueColor: AppColors.forest,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatCard(
                        value: '${user.hostedRidesCount ?? 0}',
                        label: 'Hosted rides',
                        valueColor: AppColors.ink,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Recommendation points are private and not shown on your profile.',
                  style: TextStyle(color: AppColors.stone, fontSize: 12),
                ),
                const SizedBox(height: 16),
                if (user.isHost)
                  Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: AppColors.sand),
                      ),
                      leading: const Icon(Icons.flag_outlined, color: AppColors.forest),
                      title: const Text('Host dashboard'),
                      subtitle: const Text('Manage events, attendance, and completion'),
                      onTap: () => context.push('/host'),
                    ),
                  )
                else if (user.hasPendingHostApplication)
                  Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: AppColors.sand),
                      ),
                      leading: const Icon(Icons.hourglass_top, color: AppColors.ember),
                      title: const Text('Host application pending'),
                      subtitle: const Text('View or resubmit your marshal application'),
                      onTap: () => context.push('/host/apply'),
                    ),
                  )
                else
                  Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: AppColors.sand),
                      ),
                      leading: const Icon(Icons.hiking, color: AppColors.forest),
                      title: const Text('Become a Trail Host'),
                      subtitle: const Text('Apply to curate and marshal community rides'),
                      onTap: () => context.push('/host/apply'),
                    ),
                  ),
                if (user.isAdmin) ...[
                  const SizedBox(height: 12),
                  Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: AppColors.sand),
                      ),
                      leading: const Icon(Icons.admin_panel_settings_outlined,
                          color: AppColors.forest),
                      title: const Text('Admin console'),
                      subtitle:
                          const Text('Hosts, trails, regions, and platform control'),
                      onTap: () => context.push('/admin'),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () async {
                    await ref.read(authControllerProvider.notifier).logout();
                  },
                  child: const Text('Sign out'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    required this.valueColor,
  });

  final String value;
  final String label;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.sand),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: AppColors.stone,
            ),
          ),
        ],
      ),
    );
  }
}
