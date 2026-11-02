import 'package:flutter/material.dart';
import '../../themes/app_tokens.dart';
import '../../themes/colors.dart';
import '../../widgets/app_surfaces.dart';

class ProfileSkeleton extends StatefulWidget {
  const ProfileSkeleton({super.key});

  @override
  State<ProfileSkeleton> createState() => _ProfileSkeletonState();
}

class _ProfileSkeletonState extends State<ProfileSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: AppMotion.slow * 3,
  );
  late final Animation<double> _anim = CurvedAnimation(
    parent: _ctrl,
    curve: AppMotion.curve,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _ctrl.stop();
    } else if (!_ctrl.isAnimating) {
      _ctrl.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        final t = _anim.value;
        final base = Color.lerp(
          AppColors.surfaceVariant(context),
          AppColors.outlineVariant(context),
          t * AppAlpha.overlay,
        )!;
        final onP = AppColors.onPrimary(context);
        final onGradient = Color.lerp(
          AppAlpha.withAlpha(onP, AppAlpha.fill),
          AppAlpha.withAlpha(onP, AppAlpha.overlay),
          t,
        )!;

        Widget block({
          required Color color,
          double? width,
          double height = AppSize.skeletonLine,
          bool circle = false,
          BorderRadius? radius,
        }) => Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: color,
            shape: circle ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: circle ? null : (radius ?? AppRadius.pillAll),
          ),
        );

        // Pill-shaped line, centered, as a fraction of the width.
        Widget centered(double factor, Color color, {double? height}) =>
            FractionallySizedBox(
              widthFactor: factor,
              child: block(
                color: color,
                height: height ?? AppSize.skeletonLine,
              ),
            );

        final hero = Container(
          padding: AppSpacing.lgAll,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient(context),
            borderRadius: AppRadius.lgAll,
            boxShadow: AppShadow.glow(AppColors.primary(context)),
          ),
          child: Column(
            spacing: AppSpacing.smd,
            children: [
              block(
                color: onGradient,
                width: AppSize.avatarLg,
                height: AppSize.avatarLg,
                circle: true,
              ),
              centered(0.5, onGradient, height: AppSize.icon),
              centered(0.7, onGradient),
              FractionallySizedBox(
                widthFactor: 0.8,
                child: Row(
                  spacing: AppSpacing.sm,
                  children: [
                    Expanded(
                      child: block(color: onGradient, height: AppSize.iconLg),
                    ),
                    Expanded(
                      child: block(color: onGradient, height: AppSize.iconLg),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

        Widget card(Color tileColor, int rows) => AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                spacing: AppSpacing.smd,
                children: [
                  block(
                    color: tileColor,
                    width: AppSize.tile,
                    height: AppSize.tile,
                    radius: AppRadius.mdAll,
                  ),
                  Expanded(
                    child: FractionallySizedBox(
                      widthFactor: 0.5,
                      alignment: Alignment.centerLeft,
                      child: block(color: base),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              for (var i = 0; i < rows; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: block(
                    color: base,
                    height: AppSize.tapTarget,
                    radius: AppRadius.mdAll,
                  ),
                ),
            ],
          ),
        );

        return SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          padding: AppSpacing.mdAll,
          child: Column(
            spacing: AppSpacing.md,
            children: [
              hero,
              card(AppColors.primaryContainer(context), 3),
              card(AppColors.infoContainer, 5),
            ],
          ),
        );
      },
    );
  }
}
