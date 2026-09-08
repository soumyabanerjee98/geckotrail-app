import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/providers/auth_provider.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/async_body.dart';
import '../../../shared/widgets/design_system.dart';

final profileProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) {
  return ref.watch(profileRepositoryProvider).getProfile();
});

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final user = auth.user;
    final profileAsync = ref.watch(profileProvider);
    final name = user?.name ?? 'Rider';

    return TopoBackground(
      child: SafeArea(
        bottom: false,
        child: ListView(
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
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadii.card),
                border: Border.all(color: AppColors.sand),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.ember, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 36,
                      backgroundColor: AppColors.forest,
                      backgroundImage: user?.photoUrl != null
                          ? NetworkImage(user!.photoUrl!)
                          : null,
                      child: user?.photoUrl == null
                          ? Text(
                              name.isNotEmpty ? name[0].toUpperCase() : 'R',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                              ),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: profileAsync.when(
                      data: (data) {
                        final bio = data['bio']?.toString();
                        final experience = data['ridingExperience']?.toString();
                        final bike = data['bikeInfo']?.toString();
                        return Column(
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
                              bio?.isNotEmpty == true
                                  ? bio!
                                  : (user?.email ?? ''),
                              style: const TextStyle(
                                color: AppColors.stone,
                                fontSize: 13,
                              ),
                            ),
                            if (experience != null) ...[
                              const SizedBox(height: 8),
                              UpperLabel('Riding since'),
                              Text(
                                experience,
                                style: const TextStyle(
                                  color: AppColors.forest,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                            if (bike != null) ...[
                              const SizedBox(height: 6),
                              UpperLabel('Current steed'),
                              Text(
                                bike,
                                style: const TextStyle(
                                  color: AppColors.forest,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                      loading: () => const LoadingView(),
                      error: (e, _) => Text(e.toString()),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            profileAsync.when(
              data: (data) {
                final unlocked = data['unlockedRoutesCount'] ?? 0;
                final completions = data['verifiedRouteCompletions'] ?? 0;
                final hosted = data['hostedRidesCount'] ?? 0;
                return Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        value: '$unlocked',
                        label: 'Unlocked',
                        valueColor: AppColors.ember,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatCard(
                        value: '$completions',
                        label: 'Verified rides',
                        valueColor: AppColors.forest,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatCard(
                        value: '$hosted',
                        label: 'Hosted rides',
                        valueColor: AppColors.ink,
                      ),
                    ),
                  ],
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 20),
            const Text(
              'Recommendation points are private and not shown on your profile.',
              style: TextStyle(color: AppColors.stone, fontSize: 12),
            ),
            const SizedBox(height: 16),
            if (user?.isHost == true)
              ListTile(
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: AppColors.sand),
                ),
                leading: const Icon(Icons.flag_outlined, color: AppColors.forest),
                title: const Text('Host dashboard'),
                subtitle: const Text('Manage events, attendance, and completion'),
                onTap: () => context.push('/host'),
              ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () async {
                await ref.read(authControllerProvider.notifier).logout();
              },
              child: const Text('Sign out'),
            ),
          ],
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
