// lib/presentation/screens/location/widgets/last_updated_badge.dart

import 'dart:async';
import 'package:flutter/material.dart';
import '../../../themes/app_text_styles.dart';
import '../../../themes/colors.dart';
import '../../../utils/date_time_formatter.dart';
import '../../../themes/app_tokens.dart';

class LastUpdatedBadge extends StatefulWidget {
  final DateTime? timestamp;
  const LastUpdatedBadge({super.key, required this.timestamp});

  @override
  State<LastUpdatedBadge> createState() => _LastUpdatedBadgeState();
}

class _LastUpdatedBadgeState extends State<LastUpdatedBadge>
    with SingleTickerProviderStateMixin {
  // TODO(logic): freshness polling interval, not a visual duration.
  static const _refreshEvery = Duration(seconds: 10);

  late final AnimationController _pulseController;
  Timer? _ticker;
  bool _isLive = false;
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: AppMotion.pulse,
    );
    _isLive = DateTimeFormatter.isLive(widget.timestamp);
    _ticker = Timer.periodic(_refreshEvery, (_) {
      if (!mounted) return;
      setState(_evaluateFreshness);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    _syncPulse();
  }

  @override
  void didUpdateWidget(covariant LastUpdatedBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.timestamp != widget.timestamp) _evaluateFreshness();
  }

  void _evaluateFreshness() {
    _isLive = DateTimeFormatter.isLive(widget.timestamp);
    _syncPulse();
  }

  void _syncPulse() {
    if (_isLive && !_reduceMotion) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      _pulseController.stop(); // no wasted frames while stale / reduce-motion
      _pulseController.value = 1;
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  Widget _dot(Color color, double fillAlpha) => Container(
    width: AppSize.dot,
    height: AppSize.dot,
    decoration: BoxDecoration(
      color: AppAlpha.withAlpha(color, fillAlpha),
      border: Border.all(color: color, width: AppSize.stroke),
      shape: BoxShape.circle,
    ),
  );

  @override
  Widget build(BuildContext context) {
    if (widget.timestamp == null) return const SizedBox.shrink();

    final surface = AppColors.surface(context);
    final dotColor = _isLive ? AppColors.success : AppColors.offline;
    final textColor = _isLive
        ? AppColors.textPrimary(context)
        : AppColors.textSecondary(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: _isLive
            ? Color.alphaBlend(AppColors.successContainer, surface)
            : surface,
        borderRadius: AppRadius.pillAll,
        border: Border.all(
          color: AppAlpha.withBorderAlpha(AppColors.outlineVariant(context)),
        ),
        boxShadow: AppShadow.soft(AppColors.shadow(context)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.smd,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: AppSpacing.xs,
          children: [
            if (_isLive)
              AnimatedBuilder(
                animation: _pulseController,
                builder: (_, __) => _dot(
                  dotColor,
                  AppAlpha.disabled +
                      (1 - AppAlpha.disabled) * _pulseController.value,
                ),
              )
            else
              _dot(dotColor, 1),
            Text(
              DateTimeFormatter.formatRelativeTime(widget.timestamp),
              style: AppTextStyles.metaWithColor(
                context,
                color: textColor,
              ).copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
