import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/providers/auth_provider.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/async_body.dart';

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

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: () => context.push('/notifications'),
            icon: const Icon(Icons.notifications_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            user?.name ?? 'Rider',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          Text(user?.email ?? '', style: const TextStyle(color: AppColors.stone)),
          const SizedBox(height: 16),
          profileAsync.when(
            data: (data) {
              final bio = data['bio']?.toString();
              final experience = data['ridingExperience']?.toString();
              final bike = data['bikeInfo']?.toString();
              final completions = data['verifiedRouteCompletions'];
              final unlocked = data['unlockedRoutesCount'];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (bio != null && bio.isNotEmpty) Text(bio),
                  if (experience != null) ...[
                    const SizedBox(height: 8),
                    Text('Experience: $experience'),
                  ],
                  if (bike != null) Text('Bike: $bike'),
                  if (unlocked != null) Text('Unlocked routes: $unlocked'),
                  if (completions != null)
                    Text('Verified completions: $completions'),
                  const SizedBox(height: 8),
                  const Text(
                    'Recommendation points are private and not shown on your profile.',
                    style: TextStyle(color: AppColors.stone),
                  ),
                ],
              );
            },
            loading: () => const LoadingView(),
            error: (e, _) => Text(e.toString()),
          ),
          const SizedBox(height: 24),
          if (user?.isHost == true)
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.sand),
              ),
              leading: const Icon(Icons.flag_outlined),
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
    );
  }
}
