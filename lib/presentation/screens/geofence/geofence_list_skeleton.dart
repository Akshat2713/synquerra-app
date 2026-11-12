import 'package:flutter/material.dart';

import '../../themes/app_tokens.dart';
import '../../themes/colors.dart';
import '../../widgets/app_surfaces.dart';

/// Loading placeholder mirroring the geofence list page: search field,
/// "Important" section (2 filled slots + 1 empty slot), "General" section
/// (geofence cards).
class GeofenceListSkeleton extends StatefulWidget {
  const GeofenceListSkeleton({super.key});

  @override
  State<GeofenceListSkeleton> createState() => _GeofenceListSkeletonState();
}

class _GeofenceListSkeletonState extends State<GeofenceListSkeleton>
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
        Widget line(double factor) => FractionallySizedBox(
          widthFactor: factor,
          alignment: Alignment.centerLeft,
          child: block(color: base),
        );

        Widget tile(Color color, {double size = AppSize.tile}) => block(
          color: color,
          width: size,
          height: size,
          radius: AppRadius.mdAll,
        );

        Widget chevron() => block(
          color: base,
          width: AppSize.icon,
          height: AppSize.icon,
          circle: true,
        );

        // Section header: title line + count pill.
        Widget sectionHeader(Color pillColor) => Row(
          spacing: AppSpacing.sm,
          children: [
            block(color: base, width: AppSize.buttonMinWidth),
            block(
              color: pillColor,
              width: AppSize.tile + AppSpacing.sm,
              height: AppSize.iconLg,
            ),
          ],
        );

        // Filled geofence card (GeofenceListTile): small tile, name,
        // edit + delete icons, then the mode InsetRow.
        Widget geofenceCard() => AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.sm,
            children: [
              Row(
                spacing: AppSpacing.smd,
                children: [
                  tile(
                    AppColors.primaryContainer(context),
                    size: AppSize.avatarSm,
                  ),
                  Expanded(child: line(0.5)),
                  block(
                    color: base,
                    width: AppSize.icon,
                    height: AppSize.icon,
                    circle: true,
                  ),
                  block(
                    color: base,
                    width: AppSize.icon,
                    height: AppSize.icon,
                    circle: true,
                  ),
                ],
              ),
              block(color: base, height: AppSize.tile, radius: AppRadius.mdAll),
            ],
          ),
        );

        // Empty slot card (_EmptySlotTile): circle tile, two lines, chevron.
        Widget emptySlotCard() => AppCard(
          child: Row(
            spacing: AppSpacing.smd,
            children: [
              block(
                color: AppColors.primaryContainer(context),
                width: AppSize.tile,
                height: AppSize.tile,
                circle: true,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: AppSpacing.xs,
                  children: [line(0.3), line(0.55)],
                ),
              ),
              chevron(),
            ],
          ),
        );

        return SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          padding: AppSpacing.mdAll,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Search field
              block(
                color: AppColors.surfaceVariant(context),
                height: AppSize.tapTarget,
                radius: AppRadius.mdAll,
              ),
              const SizedBox(height: AppSpacing.md),
              // Important section
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: AppSpacing.smd,
                children: [
                  sectionHeader(AppColors.successContainer),
                  geofenceCard(),
                  geofenceCard(),
                  emptySlotCard(),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              // General section
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: AppSpacing.smd,
                children: [
                  sectionHeader(AppColors.infoContainer),
                  geofenceCard(),
                  geofenceCard(),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
