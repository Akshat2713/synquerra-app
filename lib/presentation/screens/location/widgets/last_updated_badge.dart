// lib/presentation/screens/location/widgets/last_updated_badge.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:synquerra/presentation/themes/colors.dart';
import '../../../utils/date_time_formatter.dart';

/// Small pill badge showing "x ago" for the current analytics point's
/// device timestamp.
///
/// * Live (<60s old, per DateTimeFormatter.isLive): green, pulsing dot.
/// * Stale: neutral colour, static dot, so a last-known position is never
///   presented as if it were current.
///
/// It re-evaluates on its own timer, so the text and live/stale state keep
/// updating even when no new data arrives (the old `_ticker` was declared but
/// never started).
class LastUpdatedBadge extends StatefulWidget {
  final DateTime? timestamp;
  const LastUpdatedBadge({super.key, required this.timestamp});

  @override
  State<LastUpdatedBadge> createState() => _LastUpdatedBadgeState();
}

class _LastUpdatedBadgeState extends State<LastUpdatedBadge>
    with SingleTickerProviderStateMixin {
  static const _refreshEvery = Duration(seconds: 10);

  late final AnimationController _pulseController;
  Timer? _ticker;
  bool _isLive = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _evaluateFreshness();
    _ticker = Timer.periodic(_refreshEvery, (_) {
      if (!mounted) return;
      setState(_evaluateFreshness);
    });
  }

  @override
  void didUpdateWidget(covariant LastUpdatedBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.timestamp != widget.timestamp) _evaluateFreshness();
  }

  void _evaluateFreshness() {
    _isLive = DateTimeFormatter.isLive(widget.timestamp);
    if (_isLive) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      _pulseController.stop(); // no wasted frames while stale
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.timestamp == null) return const SizedBox.shrink();

    final Color color = _isLive
        ? AppColors.success
        : Theme.of(context).colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant(context).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isLive)
            AnimatedBuilder(
              animation: _pulseController,
              builder: (_, __) => Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color.withValues(
                    alpha: 0.4 + (_pulseController.value * 0.6),
                  ),
                  border: Border.all(color: color, width: 2),
                  shape: BoxShape.circle,
                ),
              ),
            )
          else
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          const SizedBox(width: 4),
          Text(
            DateTimeFormatter.formatRelativeTime(widget.timestamp),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
