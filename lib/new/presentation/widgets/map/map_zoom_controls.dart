// lib/presentation/widgets/map/map_zoom_controls.dart
import 'package:flutter/material.dart';

class MapZoomControls extends StatelessWidget {
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  const MapZoomControls({
    super.key,
    required this.onZoomIn,
    required this.onZoomOut,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Positioned(
      top: MediaQuery.of(context).padding.top + 130,
      right: 10,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              blurRadius: 8,
              color: Colors.black.withValues(alpha: 0.15),
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.add_rounded),
              onPressed: onZoomIn,
              iconSize: 28,
              color: colorScheme.primary,
            ),
            Container(
              height: 1,
              width: 30,
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
            IconButton(
              icon: const Icon(Icons.remove_rounded),
              onPressed: onZoomOut,
              iconSize: 28,
              color: colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}
