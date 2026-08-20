// lib/presentation/screens/location/widgets/last_updated_badge.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:synquerra/presentation/themes/colors.dart';
import '../../../utils/date_time_formatter.dart';

/// Small pill badge showing "x ago" for the current analytics point's
/// device timestamp. Pulses while the data is considered "live" (<60s old).
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

  @override
  Widget build(BuildContext context) {
    if (widget.timestamp == null) return const SizedBox.shrink();

    const color = AppColors.alertSuccess;
    final isLive = DateTimeFormatter.isLive(widget.timestamp);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.backgroundContainer.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLive)
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
              decoration: const BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
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
