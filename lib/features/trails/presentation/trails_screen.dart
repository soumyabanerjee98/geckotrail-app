import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../../../shared/models/trail.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/trail_card.dart';
import '../../../shared/widgets/async_body.dart';
import '../../../shared/widgets/design_system.dart';

final trailsListProvider =
    FutureProvider.autoDispose.family<List<TrailSummary>, String?>((ref, query) {
  return ref.watch(trailRepositoryProvider).listTrails(query: query);
});

class TrailsScreen extends ConsumerStatefulWidget {
  const TrailsScreen({super.key});

  @override
  ConsumerState<TrailsScreen> createState() => _TrailsScreenState();
}

class _TrailsScreenState extends ConsumerState<TrailsScreen> {
  final _search = TextEditingController();
  String? _query;
  String _filter = 'Region: North';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(trailsListProvider(_query));

    return TopoBackground(
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Explore Trails',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontSize: 28,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Top curated trails curated by the community',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.stone,
                        ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _search,
                    decoration: InputDecoration(
                      hintText: 'Search trails or regions',
                      prefixIcon: const Icon(Icons.search, color: AppColors.stone),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () =>
                            setState(() => _query = _search.text.trim()),
                      ),
                    ),
                    onSubmitted: (value) =>
                        setState(() => _query = value.trim()),
                  ),
                  const SizedBox(height: 14),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final label in const [
                          'Region: North',
                          'Difficulty',
                          'Terrain',
                          'Eco-First',
                        ]) ...[
                          FilterChipPill(
                            label: label,
                            selected: _filter == label,
                            onTap: () => setState(() => _filter = label),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: async.when(
                data: (items) {
                  if (items.isEmpty) {
                    return const EmptyView(
                      title: 'No trails found',
                      subtitle: 'Try another region or check back later.',
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async =>
                        ref.invalidate(trailsListProvider(_query)),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 14),
                      itemBuilder: (context, index) =>
                          TrailCard(trail: items[index]),
                    ),
                  );
                },
                loading: () => const LoadingView(),
                error: (e, _) => ErrorView(
                  message: e.toString(),
                  onRetry: () => ref.invalidate(trailsListProvider(_query)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
