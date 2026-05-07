// lib/presentation/widgets/core/app_loading.dart
import 'package:flutter/material.dart';

class AppLoading extends StatelessWidget {
  final String? message;
  final bool fullScreen;

  const AppLoading({super.key, this.message, this.fullScreen = false});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final loader = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
          if (message != null) ...[
            const SizedBox(height: 20),
            Text(
              message!,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );

    if (fullScreen) {
      return Scaffold(body: loader);
    }

    return loader;
  }
}
