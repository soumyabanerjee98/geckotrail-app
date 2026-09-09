import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../auth/providers/auth_provider.dart';
import '../../../shared/models/host.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/async_body.dart';
import '../../../shared/widgets/design_system.dart';

final adminHostAppsProvider =
    FutureProvider.autoDispose.family<List<HostProfile>, String?>((ref, status) {
  return ref.watch(adminRepositoryProvider).listHostApplications(status: status);
});

class AdminHostApprovalsScreen extends ConsumerStatefulWidget {
  const AdminHostApprovalsScreen({super.key});

  @override
  ConsumerState<AdminHostApprovalsScreen> createState() =>
      _AdminHostApprovalsScreenState();
}

class _AdminHostApprovalsScreenState
    extends ConsumerState<AdminHostApprovalsScreen> {
  String? _filter = 'PENDING';

  Future<void> _approve(HostProfile host) async {
    try {
      await ref.read(adminRepositoryProvider).approveHost(host.userId);
      ref.invalidate(adminHostAppsProvider(_filter));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Approved ${host.displayName ?? 'host'}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  Future<void> _reject(HostProfile host) async {
    try {
      await ref.read(adminRepositoryProvider).rejectHost(host.userId);
      ref.invalidate(adminHostAppsProvider(_filter));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Rejected ${host.displayName ?? 'host'}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appsAsync = ref.watch(adminHostAppsProvider(_filter));

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async => ref.invalidate(adminHostAppsProvider(_filter)),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => context.go('/admin'),
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Host Applications',
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              fontSize: 26,
                            ),
                      ),
                      const Text(
                        'Review experienced marshal certifications to protect remote trails.',
                        style: TextStyle(color: AppColors.stone, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                FilterChipPill(
                  label: 'Pending',
                  selected: _filter == 'PENDING',
                  onTap: () => setState(() => _filter = 'PENDING'),
                ),
                FilterChipPill(
                  label: 'Approved',
                  selected: _filter == 'APPROVED',
                  onTap: () => setState(() => _filter = 'APPROVED'),
                ),
                FilterChipPill(
                  label: 'Rejected',
                  selected: _filter == 'REJECTED',
                  onTap: () => setState(() => _filter = 'REJECTED'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            appsAsync.when(
              loading: () => const LoadingView(),
              error: (e, _) => ErrorView(
                message: e.toString(),
                onRetry: () => ref.invalidate(adminHostAppsProvider(_filter)),
              ),
              data: (apps) {
                if (apps.isEmpty) {
                  return const EmptyView(title: 'No applications in this filter');
                }
                return Column(
                  children: apps
                      .map(
                        (h) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _HostAppCard(
                            host: h,
                            showActions: _filter == 'PENDING',
                            onApprove: () => _approve(h),
                            onReject: () => _reject(h),
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _HostAppCard extends StatelessWidget {
  const _HostAppCard({
    required this.host,
    required this.showActions,
    required this.onApprove,
    required this.onReject,
  });

  final HostProfile host;
  final bool showActions;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final filed = host.submittedAt != null
        ? DateFormat('MMM d, y').format(host.submittedAt!.toLocal())
        : null;
    final years = host.experienceYears;

    return Container(
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
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.forest,
                backgroundImage:
                    host.photoUrl != null ? NetworkImage(host.photoUrl!) : null,
                child: host.photoUrl == null
                    ? Text(
                        (host.displayName ?? 'H')[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      host.displayName ?? 'Applicant',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      [
                        if (years != null) '$years Years Active',
                        if (filed != null) 'Filed $filed',
                      ].join(' • '),
                      style: const TextStyle(color: AppColors.stone, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (host.regions.isNotEmpty) ...[
            const SizedBox(height: 14),
            const UpperLabel('Regions applied for'),
            const SizedBox(height: 4),
            Text(
              host.regions.join(' • '),
              style: const TextStyle(
                color: AppColors.forest,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          if (host.motivation?.isNotEmpty == true) ...[
            const SizedBox(height: 12),
            const UpperLabel('Marshal motivation'),
            const SizedBox(height: 4),
            Text(
              '"${host.motivation}"',
              style: const TextStyle(color: AppColors.ink),
            ),
          ],
          if (showActions) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: const BorderSide(color: AppColors.danger),
                    ),
                    onPressed: onReject,
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: onApprove,
                    child: const Text('Approve Marshal'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
