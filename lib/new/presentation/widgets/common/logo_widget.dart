// lib/presentation/widgets/common/logo_widget.dart
import 'package:flutter/material.dart';
import '../../themes/colors.dart';

class LogoWidget extends StatelessWidget {
  final String imagePath;
  final double size;
  final Color? backgroundColor;
  final double padding;

  const LogoWidget({
    super.key,
    required this.imagePath,
    this.size = 100,
    this.backgroundColor,
    this.padding = 20,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor ?? colorScheme.primary.withOpacity(0.1),
      ),
      child: Image.asset(
        imagePath,
        height: size,
        width: size,
        errorBuilder: (context, error, stackTrace) => Icon(
          Icons.school_rounded,
          size: size * 0.8,
          color: colorScheme.primary,
        ),
      ),
    );
  }
}
