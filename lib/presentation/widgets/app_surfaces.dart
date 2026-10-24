import 'package:flutter/material.dart';

import '../themes/app_tokens.dart';
import '../themes/colors.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: AppColors.surface(context),
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
  final bool circle;

  const IconTile({
    super.key,
    this.icon,
    this.child,
    required this.background,
    required this.foreground,
    this.size = AppSize.tile,
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
    child: child ?? Icon(icon, size: AppSize.icon, color: foreground),
  );
}
