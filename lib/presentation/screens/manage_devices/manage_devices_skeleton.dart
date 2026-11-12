import 'package:flutter/material.dart';

import '../../themes/app_tokens.dart';
import '../../themes/colors.dart';
import '../../widgets/app_surfaces.dart';

/// Loading placeholder mirroring Manage Devices: summary hero, then
/// "Needs assignment" and "Assigned" sections with device cards.
class ManageDevicesSkeleton extends StatefulWidget {
  const ManageDevicesSkeleton({super.key});

  @override
  State<ManageDevicesSkeleton> createState() => _ManageDevicesSkeletonState();
}

class _ManageDevicesSkeletonState extends State<ManageDevicesSkeleton>
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

        // Neutral pulse for blocks sitting on cards.
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
          BorderRadius? radius,
        }) => Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: radius ?? AppRadius.pillAll,
          ),
        );

        Widget line(
          double factor, {
          Color? color,
          double height = AppSize.skeletonLine,
        }) => FractionallySizedBox(
          widthFactor: factor,
          alignment: Alignment.centerLeft,
          child: block(color: color ?? base, height: height),
        );

        Widget tile(Color color) => block(
          color: color,
          width: AppSize.tile,
          height: AppSize.tile,
          radius: AppRadius.mdAll,
        );

        // _SummaryHero: tile + two lines, then two pills.
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
                spacing: AppSpacing.md,
                children: [
                  tile(onGradient),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: AppSpacing.sm,
                      children: [
                        line(0.4, color: onGradient, height: AppSize.icon),
                        line(0.65, color: onGradient),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                spacing: AppSpacing.sm,
                children: [
                  block(
                    color: onGradient,
                    width: AppSize.buttonMinWidth + AppSpacing.lg,
                    height: AppSize.iconLg,
                  ),
                  block(
                    color: onGradient,
                    width: AppSize.buttonMinWidth + AppSpacing.xl,
                    height: AppSize.iconLg,
                  ),
                ],
              ),
            ],
          ),
        );

        // _Section header: title line + count pill.
        Widget sectionHeader(Color pillColor) => Padding(
          padding: AppSpacing.xsHorizontal,
          child: Row(
            spacing: AppSpacing.sm,
            children: [
              block(color: base, width: AppSize.buttonMinWidth + AppSpacing.md),
              block(
                color: pillColor,
                width: AppSize.tile,
                height: AppSize.iconLg,
              ),
            ],
          ),
        );

        // ManageDeviceCard: header row, carrier InsetRow, action buttons.
        Widget deviceCard(Color tileColor, Color pillColor) => AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.smd,
            children: [
              Row(
                spacing: AppSpacing.smd,
                children: [
                  tile(tileColor),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: AppSpacing.sm,
                      children: [
                        line(0.55, height: AppSize.icon),
                        line(0.4),
                      ],
                    ),
                  ),
                  block(
                    color: pillColor,
                    width: AppSize.buttonMinWidth + AppSpacing.sm,
                    height: AppSize.iconLg,
                  ),
                ],
              ),
              block(
                color: base,
                height: AppSize.tapTarget,
                radius: AppRadius.mdAll,
              ),
              Row(
                spacing: AppSpacing.sm,
                children: [
                  Expanded(
                    child: block(
                      color: base,
                      height: AppSize.tapTarget,
                      radius: AppRadius.mdAll,
                    ),
                  ),
                  Expanded(
                    child: block(
                      color: AppColors.primaryContainer(context),
                      height: AppSize.tapTarget,
                      radius: AppRadius.mdAll,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );

        Widget section(Color pillColor, Color tileColor, int cards) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSpacing.smd,
          children: [
            sectionHeader(pillColor),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AppSpacing.md,
              children: [
                for (var i = 0; i < cards; i++)
                  deviceCard(tileColor, pillColor),
              ],
            ),
          ],
        );

        return SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.lg,
            children: [
              hero,
              section(
                AppColors.warningContainer,
                AppColors.warningContainer,
                1,
              ),
              section(
                AppColors.successContainer,
                AppColors.successContainer,
                2,
              ),
            ],
          ),
        );
      },
    );
  }
}
