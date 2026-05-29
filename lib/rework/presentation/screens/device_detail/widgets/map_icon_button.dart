// presentation/widgets/map_icon_button.dart

import 'package:flutter/material.dart';

class MapIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap; // ← nullable
  final ColorScheme colors;
  final bool highlighted;

  const MapIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.colors,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: highlighted
              ? colors.primary
              : disabled
              ? colors.surfaceContainerHighest
              : colors.surface,
          borderRadius: BorderRadius.circular(10),
          boxShadow: disabled
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                  ),
                ],
        ),
        child: Icon(
          icon,
          size: 20,
          color: highlighted
              ? colors.onPrimary
              : disabled
              ? colors.onSurfaceVariant.withValues(alpha: 0.4)
              : colors.onSurface,
        ),
      ),
    );
  }
}
