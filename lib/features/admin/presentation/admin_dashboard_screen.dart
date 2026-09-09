import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/providers/auth_provider.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/design_system.dart';

final adminVitalsProvider = FutureProvider.autoDispose<Map<String, int>>((ref) async {
  final admin = ref.watch(adminRepositoryProvider);
  final trails = ref.watch(trailRepositoryProvider);
  final users = await admin.listUsers();
  final trailList = await trails.listTrails();
  final hosts = users
      .where((u) => u.isHost || u.hostStatus.name == 'approved')
      .length;
  final pending = users.where((u) => u.hasPendingHostApplication).length;
  return {
    'riders': users.length,
    'hosts': hosts,
    'trails': trailList.length,
    'pendingHosts': pending,
  };
});

class AdminShell extends ConsumerWidget {
  const AdminShell({super.key, required this.child, required this.location});

  final Widget child;
  final String location;

  int get _index {
    if (location.startsWith('/admin/hosts')) return 1;
    if (location.startsWith('/admin/trails')) return 2;
    if (location.startsWith('/admin/regions')) return 3;
    if (location.startsWith('/admin/events')) return 4;
    return 0;
  }

  void _go(BuildContext context, int index) {
    final path = switch (index) {
      1 => '/admin/hosts',
      2 => '/admin/trails',
      3 => '/admin/regions',
      4 => '/admin/events',
      _ => '/admin',
    };
    context.go(path);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TopoBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: child,
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => _go(context, i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.groups_outlined),
              selectedIcon: Icon(Icons.groups),
              label: 'Hosts',
            ),
            NavigationDestination(
              icon: Icon(Icons.map_outlined),
              selectedIcon: Icon(Icons.map),
              label: 'Trails',
            ),
            NavigationDestination(
              icon: Icon(Icons.public_outlined),
              selectedIcon: Icon(Icons.public),
              label: 'Regions',
            ),
            NavigationDestination(
              icon: Icon(Icons.event_outlined),
              selectedIcon: Icon(Icons.event),
              label: 'Rides',
            ),
          ],
        ),
      ),
    );
  }
}

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vitals = ref.watch(adminVitalsProvider);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async => ref.invalidate(adminVitalsProvider),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => context.go('/profile'),
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gecko Admin',
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              fontSize: 28,
                            ),
                      ),
                      const Text(
                        'National Trail & Community Control Console',
                        style: TextStyle(color: AppColors.stone),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const SectionHeader(title: 'Platform vitals'),
            const SizedBox(height: 10),
            vitals.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('$e'),
              data: (v) => Row(
                children: [
                  Expanded(child: _Vital(value: '${v['riders']}', label: 'Total Riders')),
                  const SizedBox(width: 8),
                  Expanded(child: _Vital(value: '${v['hosts']}', label: 'Active Hosts')),
                  const SizedBox(width: 8),
                  Expanded(child: _Vital(value: '${v['trails']}', label: 'Total Trails')),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const SectionHeader(title: 'Core admin actions'),
            const SizedBox(height: 10),
            _ActionCard(
              title: 'Review Host Applications',
              subtitle:
                  'Evaluate experienced riders applying to curate and marshal community expeditions.',
              badge: vitals.asData?.value['pendingHosts'],
              actionLabel: 'Review',
              onAction: () => context.go('/admin/hosts'),
            ),
            const SizedBox(height: 10),
            _ActionCard(
              title: 'Upload New Region',
              subtitle:
                  'Open up new geographic sectors and establish topographic limits for off-road riders.',
              actionLabel: 'Create',
              onAction: () => context.push('/admin/regions/create'),
            ),
            const SizedBox(height: 10),
            _ActionCard(
              title: 'Upload New Trail',
              subtitle:
                  'Import official GPX files, specify terrain difficulty levels, and detail eco-safeguards.',
              actionLabel: 'Upload',
              onAction: () => context.push('/admin/trails/create'),
            ),
            const SizedBox(height: 10),
            _ActionCard(
              title: 'Manage Group Rides',
              subtitle: 'Review hosted expeditions across the platform.',
              actionLabel: 'Open',
              onAction: () => context.go('/admin/events'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Vital extends StatelessWidget {
  const _Vital({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.sand),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.forest,
            ),
          ),
          Text(label, style: const TextStyle(color: AppColors.stone, fontSize: 11)),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
    this.badge,
  });

  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;
  final int? badge;

  @override
  Widget build(BuildContext context) {
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
              Expanded(
                child: Text(title, style: Theme.of(context).textTheme.titleLarge),
              ),
              if (badge != null && badge! > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.ember,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$badge',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(subtitle, style: const TextStyle(color: AppColors.stone)),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.forest.withValues(alpha: 0.12),
                foregroundColor: AppColors.forest,
              ),
              onPressed: onAction,
              child: Text(actionLabel),
            ),
          ),
        ],
      ),
    );
  }
}
