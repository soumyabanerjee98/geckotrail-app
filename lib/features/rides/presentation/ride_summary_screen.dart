import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/theme/app_theme.dart';

class RideSummaryScreen extends StatelessWidget {
  const RideSummaryScreen({
    super.key,
    required this.verified,
    this.message,
    this.familiarityLevel,
  });

  final bool verified;
  final String? message;
  final String? familiarityLevel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ride summary')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              verified ? Icons.verified : Icons.info_outline,
              size: 64,
              color: verified ? AppColors.success : AppColors.clay,
            ),
            const SizedBox(height: 16),
            Text(
              verified ? 'Route completed' : 'Ride recorded',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              verified
                  ? (message ?? 'Familiarity updated by the backend.')
                  : (message ??
                      'Completion could not be verified. Your ride was recorded.'),
            ),
            if (verified && familiarityLevel != null) ...[
              const SizedBox(height: 12),
              Text(
                'Familiarity: $familiarityLevel',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
            const Spacer(),
            ElevatedButton(
              onPressed: () => context.go('/my-routes'),
              child: const Text('Back to My Routes'),
            ),
          ],
        ),
      ),
    );
  }
}
