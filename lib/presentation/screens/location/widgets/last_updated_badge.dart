import 'dart:async';
import 'package:flutter/material.dart';
import 'package:synquerra/presentation/themes/colors.dart';
import '../../../utils/date_time_formatter.dart';

/// Small pill badge showing "x ago" for the current analytics point's
/// device timestamp. Pulses while the data is considered "live" (<60s old).
/// Self-refreshes every 30s so the text doesn't go stale without a rebuild.
class LastUpdatedBadge extends StatefulWidget {
  final DateTime? timestamp;
  const LastUpdatedBadge({super.key, required this.timestamp});

  @override
  State<LastUpdatedBadge> createState() => _LastUpdatedBadgeState();
}

class _LastUpdatedBadgeState extends State<LastUpdatedBadge>
    with SingleTickerProviderStateMixin {
  Timer? _ticker;
  late final AnimationController _pulseController;

  static const _liveThreshold = Duration(seconds: 60);

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  bool get _isLive {
    final ts = widget.timestamp;
    if (ts == null) return false;
    return DateTime.now().difference(ts) < _liveThreshold;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.timestamp == null) return const SizedBox.shrink();

    const color = AppColors.alertSuccess;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.backgroundContainer.withValues(alpha: 0.85),
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
            style: const TextStyle(
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
