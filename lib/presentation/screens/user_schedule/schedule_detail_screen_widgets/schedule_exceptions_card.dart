import 'package:flutter/material.dart';

import '../../../../domain/entities/schedule/schedule_override_entity.dart';
import '../../../themes/colors.dart';

class ScheduleExceptionsCard extends StatelessWidget {
  final List<ScheduleOverrideEntity> overrides;
  final Set<String> processingIds;
  final VoidCallback onAddException;
  final ValueChanged<ScheduleOverrideEntity> onEditException;
  final ValueChanged<ScheduleOverrideEntity> onDeleteException;

  const ScheduleExceptionsCard({
    super.key,
    required this.overrides,
    required this.onAddException,
    required this.onEditException,
    required this.onDeleteException,
    this.processingIds = const {},
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.surface(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.event_busy_outlined,
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Schedule Exceptions (${overrides.length})',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add, color: AppColors.primary),
                  onPressed: onAddException,
                ),
              ],
            ),
            const SizedBox(height: 12),
            overrides.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Text(
                      'No custom exceptions configured for this schedule.',
                      style: TextStyle(
                        color: AppColors.textSecondary(context),
                        fontSize: 14,
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: overrides.length,
                    separatorBuilder: (_, __) => const Divider(height: 16),
                    itemBuilder: (context, index) {
                      return _buildOverrideItem(context, overrides[index]);
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverrideItem(
    BuildContext context,
    ScheduleOverrideEntity override,
  ) {
    final isCancel = override.overrideType.toUpperCase() == 'CANCEL';
    final isProcessing = processingIds.contains(override.id);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                override.date,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppColors.textPrimary(context),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isCancel
                          ? AppColors.danger.withAlpha(30)
                          : AppColors.primary.withAlpha(30),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isCancel ? 'Cancelled' : 'Modified Hours',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isCancel ? AppColors.danger : AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  if (isProcessing)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  else ...[
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: AppColors.textSecondary(context),
                      ),
                      onPressed: () => onEditException(override),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: AppColors.danger,
                      ),
                      onPressed: () => onDeleteException(override),
                    ),
                  ],
                ],
              ),
            ],
          ),
          if (!isCancel &&
              override.startTime != null &&
              override.endTime != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: AppColors.textSecondary(context),
                ),
                const SizedBox(width: 4),
                Text(
                  '${override.startTime} - ${override.endTime}',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ],
          if (override.reason != null && override.reason!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Reason: ${override.reason}',
              style: TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: AppColors.textSecondary(context),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
