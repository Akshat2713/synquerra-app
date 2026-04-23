// lib/presentation/widgets/core/app_icon_with_bg.dart
import 'package:flutter/material.dart';

class AppIconWithBg extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final double size;
  final double padding;
  final double borderRadius;

  const AppIconWithBg({
    super.key,
    required this.icon,
    this.color,
    this.size = 24,
    this.padding = 12,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconColor = color ?? colorScheme.primary;

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Icon(icon, size: size, color: iconColor),
    );
  }
}