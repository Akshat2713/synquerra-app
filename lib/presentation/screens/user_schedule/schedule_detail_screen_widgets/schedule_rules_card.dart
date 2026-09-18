import 'package:flutter/material.dart';

import '../../../../domain/entities/schedule/schedule_entity.dart';
import '../../../themes/colors.dart';

class ScheduleRulesCard extends StatelessWidget {
  final ScheduleEntity schedule;

  const ScheduleRulesCard({super.key, required this.schedule});

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
                Icon(Icons.tune_outlined, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Grace & Alert Rules',
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
            const Divider(height: 24),
            _buildSwitchTile(
              context,
              label: 'Alert on Absence',
              enabled: schedule.alertOnAbsence,
            ),
            _buildSwitchTile(
              context,
              label: 'Alert on Late Arrival',
              enabled: schedule.alertOnLateArrival,
            ),
            _buildSwitchTile(
              context,
              label: 'Alert on Early Departure',
              enabled: schedule.alertOnEarlyDeparture,
            ),
            _buildSwitchTile(
              context,
              label: 'Alert on Early Entry',
              enabled: schedule.alertOnEarlyEntry,
            ),
            _buildSwitchTile(
              context,
              label: 'Alert on Re-entry',
              enabled: schedule.alertOnReentry,
            ),
            _buildSwitchTile(
              context,
              label: 'Push Notifications',
              enabled: schedule.sendPushNotification,
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

  Widget _buildSwitchTile(
    BuildContext context, {
    required String label,
    required bool enabled,
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
              color: AppColors.textPrimary(context),
            ),
          ),
          Icon(
            enabled ? Icons.check_circle : Icons.cancel,
            size: 20,
            color: enabled
                ? AppColors.success
                : AppColors.textSecondary(context).withAlpha(100),
          ),
        ],
      ),
    );
  }
}
