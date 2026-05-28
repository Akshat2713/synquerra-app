// presentation/widgets/map_icon_button.dart

import 'package:flutter/material.dart';

class MapIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final ColorScheme colors;
  final bool highlighted;

  // Notice we can make this a 'const' constructor now!
  const MapIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.colors,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: highlighted ? colors.primary : colors.surface,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8),
          ],
        ),
        child: Icon(
          icon,
          size: 20,
          color: highlighted ? colors.onPrimary : colors.onSurface,
        ),
      ),
    );
  }
}
