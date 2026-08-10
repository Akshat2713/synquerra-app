import 'package:flutter/material.dart';

import '../../../../domain/entities/geofence/geofence_entity.dart';

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
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    // Show only first 5 — last is closing point (duplicate of first)
    final display = coordinates.take(5).toList();

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colors.outlineVariant),
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
                          color: colors.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${e.key + 1}',
                            style: textTheme.labelSmall?.copyWith(
                              color: colors.onPrimaryContainer,
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
                  Divider(height: 1, color: colors.outlineVariant),
              ],
            );
          }),
          Divider(height: 1, color: colors.outlineVariant),
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
