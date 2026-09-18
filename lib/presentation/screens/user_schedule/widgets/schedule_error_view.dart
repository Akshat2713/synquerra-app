import 'package:flutter/material.dart';
import '../../../../presentation/themes/colors.dart';

class ScheduleErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ScheduleErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline_rounded, size: 48, color: AppColors.danger),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(color: AppColors.danger),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
