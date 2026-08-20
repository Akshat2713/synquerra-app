// presentation/widgets/map_icon_button.dart
import 'package:flutter/material.dart';
import '../../../themes/colors.dart';

class MapIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap; // ← nullable
  final bool highlighted;
  final Widget? child;

  const MapIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.highlighted = false,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    final iconColor = highlighted
        ? Colors.white
        : disabled
        ? AppColors.textSecondary(context).withValues(alpha: 0.4)
        : AppColors.textPrimary(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: highlighted
              ? AppColors.primary
              : disabled
              ? AppColors.surfaceVariant(context)
              : AppColors.surface(context),
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
        child: Center(child: child ?? Icon(icon, size: 20, color: iconColor)),
      ),
    );
  }
}
