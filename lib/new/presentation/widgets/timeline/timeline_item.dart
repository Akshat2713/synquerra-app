// lib/presentation/widgets/timeline/timeline_item.dart
import 'package:flutter/material.dart';
import 'package:synquerra/presentation/themes/colors.dart';
import '../../../business/entities/analytics_entity.dart';

class TimelineItem extends StatelessWidget {
  final AnalyticsDistanceEntity item;
  final bool isLast;

  const TimelineItem({super.key, required this.item, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isIdle = item.isIdle;
    final activeColor = isIdle
        ? Colors.grey.withOpacity(0.4)
        : AppColors.navBlue;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time Column
          SizedBox(
            width: 50,
            child: Text(
              item.hour,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ),

          // Line & Dot
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isIdle ? Colors.transparent : activeColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: activeColor, width: 2),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.grey.withOpacity(0.3),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),

          // Data Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: isIdle
                      ? null
                      : Border.all(color: activeColor.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isIdle ? "Idle / Stationary" : "Active Movement",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: activeColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${item.distance.toStringAsFixed(3)} km",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isIdle
                                ? colorScheme.onSurface.withOpacity(0.5)
                                : colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "Total So Far",
                          style: TextStyle(
                            fontSize: 10,
                            color: colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                        Text(
                          "${item.cumulative.toStringAsFixed(2)} km",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
