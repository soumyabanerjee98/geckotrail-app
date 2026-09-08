import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.moss),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message!, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}

class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.stone),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              ElevatedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ],
        ),
      ),
    );
  }
}

class AsyncBody<T> extends StatelessWidget {
  const AsyncBody({
    super.key,
    required this.value,
    required this.builder,
    this.onRetry,
    this.emptyTitle,
    this.isEmpty,
  });

  final AsyncValueLike<T> value;
  final Widget Function(T data) builder;
  final VoidCallback? onRetry;
  final String? emptyTitle;
  final bool Function(T data)? isEmpty;

  @override
  Widget build(BuildContext context) {
    if (value.isLoading && !value.hasValue) {
      return const LoadingView();
    }
    if (value.hasError && !value.hasValue) {
      return ErrorView(
        message: value.errorMessage ?? 'Something went wrong',
        onRetry: onRetry,
      );
    }
    final data = value.requireValue;
    if (isEmpty != null && isEmpty!(data)) {
      return EmptyView(title: emptyTitle ?? 'Nothing here yet');
    }
    return builder(data);
  }
}

/// Lightweight adapter so screens can pass Riverpod AsyncValue without importing riverpod here.
class AsyncValueLike<T> {
  const AsyncValueLike({
    required this.isLoading,
    required this.hasValue,
    required this.hasError,
    this.value,
    this.errorMessage,
  });

  final bool isLoading;
  final bool hasValue;
  final bool hasError;
  final T? value;
  final String? errorMessage;

  T get requireValue => value as T;
}
