import 'package:flutter/material.dart';

import '../../../themes/colors.dart';

class GeofenceStatusChip extends StatelessWidget {
  final bool isActive;

  const GeofenceStatusChip({super.key, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.successContainer.withValues(alpha: 0.1)
            : AppColors.surfaceVariant(context),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: textTheme.labelSmall?.copyWith(
          color: isActive
              ? AppColors.success
              : AppColors.textSecondary(context),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
