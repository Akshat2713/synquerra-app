import 'package:flutter/material.dart';

import '../../../../domain/entities/geofence/geofence_entity.dart';
import '../../../themes/colors.dart';

class CoordinatesList extends StatelessWidget {
  final List<Coordinate> coordinates;
  final VoidCallback onReset;

  const CoordinatesList({
    super.key,
    required this.coordinates,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // Show only first 5 — last is closing point (duplicate of first)
    final display = coordinates.take(5).toList();

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.outlineVariant(context)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ...display.asMap().entries.map((e) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${e.key + 1}',
                            style: textTheme.labelSmall?.copyWith(
                              color: AppColors.onPrimaryContainer(context),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${e.value.lat.toStringAsFixed(6)},  ${e.value.lng.toStringAsFixed(6)}',
                          style: textTheme.bodySmall?.copyWith(
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (e.key < display.length - 1)
                  Divider(height: 1, color: AppColors.outlineVariant(context)),
              ],
            );
          }),
          Divider(height: 1, color: AppColors.outlineVariant(context)),
          TextButton.icon(
            onPressed: onReset,
            icon: const Icon(Icons.edit_location_alt_outlined, size: 18),
            label: const Text('Redraw on map'),
          ),
        ],
      ),
    );
  }
}
