import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/providers/auth_provider.dart';
import '../../../shared/models/host.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/design_system.dart';

final myHostProfileProvider = FutureProvider.autoDispose<HostProfile?>((ref) {
  return ref.watch(hostRepositoryProvider).me();
});

class BecomeHostScreen extends ConsumerStatefulWidget {
  const BecomeHostScreen({super.key});

  @override
  ConsumerState<BecomeHostScreen> createState() => _BecomeHostScreenState();
}

class _BecomeHostScreenState extends ConsumerState<BecomeHostScreen> {
  final _years = TextEditingController();
  final _familiar = TextEditingController();
  final _motivation = TextEditingController();
  final _bike = TextEditingController();
  final _certName = TextEditingController();
  final Set<String> _regions = {};
  bool _busy = false;
  String? _error;

  static const _regionOptions = [
    'Ladakh',
    'Himachal',
    'Uttarakhand',
    'Rajasthan',
    'Western Ghats',
    'Maharashtra',
    'Karnataka',
  ];

  @override
  void dispose() {
    _years.dispose();
    _familiar.dispose();
    _motivation.dispose();
    _bike.dispose();
    _certName.dispose();
    super.dispose();
  }

  Future<void> _submit({bool resubmit = false}) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final payload = {
        'experienceYears': int.tryParse(_years.text.trim()),
        'regions': _regions.toList(),
        'familiarTrails': _familiar.text.trim(),
        'motivation': _motivation.text.trim(),
        'bikeInfo': _bike.text.trim(),
        'certificateFileName': _certName.text.trim().isEmpty
            ? null
            : _certName.text.trim(),
      };
      if (resubmit) {
        await ref.read(hostRepositoryProvider).updateMe(payload);
      } else {
        await ref.read(hostRepositoryProvider).apply(payload);
      }
      ref.invalidate(myHostProfileProvider);
      await ref.read(authControllerProvider.notifier).refreshUser();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Application submitted for review')),
        );
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hostAsync = ref.watch(myHostProfileProvider);

    return TopoBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: hostAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('$e')),
            data: (profile) {
              final pending = profile?.isPending == true;
              final approved = profile?.isApproved == true;
              if (approved) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) context.go('/host');
                });
              }
              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                      ),
                      Text(
                        'Become a Trail Host',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  if (pending)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.ember.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Application Status: PENDING REVIEW',
                        style: TextStyle(
                          color: AppColors.ember,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  Text(
                    'Apply to curate hosted rides and earn marshal trust.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.stone,
                        ),
                  ),
                  const SizedBox(height: 20),
                  const UpperLabel('Riding experience (years)'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _years,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: 'e.g. 8'),
                  ),
                  const SizedBox(height: 16),
                  const UpperLabel('Regions of expertise'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final region in _regionOptions)
                        FilterChipPill(
                          label: region,
                          selected: _regions.contains(region),
                          onTap: () => setState(() {
                            if (_regions.contains(region)) {
                              _regions.remove(region);
                            } else {
                              _regions.add(region);
                            }
                          }),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const UpperLabel('Curated trails familiar with'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _familiar,
                    decoration: const InputDecoration(
                      hintText: 'Spiti Circuit, Ghats Ridge…',
                    ),
                  ),
                  const SizedBox(height: 16),
                  const UpperLabel('Brief rider bio / motivation'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _motivation,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Why you should marshal community rides…',
                    ),
                  ),
                  const SizedBox(height: 16),
                  const UpperLabel('Motorcycle details'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _bike,
                    decoration: const InputDecoration(
                      hintText: 'RE Himalayan 450…',
                    ),
                  ),
                  const SizedBox(height: 16),
                  const UpperLabel('Marshal certificate (filename)'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _certName,
                    decoration: const InputDecoration(
                      hintText: 'Himalayan_marshal_cert.pdf',
                      prefixIcon: Icon(Icons.attach_file, color: AppColors.ember),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: const TextStyle(color: AppColors.danger)),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: pending
                        ? ElevatedButton.styleFrom(
                            backgroundColor: AppColors.ember,
                          )
                        : null,
                    onPressed: _busy
                        ? null
                        : () => _submit(resubmit: pending),
                    child: Text(
                      _busy
                          ? 'Submitting…'
                          : pending
                              ? 'Resubmit Application'
                              : 'Submit Application',
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
