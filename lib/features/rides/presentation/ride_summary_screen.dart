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
      backgroundColor: AppColors.night,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    verified ? Icons.verified_user : Icons.info_outline,
                    size: 36,
                    color: verified ? AppColors.success : AppColors.ember,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                verified ? 'Route Completed!' : 'Ride recorded',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: AppColors.moss,
                      fontSize: 28,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                message ??
                    (verified
                        ? 'Familiarity updated by the backend.'
                        : 'Completion could not be verified. Your ride was recorded.'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.ember,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              if (verified && familiarityLevel != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cream,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Familiarity Upgraded!',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Text(
                            'Familiar',
                            style: TextStyle(
                              color: AppColors.stone,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.all(Radius.circular(999)),
                              child: LinearProgressIndicator(
                                value: 0.8,
                                minHeight: 8,
                                backgroundColor: AppColors.sand,
                                color: AppColors.forest,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            familiarityLevel!,
                            style: const TextStyle(
                              color: AppColors.forest,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => context.go('/my-routes'),
                child: const Text('Back to My Routes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
