import 'package:flutter/material.dart';
import '../../../themes/app_tokens.dart';
import '../../../themes/colors.dart';
import '../../../utils/app_icons.dart';
import '../../../widgets/app_surfaces.dart';

import '../../../../domain/entities/schedule/schedule_entity.dart';
import '../../schedule_form/widgets/day_selector_row.dart';
import 'detail_card_parts.dart';

class ScheduleTimingCard extends StatelessWidget {
  final ScheduleEntity schedule;

  const ScheduleTimingCard({super.key, required this.schedule});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.smd,
        children: [
          DetailCardHeader(
            title: 'Timing & Recurrence',
            icon: AppIcons.time,
            background: AppColors.primary(context),
            foreground: AppColors.onPrimary(context),
          ),
          Column(
            children: [
              DetailRow(
                label: 'Active Hours',
                value: '${schedule.startTime} - ${schedule.endTime}',
                highlight: true,
              ),
              DetailRow(label: 'Timezone', value: schedule.timezone),
              DetailRow(
                label: 'Validity Period',
                value: schedule.endDate != null
                    ? '${schedule.startDate} to ${schedule.endDate}'
                    : 'From ${schedule.startDate} (Ongoing)',
              ),
              DetailRow(
                label: 'Midnight Cross',
                value: schedule.crossesMidnight ? 'Yes' : 'No',
              ),
            ],
          ),
          DaySelectorRow(selectedDays: schedule.daysOfWeek),
        ],
      ),
    );
  }
}
