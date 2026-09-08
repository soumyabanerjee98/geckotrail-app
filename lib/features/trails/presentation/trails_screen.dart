import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../../../shared/models/trail.dart';
import '../../../shared/widgets/trail_card.dart';
import '../../../shared/widgets/async_body.dart';

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

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(trailsListProvider(_query));

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Trails')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _search,
              decoration: InputDecoration(
                hintText: 'Search trails or regions',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => setState(() => _query = _search.text.trim()),
                ),
              ),
              onSubmitted: (value) => setState(() => _query = value.trim()),
            ),
          ),
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
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) => TrailCard(trail: items[index]),
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
    );
  }
}
