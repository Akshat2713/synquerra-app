import 'package:flutter/material.dart';

import '../../themes/app_tokens.dart';
import '../../themes/colors.dart';
import '../../widgets/app_surfaces.dart';

/// Loading placeholder mirroring the Manage Users list (MemberCard rows).
class ManageUsersSkeleton extends StatefulWidget {
  const ManageUsersSkeleton({super.key});

  @override
  State<ManageUsersSkeleton> createState() => _ManageUsersSkeletonState();
}

class _ManageUsersSkeletonState extends State<ManageUsersSkeleton>
    with SingleTickerProviderStateMixin {
  static const int _cardCount = 4;

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

        Widget block({
          double? width,
          double height = AppSize.skeletonLine,
          bool circle = false,
        }) => Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: base,
            shape: circle ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: circle ? null : AppRadius.pillAll,
          ),
        );

        Widget line(double factor, {double height = AppSize.skeletonLine}) =>
            FractionallySizedBox(
              widthFactor: factor,
              alignment: Alignment.centerLeft,
              child: block(height: height),
            );

        // MemberCard: avatar, name + phone + email lines, "more" icon.
        Widget memberCard() => AppCard(
          child: Row(
            spacing: AppSpacing.md,
            children: [
              block(
                width: AppSize.tapTarget,
                height: AppSize.tapTarget,
                circle: true,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: AppSpacing.sm,
                  children: [
                    line(0.5, height: AppSize.iconLg),
                    line(0.4),
                    line(0.7),
                  ],
                ),
              ),
              block(width: AppSize.icon, height: AppSize.icon, circle: true),
            ],
          ),
        );

        return SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          padding: AppSpacing.mdAll,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.md,
            children: [for (var i = 0; i < _cardCount; i++) memberCard()],
          ),
        );
      },
    );
  }
}
