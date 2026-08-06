import 'package:flutter/material.dart';

class EmptyCoordinatesPlaceholder extends StatelessWidget {
  final VoidCallback onTap;

  const EmptyCoordinatesPlaceholder({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 28),
        decoration: BoxDecoration(
          border: Border.all(
            color: colors.primary.withValues(alpha: 0.4),
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(12),
          color: colors.primaryContainer.withValues(alpha: 0.15),
        ),
        child: Column(
          children: [
            Icon(Icons.map_outlined, size: 36, color: colors.primary),
            const SizedBox(height: 8),
            Text(
              'Tap to draw on map',
              style: TextStyle(
                color: colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Place exactly 5 points to define the zone',
              style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
