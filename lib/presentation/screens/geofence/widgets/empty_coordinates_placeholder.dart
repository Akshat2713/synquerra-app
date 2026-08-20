import 'package:flutter/material.dart';

import '../../../themes/colors.dart';

class EmptyCoordinatesPlaceholder extends StatelessWidget {
  final VoidCallback onTap;

  const EmptyCoordinatesPlaceholder({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 28),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.4),
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(12),
          color: AppColors.primaryContainer.withValues(alpha: 0.15),
        ),
        child: Column(
          children: [
            Icon(Icons.map_outlined, size: 36, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(
              'Tap to draw on map',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Place exactly 5 points to define the zone',
              style: TextStyle(
                color: AppColors.textSecondary(context),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
