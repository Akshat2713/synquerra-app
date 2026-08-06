import 'package:flutter/material.dart';

class GeofenceStatusChip extends StatelessWidget {
  final bool isActive;

  const GeofenceStatusChip({super.key, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: isActive
            ? colors.primaryContainer
            : colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: textTheme.labelSmall?.copyWith(
          color: isActive ? colors.onPrimaryContainer : colors.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
