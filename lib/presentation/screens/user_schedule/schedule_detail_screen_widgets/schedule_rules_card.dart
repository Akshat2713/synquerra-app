import 'package:flutter/material.dart';

import '../../../../domain/entities/schedule/schedule_entity.dart';
import '../../../themes/colors.dart';
import 'package:synquerra/presentation/themes/app_tokens.dart';

class ScheduleRulesCard extends StatelessWidget {
  final ScheduleEntity schedule;

  const ScheduleRulesCard({super.key, required this.schedule});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.surface(context),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.tune_outlined, size: 20, color: AppColors.primary(context)),
                const SizedBox(width: 8),
                Text(
                  'Grace Rules',
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
              label: 'Arrival Grace',
              value: '${schedule.arrivalGraceMins} mins',
            ),
            _buildDetailRow(
              context,
              label: 'Departure Buffer',
              value: '${schedule.departureBufferMins} mins',
            ),
            if (schedule.minimumStayMins != null)
              _buildDetailRow(
                context,
                label: 'Minimum Stay',
                value: '${schedule.minimumStayMins} mins',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required String label,
    required String value,
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
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary(context),
            ),
          ),
        ],
      ),
    );
  }
}
