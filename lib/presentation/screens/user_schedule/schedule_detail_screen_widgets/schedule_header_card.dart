import 'package:flutter/material.dart';

import '../../../../domain/entities/schedule/schedule_entity.dart';
import '../../../themes/colors.dart';

class ScheduleHeaderCard extends StatelessWidget {
  final ScheduleEntity schedule;

  const ScheduleHeaderCard({super.key, required this.schedule});

  @override
  Widget build(BuildContext context) {
    final activeColor = schedule.isActive
        ? AppColors.success
        : AppColors.danger;

    return Card(
      elevation: 0,
      color: AppColors.surface(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Row 1: Title on left, Active indicator on right
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    schedule.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Compact Active/Inactive Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: activeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: activeColor,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        schedule.isActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: activeColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Description (placed directly under title)
            if (schedule.description != null &&
                schedule.description!.trim().isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                schedule.description!,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.35,
                  color: AppColors.textSecondary(context),
                ),
              ),
            ],

            const SizedBox(height: 14),

            // Footer Row: Priority metadata anchored at bottom-left
            Row(
              children: [
                Text(
                  'Priority',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary(context),
                  ),
                ),
                const SizedBox(width: 6),
                _PriorityBadge(priority: schedule.priority),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  final String priority;

  const _PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    final color = _getPriorityColor(priority);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Text(
        priority.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          color: color,
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toUpperCase()) {
      case 'CRITICAL':
        return AppColors.danger;
      case 'HIGH':
        return AppColors.dangerContainer;
      case 'MEDIUM':
        return AppColors.warning;
      case 'LOW':
        return AppColors.info;
      default:
        return AppColors.success;
    }
  }
}
