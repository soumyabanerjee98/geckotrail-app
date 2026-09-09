import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/providers/auth_provider.dart';
import '../../../shared/models/region.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/async_body.dart';
import '../../../shared/widgets/design_system.dart';

final adminRegionsProvider = FutureProvider.autoDispose<List<Region>>((ref) {
  return ref.watch(regionRepositoryProvider).listRegions();
});

class AdminRegionsScreen extends ConsumerWidget {
  const AdminRegionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final regionsAsync = ref.watch(adminRegionsProvider);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async => ref.invalidate(adminRegionsProvider),
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
                  child: Text(
                    'Regions',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontSize: 26,
                        ),
                  ),
                ),
                FilledButton(
                  onPressed: () => context.push('/admin/regions/create'),
                  child: const Text('+ Create'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            regionsAsync.when(
              loading: () => const LoadingView(),
              error: (e, _) => ErrorView(
                message: e.toString(),
                onRetry: () => ref.invalidate(adminRegionsProvider),
              ),
              data: (regions) {
                if (regions.isEmpty) {
                  return EmptyView(
                    title: 'No regions yet',
                    actionLabel: 'Create region',
                    onAction: () => context.push('/admin/regions/create'),
                  );
                }
                return Column(
                  children: regions
                      .map(
                        (r) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(AppRadii.card),
                              border: Border.all(color: AppColors.sand),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(r.name, style: Theme.of(context).textTheme.titleLarge),
                                if (r.stateOrTerritory != null)
                                  Text(
                                    r.stateOrTerritory!,
                                    style: const TextStyle(color: AppColors.stone),
                                  ),
                                if (r.description != null) ...[
                                  const SizedBox(height: 6),
                                  Text(r.description!),
                                ],
                              ],
                            ),
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

class AdminUploadRegionScreen extends ConsumerStatefulWidget {
  const AdminUploadRegionScreen({super.key});

  @override
  ConsumerState<AdminUploadRegionScreen> createState() =>
      _AdminUploadRegionScreenState();
}

class _AdminUploadRegionScreenState
    extends ConsumerState<AdminUploadRegionScreen> {
  final _name = TextEditingController();
  final _state = TextEditingController();
  final _season = TextEditingController();
  final _description = TextEditingController();
  final _safety = TextEditingController();
  final _terrain = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _state.dispose();
    _season.dispose();
    _description.dispose();
    _safety.dispose();
    _terrain.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(regionRepositoryProvider).createRegion({
        'name': _name.text.trim(),
        'stateOrTerritory': _state.text.trim(),
        'bestSeason': _season.text.trim(),
        'description': _description.text.trim(),
        'safetyNotes': _safety.text.trim(),
        'terrainTypes': _terrain.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
      });
      ref.invalidate(adminRegionsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Region created')),
      );
      context.pop();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TopoBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                  ),
                  Text(
                    'Upload New Region',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const UpperLabel('Region name'),
              const SizedBox(height: 8),
              TextField(controller: _name, decoration: const InputDecoration(hintText: 'Spiti Valley')),
              const SizedBox(height: 14),
              const UpperLabel('State / territory'),
              const SizedBox(height: 8),
              TextField(controller: _state, decoration: const InputDecoration(hintText: 'Himachal Pradesh')),
              const SizedBox(height: 14),
              const UpperLabel('Best season'),
              const SizedBox(height: 8),
              TextField(controller: _season, decoration: const InputDecoration(hintText: 'Jun–Sep')),
              const SizedBox(height: 14),
              const UpperLabel('Description'),
              const SizedBox(height: 8),
              TextField(controller: _description, maxLines: 3),
              const SizedBox(height: 14),
              const UpperLabel('Terrain types (comma-separated)'),
              const SizedBox(height: 8),
              TextField(controller: _terrain, decoration: const InputDecoration(hintText: 'High-altitude, gravel')),
              const SizedBox(height: 14),
              const UpperLabel('Safety & eco notes'),
              const SizedBox(height: 8),
              TextField(controller: _safety, maxLines: 3),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: AppColors.danger)),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _busy ? null : _submit,
                child: Text(_busy ? 'Creating…' : 'Publish Region'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
