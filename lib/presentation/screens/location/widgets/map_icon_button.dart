// presentation/screens/device_detail/widgets/map_icon_button.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../themes/colors.dart';
import '../../../themes/app_tokens.dart';

class MapIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap; // null = disabled
  final bool highlighted;
  final Widget? child;
  final String? tooltip;

  const MapIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.highlighted = false,
    this.child,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    final background = highlighted
        ? AppColors.primary(context)
        : disabled
        ? AppColors.surfaceVariant(context)
        : AppColors.surface(context);
    final iconColor = highlighted
        ? AppColors.onPrimary(context)
        : disabled
        ? AppAlpha.withAlpha(
            AppColors.textSecondary(context),
            AppAlpha.disabled,
          )
        : AppColors.textPrimary(context);

    // Shadow lives on the outer box; the Material (and its ink) sits inside.
    final button = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: AppRadius.mdAll,
        boxShadow: disabled ? null : AppShadow.soft(AppColors.shadow(context)),
      ),
      child: Material(
        color: background,
        borderRadius: AppRadius.mdAll,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: disabled
              ? null
              : () {
                  HapticFeedback.selectionClick();
                  onTap!();
                },
          child: SizedBox(
            width: AppSize.tile,
            height: AppSize.tile,
            child: Center(
              child: child ?? Icon(icon, size: AppSize.icon, color: iconColor),
            ),
          ),
        ),
      ),
    );

    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}
