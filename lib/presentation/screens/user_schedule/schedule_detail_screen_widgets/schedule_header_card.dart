import 'package:flutter/material.dart';

import '../../../../domain/entities/schedule/schedule_entity.dart';
import '../../../themes/colors.dart';
import 'package:synquerra/presentation/themes/app_tokens.dart';

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
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
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
                    color: activeColor.withValues(alpha: AppAlpha.tint),
                    borderRadius: AppRadius.mdAll,
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
                      const SizedBox(width: AppSpacing.xs),
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
              const SizedBox(height: AppSpacing.xs),
              Text(
                schedule.description!,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.35,
                  color: AppColors.textSecondary(context),
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.md),

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
                const SizedBox(width: AppSpacing.xs),
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
        color: color.withValues(alpha: AppAlpha.tint),
        borderRadius: AppRadius.smAll,
        border: Border.all(color: color.withValues(alpha: AppAlpha.border), width: 1),
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
