import 'package:flutter/material.dart';

class AsyncStateView extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;
  final bool isEmpty;
  final Widget Function() builder;
  final VoidCallback? onRetry;
  final Widget? loadingWidget;
  final Widget? emptyWidget;
  final String emptyMessage;

  const AsyncStateView({
    super.key,
    required this.isLoading,
    required this.builder,
    this.errorMessage,
    this.isEmpty = false,
    this.onRetry,
    this.loadingWidget,
    this.emptyWidget,
    this.emptyMessage = 'No data available',
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return loadingWidget ??
          const Center(child: CircularProgressIndicator.adaptive());
    }

    if (errorMessage != null && errorMessage!.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 12),
              Text(
                errorMessage!,
                textAlign: TextAlign.justify,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 16),
                FilledButton.tonal(
                  onPressed: onRetry,
                  child: const Text('Retry'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    if (isEmpty) {
      return emptyWidget ??
          Center(
            child: Text(
              emptyMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).hintColor,
              ),
            ),
          );
    }

    return builder();
  }
}
