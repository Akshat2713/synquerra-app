import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../themes/app_tokens.dart';
import '../../../themes/colors.dart';
import '../../../widgets/app_surfaces.dart';

const double _pillHeight = AppSize.icon + AppSpacing.xs;

class ScheduleListSkeleton extends StatelessWidget {
  static const int _count = 3;

  const ScheduleListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final body = Semantics(
      label: 'Loading schedules',
      excludeSemantics: true,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: AppSpacing.mdAll,
        child: Column(
          spacing: AppSpacing.md,
          children: List.generate(_count, (_) => const _CardSkeleton()),
        ),
      ),
    );

    if (MediaQuery.disableAnimationsOf(context)) return body;
    return body
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .fade(
          begin: AppAlpha.overlay,
          end: 1,
          duration: AppMotion.pulse,
          curve: AppMotion.curve,
        );
  }
}

class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton();

  @override
  Widget build(BuildContext context) => AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.smd,
      children: [
        // Header: tile, two text lines, switch
        Row(
          spacing: AppSpacing.smd,
          children: const [
            _Bone(
              width: AppSize.tile,
              height: AppSize.tile,
              radius: AppRadius.md,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: AppSpacing.sm,
                children: [
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.6,
                    child: _Bone(),
                  ),
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.35,
                    child: _Bone(),
                  ),
                ],
              ),
            ),
            _Bone(width: AppSize.tapTarget, height: AppSize.avatarSm),
          ],
        ),
        // Time strip
        const _Bone(height: AppSize.tapTarget, radius: AppRadius.md),
        // Day dots
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            7,
            (_) =>
                const _Bone(width: AppSize.avatarSm, height: AppSize.avatarSm),
          ),
        ),
        // Footer pills
        const Row(
          spacing: AppSpacing.sm,
          children: [
            Expanded(flex: 3, child: _Bone(height: _pillHeight)),
            Expanded(flex: 4, child: _Bone(height: _pillHeight)),
            Spacer(flex: 3),
          ],
        ),
      ],
    ),
  );
}

class _Bone extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;

  const _Bone({
    this.width,
    this.height = AppSize.skeletonLine,
    this.radius = AppRadius.pill,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: AppColors.surfaceVariant(context),
      borderRadius: BorderRadius.circular(radius),
    ),
  );
}
