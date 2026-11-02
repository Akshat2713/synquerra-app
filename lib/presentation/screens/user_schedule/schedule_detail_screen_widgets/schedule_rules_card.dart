import 'package:flutter/material.dart';
import '../../../themes/app_tokens.dart';
import '../../../themes/colors.dart';
import '../../../utils/app_icons.dart';
import '../../../widgets/app_surfaces.dart';

import '../../../../domain/entities/schedule/schedule_entity.dart';
import 'detail_card_parts.dart';

class ScheduleRulesCard extends StatelessWidget {
  final ScheduleEntity schedule;

  const ScheduleRulesCard({super.key, required this.schedule});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.smd,
        children: [
          const DetailCardHeader(
            title: 'Grace Rules',
            icon: AppIcons.rules,
            background: AppColors.info,
            foreground: AppColors.onInfo,
          ),
          Column(
            children: [
              DetailRow(
                label: 'Arrival Grace',
                value: '${schedule.arrivalGraceMins} mins',
              ),
              DetailRow(
                label: 'Departure Buffer',
                value: '${schedule.departureBufferMins} mins',
              ),
              if (schedule.minimumStayMins != null)
                DetailRow(
                  label: 'Minimum Stay',
                  value: '${schedule.minimumStayMins} mins',
                ),
            ],
          ),
        ],
      ),
    );
  }
}
