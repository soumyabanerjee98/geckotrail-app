import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/providers/auth_provider.dart';
import '../../../shared/models/trail.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/async_body.dart';
import '../../../shared/widgets/design_system.dart';

final adminTrailsProvider = FutureProvider.autoDispose<List<TrailSummary>>((ref) {
  return ref.watch(trailRepositoryProvider).listTrails();
});

class AdminTrailsScreen extends ConsumerWidget {
  const AdminTrailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trailsAsync = ref.watch(adminTrailsProvider);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async => ref.invalidate(adminTrailsProvider),
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
                    'Manage Trails',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontSize: 26,
                        ),
                  ),
                ),
                FilledButton(
                  onPressed: () => context.push('/admin/trails/create'),
                  child: const Text('+ Upload'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Publish curated routes and eco safeguards for the platform.',
              style: TextStyle(color: AppColors.stone),
            ),
            const SizedBox(height: 16),
            trailsAsync.when(
              loading: () => const LoadingView(),
              error: (e, _) => ErrorView(
                message: e.toString(),
                onRetry: () => ref.invalidate(adminTrailsProvider),
              ),
              data: (trails) {
                if (trails.isEmpty) {
                  return EmptyView(
                    title: 'No trails yet',
                    actionLabel: 'Upload trail',
                    onAction: () => context.push('/admin/trails/create'),
                  );
                }
                return Column(
                  children: trails
                      .map(
                        (t) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(AppRadii.card),
                              border: Border.all(color: AppColors.sand),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        t.name,
                                        style: Theme.of(context).textTheme.titleLarge,
                                      ),
                                      Text(
                                        '${t.region} · ${t.difficulty?.name ?? '—'}',
                                        style: const TextStyle(color: AppColors.stone),
                                      ),
                                    ],
                                  ),
                                ),
                                if (t.ecoSensitive)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.success.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: const Text(
                                      'ECO',
                                      style: TextStyle(
                                        color: AppColors.success,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
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

class AdminUploadTrailScreen extends ConsumerStatefulWidget {
  const AdminUploadTrailScreen({super.key});

  @override
  ConsumerState<AdminUploadTrailScreen> createState() =>
      _AdminUploadTrailScreenState();
}

class _AdminUploadTrailScreenState extends ConsumerState<AdminUploadTrailScreen> {
  final _name = TextEditingController();
  final _region = TextEditingController();
  final _distance = TextEditingController();
  final _elevation = TextEditingController();
  final _terrain = TextEditingController();
  final _ecoNotes = TextEditingController();
  String _difficulty = 'MODERATE';
  bool _eco = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _region.dispose();
    _distance.dispose();
    _elevation.dispose();
    _terrain.dispose();
    _ecoNotes.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(trailRepositoryProvider).createTrail({
        'name': _name.text.trim(),
        'region': _region.text.trim(),
        'regionName': _region.text.trim(),
        'distanceKm': double.tryParse(_distance.text.trim()),
        'elevationGainM': double.tryParse(_elevation.text.trim()),
        'difficulty': _difficulty,
        'terrain': _terrain.text.trim(),
        'ecoSensitive': _eco,
        'ecoNotes': _ecoNotes.text.trim(),
      });
      ref.invalidate(adminTrailsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Trail created. GPX can be uploaded via PATCH multipart later.'),
        ),
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
                    'Upload New Trail',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const UpperLabel('Trail name'),
              const SizedBox(height: 8),
              TextField(controller: _name, decoration: const InputDecoration(hintText: 'Western Ghats Ridge Run')),
              const SizedBox(height: 14),
              const UpperLabel('Region'),
              const SizedBox(height: 8),
              TextField(controller: _region, decoration: const InputDecoration(hintText: 'Karnataka')),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const UpperLabel('Distance (km)'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _distance,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: '86'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const UpperLabel('Elevation (m)'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _elevation,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: '1200'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const UpperLabel('Difficulty'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _difficulty,
                items: const [
                  DropdownMenuItem(value: 'EASY', child: Text('Easy')),
                  DropdownMenuItem(value: 'MODERATE', child: Text('Moderate')),
                  DropdownMenuItem(value: 'HARD', child: Text('Hard')),
                  DropdownMenuItem(value: 'EXPERT', child: Text('Expert')),
                ],
                onChanged: (v) => setState(() => _difficulty = v ?? 'MODERATE'),
              ),
              const SizedBox(height: 14),
              const UpperLabel('Terrain'),
              const SizedBox(height: 8),
              TextField(controller: _terrain, decoration: const InputDecoration(hintText: 'Gravel, mud, rock')),
              const SizedBox(height: 14),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Eco-sensitive corridor'),
                value: _eco,
                onChanged: (v) => setState(() => _eco = v),
              ),
              const UpperLabel('Eco / safety notes'),
              const SizedBox(height: 8),
              TextField(
                controller: _ecoNotes,
                maxLines: 3,
                decoration: const InputDecoration(hintText: 'Permit windows, quiet hours…'),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: AppColors.danger)),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _busy ? null : _submit,
                child: Text(_busy ? 'Uploading…' : 'Publish Trail'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
