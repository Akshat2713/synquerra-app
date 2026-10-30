import 'package:flutter/material.dart';
import 'package:synquerra/presentation/themes/app_text_styles.dart';
import 'package:synquerra/presentation/themes/app_tokens.dart';
import 'package:synquerra/presentation/themes/colors.dart';
import 'package:synquerra/presentation/utils/colour_util.dart';
import 'package:synquerra/presentation/widgets/app_surfaces.dart';

import '../../../../domain/entities/schedule/schedule_entity.dart';

class ScheduleHeaderCard extends StatelessWidget {
  final ScheduleEntity schedule;

  const ScheduleHeaderCard({super.key, required this.schedule});

  @override
  Widget build(BuildContext context) {
    final onHero = AppColors.onPrimary(context);
    final onHeroSoft = AppAlpha.withAlpha(onHero, AppAlpha.strong);
    final pillFill = AppAlpha.withAlpha(onHero, AppAlpha.fill);
    final description = schedule.description?.trim() ?? '';

    return Container(
      padding: AppSpacing.mdAll,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient(context),
        borderRadius: AppRadius.lgAll,
        boxShadow: AppShadow.glow(AppColors.primary(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.smd,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSpacing.smd,
            children: [
              Expanded(
                child: Text(
                  schedule.title,
                  style: AppTextStyles.titleWithColor(context, color: onHero),
                ),
              ),
              InfoPill(
                label: schedule.isActive ? 'Active' : 'Inactive',
                dotColor: schedule.isActive
                    ? AppColors.success
                    : AppColors.offline,
                background: pillFill,
                foreground: onHero,
              ),
            ],
          ),
          if (description.isNotEmpty)
            Text(
              description,
              style: AppTextStyles.bodyWithColor(context, color: onHeroSoft),
            ),
          Row(
            spacing: AppSpacing.sm,
            children: [
              Text(
                'Priority',
                style: AppTextStyles.metaWithColor(context, color: onHeroSoft),
              ),
              InfoPill(
                label: schedule.priority.toUpperCase(),
                dotColor: priorityColor(schedule.priority),
                background: pillFill,
                foreground: onHero,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
