import 'package:flutter/material.dart';
import 'package:synquerra/presentation/themes/app_tokens.dart';
import 'package:synquerra/presentation/themes/colors.dart';
import 'package:synquerra/presentation/widgets/app_surfaces.dart';

class LandingSkeleton extends StatefulWidget {
  const LandingSkeleton({super.key});

  @override
  State<LandingSkeleton> createState() => _LandingSkeletonState();
}

class _LandingSkeletonState extends State<LandingSkeleton>
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

        // Neutral grey pulse for blocks sitting on white cards.
        final base = Color.lerp(
          AppColors.surfaceVariant(context),
          AppColors.outlineVariant(context),
          t * AppAlpha.overlay,
        )!;

        // Translucent pulse for blocks sitting on the gradient hero.
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

        // Pill-shaped text line, left aligned, as a fraction of the width.
        Widget line(
          double factor, {
          Color? color,
          double height = AppSize.skeletonLine,
        }) => FractionallySizedBox(
          widthFactor: factor,
          alignment: Alignment.centerLeft,
          child: block(color: color ?? base, height: height),
        );

        // Rounded icon tile, tinted like the real solid tiles.
        Widget tile(Color color) => block(
          color: color,
          width: AppSize.tile,
          height: AppSize.tile,
          radius: AppRadius.mdAll,
        );

        Widget chevron() => block(
          color: base,
          width: AppSize.iconLg,
          height: AppSize.iconLg,
          circle: true,
        );

        // Attention banner: tinted tile, two lines, stacked avatars.
        const step = AppSize.avatarSm - AppSpacing.sm;
        final banner = AppCard(
          child: Row(
            spacing: AppSpacing.md,
            children: [
              tile(AppColors.successContainer),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: AppSpacing.xs,
                  children: [line(0.7), line(0.4)],
                ),
              ),
              SizedBox(
                width: AppSize.avatarSm + step,
                height: AppSize.avatarSm,
                child: Stack(
                  children: [
                    block(
                      color: base,
                      width: AppSize.avatarSm,
                      height: AppSize.avatarSm,
                      circle: true,
                    ),
                    Positioned(
                      left: step,
                      child: block(
                        color: AppColors.primaryContainer(context),
                        width: AppSize.avatarSm,
                        height: AppSize.avatarSm,
                        circle: true,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

        // Hero: gradient card like the real one.
        final hero = Container(
          padding: AppSpacing.mdAll,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient(context),
            borderRadius: AppRadius.lgAll,
            boxShadow: AppShadow.glow(AppColors.primary(context)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.md,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: AppSpacing.md,
                children: [
                  block(
                    color: onGradient,
                    width: AppSize.avatarLg,
                    height: AppSize.avatarLg,
                    circle: true,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: AppSpacing.sm,
                      children: [
                        // Name — online status
                        Row(
                          spacing: AppSpacing.md,
                          children: [
                            Expanded(
                              flex: 3,
                              child: block(
                                color: onGradient,
                                height: AppSize.icon,
                              ),
                            ),
                            Expanded(child: block(color: onGradient)),
                          ],
                        ),
                        // Mode
                        line(0.35, color: onGradient),
                        // Speed pill, movement pill
                        Row(
                          spacing: AppSpacing.sm,
                          children: [
                            Expanded(
                              flex: 3,
                              child: block(
                                color: onGradient,
                                height: AppSize.iconLg,
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: block(
                                color: onGradient,
                                height: AppSize.iconLg,
                              ),
                            ),
                            const Spacer(flex: 2),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Alert line, full width
              Row(
                spacing: AppSpacing.sm,
                children: [
                  block(
                    color: onGradient,
                    width: AppSize.icon,
                    height: AppSize.icon,
                    circle: true,
                  ),
                  Expanded(child: line(0.6, color: onGradient)),
                ],
              ),
            ],
          ),
        );

        // Address card: primary tile, two lines.
        final address = AppCard(
          child: Row(
            spacing: AppSpacing.md,
            children: [
              tile(AppColors.primaryContainer(context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: AppSpacing.xs,
                  children: [line(0.9), line(0.45)],
                ),
              ),
            ],
          ),
        );

        // Collapsible card: tinted tile, title line, chevron.
        Widget collapsible(Color tileColor) => AppCard(
          child: Row(
            spacing: AppSpacing.smd,
            children: [
              tile(tileColor),
              Expanded(child: line(0.5)),
              chevron(),
            ],
          ),
        );

        return SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.smd,
            AppSpacing.md,
            AppSpacing.md,
          ),
          child: Column(
            spacing: AppSpacing.md,
            children: [
              banner,
              hero,
              address,
              collapsible(AppColors.successContainer), // status
              collapsible(AppColors.primaryContainer(context)), // schedule
              collapsible(AppColors.infoContainer), // activity
            ],
          ),
        );
      },
    );
  }
}
