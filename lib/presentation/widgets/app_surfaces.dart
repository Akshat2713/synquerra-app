import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../themes/app_text_styles.dart';
import '../themes/app_tokens.dart';
import '../themes/colors.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? tint;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.tint,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: tint == null
          ? AppColors.surface(context)
          : Color.alphaBlend(tint!, AppColors.surface(context)),
      borderRadius: AppRadius.lgAll,
      border: Border.all(
        color: AppAlpha.withOverlayAlpha(AppColors.outline(context)),
      ),
      boxShadow: AppShadow.card(AppColors.shadow(context)),
    ),
    child: child,
  );
}

class IconTile extends StatelessWidget {
  final IconData? icon;
  final Widget? child;
  final Color background;
  final Color foreground;
  final double size;
  final double iconSize;
  final bool circle;

  const IconTile({
    super.key,
    this.icon,
    this.child,
    required this.background,
    required this.foreground,
    this.size = AppSize.tile,
    this.iconSize = AppSize.icon,
    this.circle = false,
  }) : assert(icon != null || child != null);

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: AppMotion.base,
    curve: AppMotion.curve,
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: background,
      shape: circle ? BoxShape.circle : BoxShape.rectangle,
      borderRadius: circle ? null : AppRadius.mdAll,
    ),
    child: child ?? Icon(icon, size: iconSize, color: foreground),
  );
}

/// Small rounded label, like the "Every 5 min" chips on Manage.
class InfoPill extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color background;
  final Color foreground;

  const InfoPill({
    super.key,
    required this.label,
    required this.background,
    required this.foreground,
    this.icon,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.smd,
      vertical: AppSpacing.xs,
    ),
    decoration: BoxDecoration(
      color: background,
      borderRadius: AppRadius.pillAll,
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: AppSize.iconSm, color: foreground),
          const SizedBox(width: AppSpacing.xs),
        ],
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.metaWithColor(
              context,
              color: foreground,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}

/// Tinted rounded row inside a card. Ripples (theme primary) when [onTap] is set.
class InsetRow extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const InsetRow({super.key, required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.smd,
      ),
      child: child,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: SizedBox(
        width: double.infinity,
        child: Material(
          color: AppColors.surfaceVariant(context),
          borderRadius: AppRadius.mdAll,
          clipBehavior: Clip.antiAlias,
          child: onTap == null
              ? content
              : InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onTap!();
                  },
                  child: content,
                ),
        ),
      ),
    );
  }
}
