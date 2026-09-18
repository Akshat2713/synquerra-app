import 'package:flutter/material.dart';

import '../../../../domain/entities/schedule/schedule_entity.dart';
import '../../../themes/colors.dart';

class ScheduleTimingCard extends StatelessWidget {
  final ScheduleEntity schedule;

  const ScheduleTimingCard({super.key, required this.schedule});

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
                  Icons.schedule_outlined,
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Timing & Recurrence',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              context,
              label: 'Active Hours',
              value: '${schedule.startTime} - ${schedule.endTime}',
              isHighlight: true,
            ),
            const Divider(height: 24),
            _buildDetailRow(
              context,
              label: 'Timezone',
              value: schedule.timezone,
            ),
            _buildDetailRow(
              context,
              label: 'Validity Period',
              value: schedule.endDate != null
                  ? '${schedule.startDate} to ${schedule.endDate}'
                  : 'From ${schedule.startDate} (Ongoing)',
            ),
            _buildDetailRow(
              context,
              label: 'Midnight Cross',
              value: schedule.crossesMidnight ? 'Yes' : 'No',
            ),
            const SizedBox(height: 12),
            _buildDaysOfWeekPicker(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDaysOfWeekPicker(BuildContext context) {
    final days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final isSelected = schedule.daysOfWeek.contains(index);
        return CircleAvatar(
          radius: 18,
          backgroundColor: isSelected
              ? AppColors.primary
              : AppColors.background(context),
          child: Text(
            days[index],
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isSelected
                  ? Colors.white
                  : AppColors.textSecondary(context),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required String label,
    required String value,
    bool isHighlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary(context),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isHighlight ? 16 : 14,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
              color: isHighlight
                  ? AppColors.primary
                  : AppColors.textPrimary(context),
            ),
          ),
        ],
      ),
    );
  }
}
