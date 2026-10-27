import 'package:flutter/material.dart';
import 'package:synquerra/presentation/themes/app_tokens.dart';
import 'package:synquerra/presentation/themes/colors.dart';

/// Pulsing placeholder for [TodayScheduleCard] rows (pill, two lines, button).
class ScheduleRowSkeleton extends StatefulWidget {
  final int count;
  const ScheduleRowSkeleton({super.key, this.count = 2});

  @override
  State<ScheduleRowSkeleton> createState() => _ScheduleRowSkeletonState();
}

class _ScheduleRowSkeletonState extends State<ScheduleRowSkeleton>
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
        final base = Color.lerp(
          AppColors.surfaceVariant(context),
          AppColors.outlineVariant(context),
          _anim.value * AppAlpha.overlay,
        )!;

        Widget block({double? width, double height = AppSize.skeletonLine}) =>
            Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: base,
                borderRadius: AppRadius.pillAll,
              ),
            );

        Widget row() => Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            spacing: AppSpacing.smd,
            children: [
              block(width: 56, height: AppSize.iconLg), // time pill
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: AppSpacing.xs,
                  children: [
                    FractionallySizedBox(
                      widthFactor: 0.6,
                      alignment: Alignment.centerLeft,
                      child: block(),
                    ),
                    FractionallySizedBox(
                      widthFactor: 0.35,
                      alignment: Alignment.centerLeft,
                      child: block(),
                    ),
                  ],
                ),
              ),
              block(width: 52, height: AppSize.iconLg), // skip button
            ],
          ),
        );

        return Column(children: [for (var i = 0; i < widget.count; i++) row()]);
      },
    );
  }
}
